
{-# LANGUAGE  TemplateHaskell  #-}

module Core where

import Graph (Path(..))
import Control.Lens.TH (makeLenses)
import Data.Bson (Value(..), Document, Field (..))
import Data.Text (Text)

data Annotation  = Annotation {
  _annotator :: Text,
  _subpath :: Path Text,
  _noted :: Value
  }  deriving (Show,Eq)

 
makeLenses ''Annotation


data  Core  = Core  {
  _aut :: Maybe Text, --have an author
  _note :: [Annotation], --have a space for annotations
  _datas :: Document -- part of Data.Bson.Value
  } deriving (Show,Eq)

makeLenses ''Core



validDataValue :: Value -> Bool
validDataValue (Float _) = True
validDataValue (String _) = True
validDataValue (Md5 _) = True
validDataValue (Bool _) = True
validDataValue (UTC _) = True
validDataValue (RegEx _) = True
validDataValue (Int32 _) = True
validDataValue (Int64 _) = True

validDocument :: Document -> Document 
validDocument = filter (\(_ := v) -> validDataValue v)

