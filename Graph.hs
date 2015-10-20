{-# LANGUAGE ViewPatterns, ScopedTypeVariables, 
    Rank2Types, TemplateHaskell, DeriveFunctor, TypeFamilies, FlexibleContexts #-}

module Graph where -- (Path(..),Node(..),getNode,overPath) where

import Control.Lens (lens,view,set, Lens', over,mapped,_2, _Just,_1)
import Control.Lens.TH (makeLenses)
import qualified Data.Set as S
import Lib (assocGetAndReplace)
import Data.Monoid (mappend,mconcat, Monoid)

-- | recursive linear path, switching on label l and an integer for indexing l aist
data Path l = Multi l Int (Path l) | Single l (Path l) | End deriving (Show,Eq)



next (Single _ t) = t
next (Multi _ _ t) = t


type family Lof a 

-- | recursive labelled n'ary structure holding some type uniform data at each node. Subnoding is indexed by label + position
data Node a = Node {
    _core :: a,
    _subNodes :: [(Lof a,Node a)], -- ^ single labelled nodes, the can just be modified
    _subMultiNodes ::  [(Lof a,[Node a])] -- ^ multiple labelled nodes, each can be modified, and they can be extended by cloning last
    }

makeLenses ''Node


-- step a node through a path and possibly return the node and a function to accept a substitution node
nodeAtPath :: Eq (Lof a) => Path (Lof a) -> Node a -> Maybe (Node a, Node a -> Node a)
nodeAtPath  (Multi l i _) (Node x ss ls) = do
     (ns,fk) <- assocGetAndReplace l ls 
     (n',f) <- assocGetAndReplace i $ zip [0..] ns
     return $  (n',Node x ss . fk . map snd . f)
nodeAtPath  (Single l  _) (Node x ss ls) = do
     (n,f) <- assocGetAndReplace l ss 
     return $  (n,flip (Node x) ls . f)


-- | try to retrieve a node from parent node through a path
getNode :: Eq (Lof a) =>  Path (Lof a) -> Node a -> Maybe (Node a)
getNode End n = Just n
getNode p@(getNode . next -> f) n = nodeAtPath p n >>= f . fst



-- change a node at a path feeding a context built walking down
overPath   :: Eq (Lof a)  -- required for indexing subnodes
    => (a -> b -> b) -- context correction
    -> (Maybe (Node a) -> Maybe (Node a)) -- cps action closing
    -> b -- ^ initial context
    -> Path (Lof a) -- target path
    -> Node a  -- parent node
    -> (b -> Node a  -> Maybe (Node a))  -- new node computation, by actual context and old node, Nothing is abort correction
    -> Maybe (Node a) -- new parent node

overPath cctx  z ctx End n r = z $  r ctx n
overPath cctx z ctx  p n r = do
    (n',f) <- nodeAtPath p n
    overPath cctx (z . fmap f) (cctx (view core n) ctx) (next p) n' r

---------------------------------------------------------------
--  graph can be only expanded horizontally and it's done by cloning the head of a multi subnode, and change the core of the cloned head 
---------------------------------------------------------------

-- splitting at the last label of a path
initPath :: Path l -> Maybe (Path l, l)
initPath End = Nothing
initPath (Multi l _ End) = Nothing
initPath (Single l End) = Just (End,l)
initPath (Single l p) = over (_Just . _1) (Single l)  $ initPath p
initPath (Multi l i p) = over (_Just . _1) (Multi l i)  $ initPath p

-- traveler helper type
type Pick  a =  
    Path (Lof a) -- ^ target path
    -> (Node a -> Maybe (Node a)) -- ^ correcting function
    -> Maybe (Node a) -- ^ new parent node

-- we split at the last the path, pick to the splitted path asking a correction of the labelled multinode, where we clone the head and correct the cloned core
expand :: Eq (Lof a) 
  => (a -> Maybe a) -- new node core 
  -> Pick  a -- the picking strategy
  -> Path (Lof a) -- path to the label of the multisubnodes field
  -> Maybe (Node a) -- new root
expand tc pick (initPath -> Just (p,k))
      = pick p $ \(Node x ls ms)  -> do
          (n@(Node y ls' ms'):ns, fn) <- assocGetAndReplace k ms
          y' <- tc y
          return (Node x ls . fn $ n : Node y' ls' ms': ns)
expand _ _ _ =  Nothing


-- | follow all paths havesting (a -> b) and backcorrecting (b -> a -> a) each node.
correct :: forall a b l. Monoid b => (a -> b) -> (b -> a -> a) -> Node a -> (Node a,b)
correct e c n@(Node x ss ls) = (n',e x `mappend` z) where
    n' = Node (c z x) (map (over _2 fst) ss') $ map (over (_2 .mapped) fst) ls'
    ls' :: [((Lof a), [(Node a, b)])]
    ls' =  over (mapped . _2 . mapped) (correct e c) ls 
    ss' :: [((Lof a), (Node a, b))]
    ss' =  over (mapped . _2 ) (correct e c) ss 
    z :: b
    z = mconcat (map (snd . snd) ss') `mappend` mconcat (mconcat $ map (map snd . snd) ls') 



