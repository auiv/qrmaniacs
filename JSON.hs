module JSON where

import Text.JSON

import DB0

instance JSON Argomento where
        showJSON (Argomento i x) = makeObj $ [("index",showJSON i),("text",showJSON x)]
instance JSON QuestionarioAutore where
        showJSON (QuestionarioAutore n ds) = makeObj $ [("author",showJSON True),("text",showJSON n),("domande",showJSON ds)]
instance JSON QuestionarioVisitatore where
        showJSON (QuestionarioVisitatore l n ds) = makeObj $ [("author",showJSON l),("text",showJSON n),("domande",showJSON ds)]
instance JSON Risposta where
        showJSON (Risposta i s v) = makeObj $ [("index",showJSON i),("text",showJSON s),("value",showJSON $ show v)]
instance JSON RispostaV where
        showJSON (RispostaV i s v) = makeObj $ [("index",showJSON i),("text",showJSON s),("chosen",showJSON v)]
instance JSON Domanda where
        showJSON (Domanda i s rs) = makeObj $ [("index",showJSON i),("text",showJSON s),("answers", showJSON rs)]
instance JSON DomandaV where
        showJSON (DomandaV i s rs) = makeObj $ [("index",showJSON i),("text",showJSON s),("answers", showJSON rs)]
instance JSON Roles where
        showJSON (Roles i j) = makeObj $ [("author",showJSON i),("validatore",showJSON j)]
