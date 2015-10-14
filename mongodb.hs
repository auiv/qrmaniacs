{-# LANGUAGE OverloadedStrings, ScopedTypeVariables, Rank2Types #-}

import Database.MongoDB

import Graph
import Core
import Serialize
import Data.Time.Clock
import Data.Text

test :: Resource
test = Node
  ( Core 
      (Just "paolino") 
      []
      ["nome" := String "Paolo","cognome" := String "Veronelli"]
  )
  [ ("nascita",
      Node 
        (
        Core Nothing []
        [ "luogo" := String "Milano", 
          "data" =: (read "1970-10-22 18:28:52.607875 UTC"::UTCTime)
        ]
        )
        []
        []
    )
  ]
  
  []
  
main = do  
    pipe <- connect (host "127.0.0.1")
    print (Just test == (cast $ val test :: Maybe Resource))
    return ()

type Access = forall a . Action IO a -> IO a



