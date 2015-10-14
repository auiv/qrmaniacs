
{-# LANGUAGE ViewPatterns, FlexibleInstances, OverloadedStrings  #-}

-- | BSON Serialize graph elements, 'Path', 'Annotation', 'Core', 'Node', via 'Val' class

module Serialize where

import Prelude hiding (lookup)
import Graph (Path(..), Node(..)) 
import Control.Lens.TH
import Data.Bson (Val(..), lookup, exclude, Field(..), Value(..), (=:))
import Data.Text (Text)
import Core (Core(..),Annotation (..), validDocument, validDataValue)
import Control.Monad (when)


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
      when (not . validDataValue $ note) Nothing
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
      ds <- validDocument <$> "datas" `lookup` xs
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


