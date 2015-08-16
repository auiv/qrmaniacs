module JSON where

import Text.JSON

import DB0

instance JSON Argomento where
        showJSON (Argomento i x) = makeObj $ [("index",showJSON i),("text",showJSON x)]
instance JSON Questionario where
        showJSON (Questionario n ds) = makeObj $ [("text",showJSON n),("domande",showJSON ds)]
instance JSON Risposta where
        showJSON (Risposta i s v) = makeObj $ [("index",showJSON i),("text",showJSON s),("value",showJSON $ show v)]
instance JSON Domanda where
        showJSON (Domanda i s rs) = makeObj $ [("index",showJSON i),("text",showJSON s),("answers", showJSON rs)]
