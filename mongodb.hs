{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

import Database.MongoDB    (Action, Document, Document, Value, access,
                            close, connect, delete, exclude, find,
                            host, insertMany, master, project, rest,insert,
                            select, sort, (=:))
import Control.Monad.Trans (liftIO)
import Web.Spock hiding (delete)

import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as L

import Data.Aeson (decodeStrict,Object,encode)
import Data.Aeson.Bson

spocking e =
    runSpock 3000 $ spockT id $
    do 
    	get ("echo" <//> var) $ \v ->  do
        	text $ T.pack v
        post ("json") $ do
        	Just j <- fmap toBson <$> jsonBody
        	e $ insert "json" j
        	text $ T.pack $ show j
        	


main = do
    pipe <- connect (host "127.0.0.1")
    let e = liftIO . access pipe master "qrmaniacs" 
    spocking e
    close pipe








{-

    
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
