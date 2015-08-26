{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE StandaloneDeriving #-}

module Protocol where

import System.Console.Haskeline hiding (catch)
import Control.Applicative
import Data.String
import Control.Monad
import Control.Monad.Writer
import Database.SQLite.Simple
import System.Process
import Database.SQLite.Simple.FromRow
import System.Random
import Data.Typeable
import Control.Exception
import Control.Monad.Error
import Text.Read hiding (lift, get)
import System.Directory

import DB0

data Put
        = AddArgomento User String	
        | DeleteArgomento User String	
        | ChangeDomanda User Integer String
        | ChangeArgomento User String String
        | AddDomanda User String String
        | DeleteDomanda User Integer
        | AddRisposta User Integer Value String
        | ChangeRisposta User Integer String
        | ChangeRispostaValue User Integer Value
        | DeleteRisposta User Integer
        | AddFeedback User Integer
        | RemoveFeedback User Integer
        | SetMail User String
        | SetLogo User String
        | SetBegin User String
        | SetExpire User String
        | SetPlace User String
        | ConfirmMail User
        deriving Read

put' :: Env -> Put -> ConnectionMonad ()
put' e (AddArgomento u s) = addArgomento e u s
put' e (DeleteArgomento u s) = deleteArgomento e u s
put' e (AddDomanda u i s) = addDomanda e u i s
put' e (DeleteDomanda u i) = deleteDomanda e u i
put' e (DeleteRisposta u i) = deleteRisposta e u i
put' e (AddRisposta u i v s) = addRisposta e u i v s
put' e (ChangeDomanda u i s) = changeDomanda e u i s
put' e (ChangeArgomento u i s) = changeArgomento e u i s
put' e (ChangeRisposta u i s) = changeRisposta e u i s
put' e (ChangeRispostaValue u i v) = changeRispostaValue e u i v
put' e (AddFeedback u r)= addFeedback e u r
put' e (RemoveFeedback u r)= removeFeedback e u r
put' e (SetMail u r)= setMail e u r
put' e (SetLogo u r)= setLogo e u r
put' e (SetBegin u r)= setBegin e u r
put' e (SetExpire u r)= setExpire e u r
put' e (SetPlace u r)= setPlace e u r
put' e (ConfirmMail u)= confirmMail e u
      
put :: Env -> Put -> WriterT [Event] IO (Either DBError ())
put e l = runErrorT (put' e l)
   
data Get a where
        ArgomentiAutore :: User -> Get Argomenti
        Domande :: User -> String -> Get QuestionarioVisitatore
        DomandeAutore :: User -> String -> Get QuestionarioAutore
        Feedback :: User -> Get [Integer]
        Visitati :: User -> Get [Argomento]
        AddAssoc :: String -> Get UserAndQuestionario
        ChangeAssoc :: User -> String -> Get UserAndQuestionario
        Validate :: User -> User -> Get ()
        Role :: User  -> Get Roles
        AskValidation :: User -> Get String
        
get'  :: Env -> Get a -> ConnectionMonad a
get' e (ArgomentiAutore u) = listArgomenti e u 
get' e (Domande u i) = listDomandeVisitatore e u i
get' e (DomandeAutore u i) = listDomandeAutore e u i
get' e (Visitati u) = feedbackArgomenti e u
get' e (Feedback u) = feedbackUtente e u
get' e (AddAssoc i) = addAssoc e i
get' e (ChangeAssoc u i) = changeAssoc e u i
get' e (Validate u h) = validateUser e u h
get' e (Role u ) = role e u 
get' e (AskValidation u ) = askValidation e u


get :: Env -> Get a -> WriterT [Event] IO (Either DBError a)
get e l = runErrorT (get' e l)

clean = callCommand "cat schema.sql | sqlite3 store.db"

data WGet  = WGet (forall a. Get a ->  WriterT [Event] IO (Either DBError a))

prepare :: IO (Bool,Put -> WriterT [Event] IO (Either DBError ()),WGet)
prepare = do         
        b <- doesFileExist "store.db"
        when (not b) clean
        conn <- open "store.db"
        execute_ conn "PRAGMA foreign_keys = ON"
        let     p = put (mkEnv conn)
                g = WGet (get (mkEnv conn))
        return (not b,p,g)
