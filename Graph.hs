{-# LANGUAGE ViewPatterns, ScopedTypeVariables, Rank2Types, TemplateHaskell , TypeFamilies, FlexibleContexts, FlexibleInstances,StandaloneDeriving, OverloadedStrings, UndecidableInstances#-}

module Graph where

import Prelude hiding (lookup)
import Control.Arrow (second)
import Control.Lens
import Control.Lens.TH
import qualified Data.Set as S
import Data.Bson
import Data.Text (Text)
import Data.Typeable
import Data.Maybe
import Control.Monad

-- recursive linear path, switching on label l and an integer for indexing a list
data Path l = Path l Int (Path l) | End deriving (Show,Eq)

-- recursive n'ary structure holding some type uniform data at each node. switching is indexed by label + position
data Node a l = Node {
    _core :: a,
    _subNodes ::  [(l,[Node a l])] 
    } deriving (Show, Eq)

makeLenses ''Node



-- lookup something in an association list and possibly return the value and a function to accept a substitution

assocGetAndReplace 
    :: forall a k . Eq k 
    =>  k -- key to lookup
    -> [(k,a)]  -- assoc list to scan
    -> Maybe (a , a -> [(k,a)])

assocGetAndReplace k = assocGetAndReplace' id
  where
  assocGetAndReplace' :: Eq k => ([(k,a)] -> [(k,a)]) -> [(k,a)]  -> Maybe (a , a -> [(k,a)])
  assocGetAndReplace' _ [] = Nothing
  assocGetAndReplace' f ((k',x):kas) 
      | k == k' = Just (x,\x -> f ((k',x):kas))
      | otherwise = assocGetAndReplace' (f . ((k',x):)) kas

-- step a node through a path and possibly return the node and a function to accept a substitution node
nodeAtPath :: Eq l => Node a l -> Path l -> Maybe (Node a l, Node a l -> Node a l)
nodeAtPath (Node x ls) (Path l i _) = do
     (ns,fk) <- assocGetAndReplace l ls 
     (n',f) <- assocGetAndReplace i $ zip [0..] ns
     return $  (n',Node x . fk . map snd . f)


-- try to retrieve a node given a parent node and a path
getNode :: Eq l => Node a l -> Path l -> Maybe (Node a l)
getNode n End = Just n
getNode n p@(Path _ _ (flip getNode -> f)) = nodeAtPath n p >>= f . fst


adjustNode'
    :: Eq l  -- required for indexing subnodes
    => (Node a l -> Maybe (Node a l))  -- fixing
    -> (Maybe (Node a l) -> Maybe (Node a l)) -- close
    -> Node a l  -- parent node
    -> Path l -- target path
    -> Maybe (Node a l) -- new parent node

adjustNode' r z n  End  = z $  r n
adjustNode' r z  n p@(Path _ _ t) = do
    (n',f) <- nodeAtPath n p 
    adjustNode' r (z . fmap f)  n' t

     
adjustNode 
    :: Eq l  -- required for indexing subnodes
    => (Node a l -> Maybe (Node a l))  -- fixing
    -> Node a l -- parent
    -> Path l -- target path
    -> Maybe (Node a l) -- new parent node
adjustNode r = adjustNode' r id





data Annotation  = Annotation {
  _annotator :: Text,
  _subpath :: Path Text,
  _noted :: Value
  }  deriving (Show,Eq)

 
makeLenses ''Annotation


data  Core  = Core  {
  _aut :: Maybe Text, --have an author
  _note :: [Annotation], --have a space for annotations
  _datas :: Document
  } deriving (Show,Eq)

makeLenses ''Core







instance Val (Path Text) where
  val  = Array . serializePath 
    where
      serializePath End = []
      serializePath (Path x i p) = val x : Int32 (fromIntegral i) : serializePath p
  valList = error "list of paths not serializable"
  valMaybe = error "maybe path not serializable"
  cast' (Array xs) = deserializePath xs
    where
    deserializePath [] = Just End
    deserializePath [_] = Nothing
    deserializePath ((cast' -> Just x): Int32 (fromIntegral -> i):rs) = Path x i <$> deserializePath rs
    deserializePath _ = Nothing
  cast' _ = Nothing
  cast'List = error "list of paths not serializable"
  cast'Maybe = error "maybe path not serializable"


instance Val Annotation where
  val (Annotation aut path noted) =  Doc ["author" =: aut, "path" =: path, "note" =: noted]
    
  valList = Array . map val
  valMaybe = error "maybe annotation not serializable"
  cast' (Doc xs) = deserializeAnnotation xs
    where
    deserializeAnnotation xs = do
      au <- "author" `lookup` xs
      path <- "path" `lookup` xs
      note <- "note" `lookup` xs
      if (not . null $ exclude ["author","path","note"] xs) then Nothing 
        else Just $ Annotation au path note
  cast'List (Array xs) = mapM cast' xs
  cast'Maybe = error "maybe annotation not serializable"

instance Val Core where
  val (Core aut ns ds) =  Doc ["author" =: aut, "notes" =: ns, "datas" =: ds]
    
  valList = error "list of cores not serializable"
  valMaybe = error "maybe core not serializable"
  cast' (Doc xs) = deserializeAnnotation xs
    where
    deserializeAnnotation xs = do
      let au = "author" `lookup` xs
      ns <- "notes" `lookup` xs
      ds <- "datas" `lookup` xs
      if (not . null $ exclude ["author","notes","datas"] xs) then Nothing 
        else Just $ Core au ns ds
  cast'List = error "list of cores not serializable"
  cast'Maybe = error "maybe annotation not serializable"

instance Val (Node Core Text) where
  val (Node x ns) =  Doc $ ["core" =: x] ++ map (\(l,xs) -> l := Array (map val xs)) ns
  valList = Array . map val 
  valMaybe = error "maybe core not serializable"
  cast' (Doc xs) = do
      co <- "core" `lookup` xs
      let   r (l := Array ns) = ((,) l) <$>   mapM cast' ns
            r _ = Nothing
      ns <- mapM r (exclude ["core"] xs)  
      return  $ Node co ns
  cast'List (Array xs) = mapM cast' xs
  cast'Maybe = error "maybe annotation not serializable"

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
