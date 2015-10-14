{-# LANGUAGE ViewPatterns, ScopedTypeVariables, 
    Rank2Types, TemplateHaskell #-}

module Graph (Path(..),Node(..),getNode,adjustNode,atPath) where

import Control.Lens (lens,view,set, Lens')
import Control.Lens.TH (makeLenses)
import qualified Data.Set as S
import Lib (assocGetAndReplace)

-- | recursive linear path, switching on label l and an integer for indexing a list
data Path l = Path l Int (Path l) | End deriving (Show,Eq)

-- | recursive labelled n'ary structure holding some type uniform data at each node. Subnoding is indexed by label + position
data Node a l = Node {
    _core :: a,
    _subNodes ::  [(l,[Node a l])] 
    } deriving (Show, Eq)

makeLenses ''Node

-- step a node through a path and possibly return the node and a function to accept a substitution node
nodeAtPath :: Eq l => Path l -> Node a l -> Maybe (Node a l, Node a l -> Node a l)
nodeAtPath  (Path l i _) (Node x ls) = do
     (ns,fk) <- assocGetAndReplace l ls 
     (n',f) <- assocGetAndReplace i $ zip [0..] ns
     return $  (n',Node x . fk . map snd . f)


-- | try to retrieve a node from parent node through a path
getNode :: Eq l =>  Path l -> Node a l -> Maybe (Node a l)
getNode End n = Just n
getNode p@(Path _ _ (getNode -> f)) n = nodeAtPath p n >>= f . fst

  
-- cps action down a path
adjustNode'
    :: Eq l  -- required for indexing subnodes
    => (Node a l -> Maybe (Node a l))  -- fixing action
    -> (Maybe (Node a l) -> Maybe (Node a l)) -- cps action closing
    -> Path l -- target path
    -> Node a l  -- parent node
    -> Maybe (Node a l) -- new parent node

adjustNode' r z End n = z $  r n
adjustNode' r z  p@(Path _ _ t) n = do
    (n',f) <- nodeAtPath p n
    adjustNode' r (z . fmap f)  t n' 

-- | read and potentially substitute a node at a path
adjustNode 
    :: Eq l  -- required for indexing subnodes
    => (Node a l -> Maybe (Node a l))  -- fixing
    -> Path l -- target path
    -> Node a l -- parent
    -> Maybe (Node a l) -- new parent node
adjustNode r = adjustNode' r id


-- | path parametrized 'Lens' focusing a subnode at the path, if present
-- semantic is broken on set Nothing which means no-operation and not set Nothing to a node. Incidentally it's broken on view where Nothing means not found.

atPath :: Eq l => Path l -> Lens' (Node a l) (Maybe (Node a l))
atPath p = lens (getNode p) $ 
  \n r -> maybe n id $ adjustNode (const r) p n



{-
serialize :: Core Text Document Text -> Document
serialize (Node (Core au notes ds) ns) = ds ++ ["Author" =: au] ++ ["Notes" := Doc ["
parse :: Document -> Reader Text (Maybe NFA)
parse ds = 
  let   author = "author" `lookup` ds 
        notes = "notes" `lookup` ds
        

  case author of 
    Nothing -> 
-}
