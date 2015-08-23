module JSON where

import Text.JSON

import DB0

instance JSON Argomenti where
        showJSON (Argomenti lo as) = makeObj $ [("logo",showJSON lo),("argomenti",showJSON as)]

instance JSON Argomento where
        showJSON (Argomento i x lo) = makeObj $ [("index",showJSON i),("text",showJSON x),("logo",showJSON lo)]
instance JSON QuestionarioAutore where
        showJSON (QuestionarioAutore n ds lo) = makeObj $ [("author",showJSON True),("text",showJSON n),("domande",showJSON ds),("logo",showJSON lo)]
instance JSON QuestionarioVisitatore where
        showJSON (QuestionarioVisitatore l n ds lo) = makeObj $ [("author",showJSON l),("text",showJSON n),("domande",showJSON ds),("logo",showJSON lo)]
instance JSON Risposta where
        showJSON (Risposta i s v) = makeObj $ [("index",showJSON i),("text",showJSON s),("value",showJSON $ show v)]
instance JSON RispostaV where
        showJSON (RispostaV i s v) = makeObj $ [("index",showJSON i),("text",showJSON s),("chosen",showJSON v)]
instance JSON Domanda where
        showJSON (Domanda i s rs) = makeObj $ [("index",showJSON i),("text",showJSON s),("answers", showJSON rs)]
instance JSON DomandaV where
        showJSON (DomandaV i s rs) = makeObj $ [("index",showJSON i),("text",showJSON s),("answers", showJSON rs)]
instance JSON Roles where
        showJSON (Roles i j Nothing c) = makeObj $ [("author",showJSON i),("validatore",showJSON j),("email",showJSON JSNull),("conferma",showJSON c)]
        showJSON (Roles i j (Just e) c) = makeObj $ [("author",showJSON i),("validatore",showJSON j),("email",showJSON e),("conferma",showJSON c)]
