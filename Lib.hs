{-# LANGUAGE ViewPatterns, ScopedTypeVariables, Rank2Types, TemplateHaskell , TypeFamilies, FlexibleContexts, FlexibleInstances,StandaloneDeriving, OverloadedStrings, UndecidableInstances  #-}


module Lib where
        
eq :: Eq a => a -> a -> Bool
eq = (==)


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

