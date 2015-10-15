{-# LANGUAGE ViewPatterns, ScopedTypeVariables, 
    Rank2Types, TemplateHaskell, DeriveFunctor #-}

module Graph (Path(..),Node(..),getNode,adjustNode,atPath) where

import Control.Lens (lens,view,set, Lens', over,mapped,_2)
import Control.Lens.TH (makeLenses)
import qualified Data.Set as S
import Lib (assocGetAndReplace)
import Data.Monoid (mappend,mconcat, Monoid)

-- | recursive linear path, switching on label l and an integer for indexing l aist
data Path l = Multi l Int (Path l) | Single l (Path l) | End deriving (Show,Eq)
 
next (Single _ t) = t
next (Multi _ _ t) = t

-- | recursive labelled n'ary structure holding some type uniform data at each node. Subnoding is indexed by label + position
data Node l a = Node {
    _core :: a,
    _subNodes :: [(l,Node l a)],
    _subMultiNodes ::  [(l,[Node l a])] 
    } deriving (Show, Eq, Functor)

makeLenses ''Node

-- step a node through a path and possibly return the node and a function to accept a substitution node
nodeAtPath :: Eq l => Path l -> Node l a -> Maybe (Node l a, Node l a -> Node l a)
nodeAtPath  (Multi l i _) (Node x ss ls) = do
     (ns,fk) <- assocGetAndReplace l ls 
     (n',f) <- assocGetAndReplace i $ zip [0..] ns
     return $  (n',Node x ss . fk . map snd . f)
nodeAtPath  (Single l  _) (Node x ss ls) = do
     (n,f) <- assocGetAndReplace l ss 
     return $  (n,flip (Node x) ls . f)


-- | try to retrieve a node from parent node through a path
getNode :: Eq l =>  Path l -> Node l a -> Maybe (Node l a)
getNode End n = Just n
getNode p@(getNode . next -> f) n = nodeAtPath p n >>= f . fst

  
-- cps action down a path
adjustNode'
    :: Eq l  -- required for indexing subnodes
    => (Node l a -> Maybe (Node l a))  -- fixing action
    -> (Maybe (Node l a) -> Maybe (Node l a)) -- cps action closing
    -> Path l -- target path
    -> Node l a  -- parent node
    -> Maybe (Node l a) -- new parent node

adjustNode' r z End n = z $  r n
adjustNode' r z  p n = do
    (n',f) <- nodeAtPath p n
    adjustNode' r (z . fmap f) (next p) n' 

-- | read and potentially substitute a node at a path
adjustNode 
    :: Eq l  -- required for indexing subnodes
    => (Node l a -> Maybe (Node l a))  -- fixing
    -> Path l -- target path
    -> Node l a -- parent
    -> Maybe (Node l a) -- new parent node
adjustNode r = adjustNode' r id


-- | Path parametrized 'Lens' focusing a subnode at the path, if present
-- semantic is broken on set Nothing which means no-operation and not set Nothing to a node. Incidentally it's broken on view where Nothing means not found.

atPath :: Eq l => Path l -> Lens' (Node l a) (Maybe (Node l a))
atPath p = lens (getNode p) $ 
  \n r -> maybe n id $ adjustNode (const r) p n



-- | follow all paths havesting (a -> b) and backcorrecting (b -> a -> a) each node.
correct :: forall a b l. Monoid b => (a -> b) -> (b -> a -> a) -> Node l a -> (Node l a,b)
correct e c n@(Node x ss ls) = (n',e x `mappend` z) where
    n' = Node (c z x) (map (over _2 fst) ss') $ map (over (_2 .mapped) fst) ls'
    ls' :: [(l, [(Node l a, b)])]
    ls' =  over (mapped . _2 . mapped) (correct e c) ls 
    ss' :: [(l, (Node l a, b))]
    ss' =  over (mapped . _2 ) (correct e c) ss 
    z :: b
    z = mconcat (map (snd . snd) ss') `mappend` mconcat (mconcat $ map (map snd . snd) ls') 



