{-# LANGUAGE ViewPatterns, ScopedTypeVariables #-}

module Graph where

import Data.List (lookup)

-- recursive linear path, switching on label l and an integer for indexing a list
data Path l = Path l Int (Path l) | End

-- recursive n'ary structure holding some type uniform data at each node. switching is indexed by label + position
data Node a l = Node a [(l,[Node a l])] 



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


replaceNode'
    :: Eq l  -- required for indexing subnodes
    => Node a l -- substitutor
    -> (Maybe (Node a l) -> Maybe (Node a l)) -- close
    -> Node a l  -- parent node
    -> Path l -- target path
    -> Maybe (Node a l) -- new parent node

replaceNode' r z n  End  = z $ Just  r
replaceNode' r z  n p@(Path _ _ t) = do
    (n',f) <- nodeAtPath n p 
    replaceNode' r (z . fmap f)  n' t

     
replaceNode 
    :: Eq l  -- required for indexing subnodes
    => Node a l  -- substitutor
    -> Node a l -- parent
    -> Path l -- target path
    -> Maybe (Node a l) -- new parent node
replaceNode r = replaceNode' r id

    
    
     
