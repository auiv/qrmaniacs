{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NoMonoLocalBinds #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DataKinds #-}

import Database.MongoDB    (Action, Document, Document, Value, access,
                            close, connect, delete, exclude, find,
                            host, insertMany, master, project, rest,insert,
                            select, sort, (=:))
import Control.Monad.Trans (liftIO, MonadIO)

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TE
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as L
import Data.Monoid

import Data.Aeson (decodeStrict,Object,encode)
import Data.Aeson.Bson
import Snap
import Snap.Extras.JSON
import Control.Applicative



main = do
  
    pipe <- connect (host "127.0.0.1")
    quickHttpServe (site $ access pipe master "json")

site :: (forall a . Action IO a -> IO a) -> Snap ()
site f =
    ifTop (writeBS "hello world") <|>
    route [ ("foo", writeBS "bar")
          , ("echo/:echoparam", echoHandler)
          , ("all",allQR f) 
          , ("insert",insertJSON f)
          ] 

echoHandler :: Snap ()
echoHandler = do
    param <- getParam "echoparam"
    maybe (writeBS "must specify echo/param in URL")
          writeBS param

allQR f = do
  method GET $ do
      t <- fmap (map toAeson) .liftIO $ f $  find (select [] "free") >>= rest
      writeJSON t

insertJSON f = method POST $ do
            j' <- reqJSON
            let Just j = fmap toBson j'
            liftIO $ f  $ insert "free" j
            writeJSON j'

{-
        get ("echo" <//> var) string
        post ("insert") $ do
            Just j <- fmap toBson <$> jsonBody
            liftIO $ pe $ insert "free" j
            string $ show j
        get ("all") $ do
            t <- fmap (map $ fromRight . TE.decodeUtf8' . encode . toAeson) . liftIO $ pe $ find (select [] "free") >>= rest
            text $ mconcat t

    
run :: Action IO ()
run = do
    clearTeams
    insertTeams
    allTeams >>= \ds -> liftIO (mapM_ (L.putStrLn . encode.toAeson) ds) 
    nationalLeagueTeams >>= printDocs "National League Teams"
    newYorkTeams >>= printDocs "New York Teams"

clearTeams :: Action IO ()
clearTeams = delete (select [] "team")

insertTeams :: Action IO [Value]
insertTeams = insertMany "team" [
    ["name" =: "Yankees", "home" =: ["city" =: "New York", "state" =: "NY"], "league" =: "American"],
    ["name" =: "Mets", "home" =: ["city" =: "New York", "state" =: "NY"], "league" =: "National"],
    ["name" =: "Phillies", "home" =: ["city" =: "Philadelphia", "state" =: "PA"], "league" =: "National"],
    ["name" =: "Red Sox", "home" =: ["city" =: "Boston", "state" =: "MA"], "league" =: "American"] ]

allTeams :: Action IO [Document]
allTeams = rest =<< find (select [] "team") {sort = ["home.city" =: 1]}

nationalLeagueTeams :: Action IO [Document]
nationalLeagueTeams = rest =<< find (select ["league" =: "National"] "team")

newYorkTeams :: Action IO [Document]
newYorkTeams = rest =<< find (select ["home.state" =: "NY"] "team") {project = ["name" =: 1, "league" =: 1]}

printDocs :: String -> [Document] -> Action IO ()
printDocs title docs = liftIO $ putStrLn title >> mapM_ (print . exclude ["_id"]) docs
-}
