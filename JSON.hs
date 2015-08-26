module JSON where

import Text.JSON

import DB0
instance JSON DBError where
        showJSON (DatabaseError x) = showJSON x
instance JSON Argomenti where
        showJSON (Argomenti lo as) = makeObj $ [("logo",showJSON lo),("argomenti",showJSON as)]

instance JSON Argomento where
        showJSON (Argomento i x lo) = makeObj $ [("index",showJSON i),("text",showJSON x),("logo",showJSON lo)]
instance JSON QuestionarioAutore where
        showJSON (QuestionarioAutore n ds lo) = makeObj $ [("author",showJSON True),("text",showJSON n),("domande",showJSON ds),("logo",showJSON lo)]
instance JSON QuestionarioVisitatore where
        showJSON (QuestionarioVisitatore l n ds lo nu a) = makeObj $ [("campagna",showJSON a),("author",showJSON l),("text",showJSON n),("domande",showJSON ds),("logo",showJSON lo),
                ("nuovo",showJSON nu)]
instance JSON Campagna where
        showJSON (Campagna lo be ex pl) = makeObj $ [("logo",showJSON lo),("begin",showJSON be),("expire",showJSON ex),("place",showJSON pl)]
instance JSON Risposta where
        showJSON (Risposta i s v) = makeObj $ [("index",showJSON i),("text",showJSON s),("value",showJSON $ show v)]
instance JSON RispostaV where
        showJSON (RispostaV i s v) = makeObj $ [("index",showJSON i),("text",showJSON s),("chosen",showJSON v)]
instance JSON Domanda where
        showJSON (Domanda i s rs) = makeObj $ [("index",showJSON i),("text",showJSON s),("answers", showJSON rs)]
instance JSON DomandaV where
        showJSON (DomandaV i s rs) = makeObj $ [("index",showJSON i),("text",showJSON s),("answers", showJSON rs)]
instance JSON Roles where
        showJSON (Roles i e c campagna) = makeObj $ [
                ("author",showJSON i),
                ("email",maybe (showJSON JSNull) showJSON e),
                ("conferma",showJSON c),
                ("campagna",maybe (showJSON JSNull) showJSON campagna)]
