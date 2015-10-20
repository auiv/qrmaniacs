
{-# LANGUAGE  TemplateHaskell, ViewPatterns, TypeFamilies  #-}
-- | The content of a 'Graph.Node'
module Core where

import Graph 
import Control.Lens.TH (makeLenses)
import Control.Lens (over,view, set)
import Data.Bson (Value(..), Document, Field (..))
import Data.Text (Text)
import Data.List (sort)
import qualified Data.Set as S

------------------------------------------------
-------- types
------------------------------

type Author = Text
data Annotation  = Annotation {
  _annotator :: Author,
  _subpath :: Path Text,
  _noted :: Value
  }  deriving (Show,Eq)

 
makeLenses ''Annotation


data  Core  = Core  {
  _author :: Maybe Author, --have an author
  _note :: [Annotation], --have a space for annotations
  _datas :: Document -- part of Data.Bson.Value
  } deriving (Show,Eq)

makeLenses ''Core

type instance Lof Core = Text
--------------------------------------
-------- validation
-------------------------------
-- we only allow a subset  of bson for datas field, recursion is excluded falling back to structural
--------------------------------

--------- template acceptance ------------------
validValue :: Value -> Bool

validValue (Float _) = True
validValue (String _) = True
validValue (Md5 _) = True
validValue (Bool _) = True
validValue (UTC _) = True
validValue (RegEx _) = True
validValue (Int32 _) = True
validValue (Int64 _) = True


validateDatas :: Document -> Bool
validateDatas = all (validValue . value)

-------- post acceptance

-- iso semantics
matchStructure :: Document -> Document -> Bool
matchStructure (map label -> x) (map label -> y) = sort x == sort y

-- match structure and value types
matchTyping :: Document -> Document -> Bool
matchTyping = undefined

--------------------------
--- Node instance
--------------------------

-- | a 'Node' of 'Core' and using 'Text' as 'Path' type
type Resource = Node Core

------------------------------------------------------------
---------------------------- interface 
-----------------------------------------------------------



----------------
-- cloning 
---------------

-- ? account for a  new author

clone 
  :: Author -- who asked for a clone
  -> Resource -- root
  -> Document -- the core of the new subresource
  -> Path Text -- path to the label of the array of subresources
  -> Maybe Resource -- new root, if everything was ok
clone u n d = let 
    -- track last author
    ch (view author -> Just u') _ = Just u'
    ch _ x = x
    tc c  
        | view datas c `matchTyping` d =  Just $ set datas d c
        | otherwise = Nothing  
    in 
      -- call expand feeding in an overPath
      expand tc $ \l f -> let 
        -- test the author is correct for a cloning
        g (fmap (== u) -> Just True) = f
        g _ = const Nothing
        in overPath 
              ch -- track author 
              id -- do nothing on output, as we call from top
              Nothing -- no initial authors
              l -- the reducted path 
              n -- root node
              g -- the author test
------------------------------------------------------------------------


----------------
-- annotation 
---------------

-- ? too expensive schema ?

annotate :: Author -> Path Text -> Annotation -> Resource -> Maybe Resource
annotate = undefined
correctAnnotation :: S.Set Author -> Core -> Core
correctAnnotation vs = over note $ filter (flip S.member vs . view annotator)
extractAuthor :: Core -> S.Set Author
extractAuthor = maybe S.empty S.singleton . view author

-------------------------------------------------------


-------------------------
-- ? modify a resource 
-------------------------


post :: Author -> Path Text -> Document -> Resource -> Maybe Resource
post = undefined

--------------------------------------------------------

-----------------------------
-- retrieve a resource
----------------------------

get :: Author -> Path Text -> Resource -> Maybe Resource

----------------------------------------------------------




