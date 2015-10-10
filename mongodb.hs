{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NoMonoLocalBinds #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE MultiParamTypeClasses #-}

import Database.MongoDB    (Action, Document, Document, Value, access,
                            close, connect, delete, exclude, find,
                            host, findAndModify, insertMany, master, project, rest,insert,allCollections,Collection,upsert, Selection(..), Query(..),
                            select, (=:))
import Control.Monad.Trans (liftIO, MonadIO)
import Control.Monad.Trans.Control (MonadBaseControl)
import qualified Data.List as Li 
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TEL
import qualified Data.Text.Encoding as TE
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as C
import qualified Data.ByteString.Lazy as L
import Data.Monoid
import Data.Bson (merge ,Field( (:=)), Value(String, ObjId, Bin), Binary (..))
import Control.Monad.Reader
import Data.Aeson (decodeStrict,Object,encode)
import Data.Aeson.Bson
import Snap
import Snap.Extras.JSON
import Control.Applicative
import Crypto.Hash (Digest, SHA512,hash)
import Control.Arrow (second)
import Data.Time.Clock

-- import Control.Lens.TH
-- import Control.Lens

data Context = Context {
  user :: Maybe User
  } deriving (Show)

freeContext = Context Nothing 
type NSnap = ReaderT Context Snap
type User=T.Text
type Coll=T.Text

main = do  
    pipe <- connect (host "127.0.0.1")
    quickHttpServe (flip runReaderT freeContext $ site $ access pipe master "json")


type Access = forall a . Action IO a -> IO a


objectRoute = "object/:coll/:id"
fileRoute = "file/:coll/:id"
collectionRoute = "collection/:coll"
ided = flip C.append "/:id"

site :: Access -> NSnap ()
site f = do 
    user <- getCookie "user" 
    local (const $ Context (fmap (TE.decodeUtf8 . cookieValue) user) ) $ 
      ifTop greatings <|>
        route  [
            ("collections",method GET $ getCollections f) 
            -- only master can operate these
            , (collectionRoute `C.append` "/:owner", method POST $ postCollection f) --change owner or new
            , (collectionRoute, method DELETE $ deleteCollection f) -- delete by name
            -- only owner can operate these, must be 
            , (fileRoute,method GET $ getFile f) -- anyone can read a configuration file of a collection 
            , (fileRoute,method POST $ postFile f) -- only owner of collection can operate configuration files
            , (objectRoute,method GET $ getJSON f) -- anyone can read an object 
            , (objectRoute,method POST $ postJSON f) -- only author can change contents
            , (,method PUT $ postJSON f) -- only author can change contents
            , ("login/:user",login)
            ]

greatings = ask >>= \c -> writeBS ("hello " `C.append` C.pack (show c))

 
onuser f = ask >>= notmiss where
  notmiss (Context Nothing) = mzero
  notmiss (Context (Just user)) = f user $ String . T.pack . (\bs -> show (hash bs :: Digest SHA512)) . TE.encodeUtf8 $ user

{-
notBinary (a := Bin _) = False
notBinary _ = True

allObjects :: Access -> NSnap ()
allObjects access = method GET $ do 

        name <- getParam "coll" 
        flip (maybe mzero) name $ \name -> do
          t <-  liftIO . access $ find (select [] $ string name) >>= rest
          writeJSON $ map (filter notBinary) t

allMyObjects :: Access -> NSnap ()
allMyObjects access = method GET . onuser $ \user h -> oncoll $ \coll -> do 
        t <- fmap (map toAeson) .  liftIO . access $ find (select ["user":= h] coll) >>= rest
        writeJSON t
-}

insertJSON :: Access -> NSnap ()
insertJSON access = method POST . onuser $ \user h -> oncoll $ \coll -> do
            j' <-  reqJSON
            case fmap toBson j' of
                Nothing -> mzero
                Just j -> do 
                    liftIO . access  $ insert coll j
                    writeJSON j'
allColl :: Access -> NSnap ()
allColl access = method GET $  do 
        r <- getRequest
        liftIO $ print r
        t <- liftIO $ access $ allCollections
        writeJSON t


getParamFail n f = getParam n >>= maybe mzero f 

collectionMetadata :: Access -> NSnap ()
collectionMetadata access = method GET $ getParamFail "coll" $ \coll -> getParamFail "id" $ \id -> do
  
        liftIO $ print (coll,id)
        t <- liftIO $ access $ find (select ["_id":= ObjId (read $ C.unpack id)] $ string coll ) >>= rest
        writeJSON t

fileAt :: Access -> NSnap ()
fileAt access = method GET $ getParamFail "coll" $ \coll -> getParamFail "id" $ \id -> do
        let s = (select ["_id":= ObjId (read $ C.unpack id), "type" =: "file"] $ string coll )
                    {project=["body" =: 1, "_id" =: 0, "contentType" =:1, "name" =: 1]}
        [["body":= Bin (Binary t), "contentType":= String w, "name":= String n]]  <- fmap (map Li.sort) $ liftIO $ access $ find s  >>= rest
        modifyResponse (setContentType $ TE.encodeUtf8 $ w)
        modifyResponse (setHeader "Content-Disposition" ("filename=ciao"))
        writeBS t
        



login :: NSnap ()
login = method GET $ getParamFail "user" $ \user -> do
        t <- liftIO getCurrentTime
        let years = 100 * 365 * 24 * 60 * 60
        modifyResponse (addResponseCookie (Cookie "user" user (Just $ years `addUTCTime` t) (Just "localhost") (Just "/") False False))
        redirect "/"

class ToValue a b where
    string :: a -> b

instance ToValue L.ByteString Value where
  string = String  . TL.toStrict . TEL.decodeUtf8 

instance ToValue C.ByteString Value where
  string = String  . TE.decodeUtf8 

instance ToValue C.ByteString T.Text where
  string = TE.decodeUtf8

replaceFile access = method POST $  
  onuser $ \user h -> 
    getParamFail "coll" $ \coll ->
      getParamFail "name" $ \name -> do
        getParamFail "type1" $ \type1 -> do
          getParamFail "type2" $ \type2 -> do
            b <- readRequestBody 10000000
            let contentType = type1 `C.append` "/" `C.append` type2
                sel = ["type" =: "file","name" := string name, "author" := h ]
                mod = ["body" := Bin (Binary $ L.toStrict b), "contentType" := string contentType]
            r <- liftIO . access  $ findAndModify (select sel $ string coll) $ sel ++ mod 
            case r of
              Right r -> writeJSON r
              _ -> mzero
          

