{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE GADTs #-}

module DB0 where 

import Prelude hiding (readFile, putStrLn)
import System.Console.Haskeline hiding (catch)
import Control.Applicative
import Data.String
import Data.Char
import Data.Maybe
import Control.Monad
import Control.Monad.Writer
import Database.SQLite.Simple hiding (Error)
import System.Process
import Database.SQLite.Simple.FromRow
import System.Random
import Data.Typeable
import Control.Exception
import Control.Monad.Error
import Text.Read hiding (lift, get)
import Data.Text.Lazy.IO (readFile,putStrLn)
import Data.Text.Lazy (Text,replace,pack)
import qualified Data.Text as S (pack)
import Network.Mail.Client.Gmail
import Network.Mail.Mime (Address (..))
import Database.SQLite.Simple.FromField
import Database.SQLite.Simple.ToField
import Database.SQLite.Simple.Ok

type Mail = String
type Login = String
type Resource = String
type UserId = Integer
type ConvId = Integer
type MessageId = Integer

data DBError 
	= DatabaseError String
        deriving Show

data Mailer 
        = Reminding Login
        | LogginOut Login
        | Booting Login
        deriving Show
data Event 
        = EvSendMail Mail Mailer String
        | EvNewMessage MessageId
        deriving Show

instance Error DBError where
        strMsg = DatabaseError

type ConnectionMonad = ErrorT DBError (WriterT [Event] IO)

data Env = Env {
        equery :: (ToRow q, FromRow r) => Query -> q -> ConnectionMonad [r],
        eexecute :: ToRow q => Query -> q -> ConnectionMonad (),
        eexecute_ :: Query -> ConnectionMonad (),
        etransaction :: forall a. ConnectionMonad a -> ConnectionMonad a
        }

catchDBException :: IO a -> ConnectionMonad a
catchDBException f = do
        	r <- liftIO $ catch (Right <$> f) (\(e :: SomeException) -> return (Left e)) 
                case r of 
                        Left e -> throwError $ DatabaseError (show e)
                        Right x -> return x
mkEnv :: Connection -> Env
mkEnv conn = Env 
        (\q r -> catchDBException $ query conn q r) 
        (\q r -> catchDBException $ execute conn q r) (\q -> catchDBException $ execute_ conn q) 
        $ 
        \c -> do
                liftIO $ execute_ conn "begin transaction"
                r <- lift $ runErrorT c
                case r of 
                        Left e -> do
                                liftIO $ execute_ conn "rollback"
                                throwError e
                        Right x -> do
                                liftIO $ execute_ conn "commit transaction"
                                return  x

data ParseException = ParseException deriving Show

instance Exception ParseException


-- run :: (Env -> ConnectionMonad a) -> IO (a,[Event])
run f = do        
        conn <- open "store.db"
        r <- runWriterT $ do

                r <- runErrorT $ f (mkEnv conn)
                case r of 
                        Left e -> liftIO $ print e
                        Right x -> liftIO $ print x
        print r
        close conn
        --return r
lastRow :: Env -> ConnectionMonad Integer
lastRow e = do
        r <- equery e "select last_insert_rowid()" ()
        case (r :: [Only Integer]) of 
                [Only x] -> return x
                _ -> throwError $ DatabaseError "last rowid lost"


type User = String

checkAuthor :: Env -> User -> (Integer -> String -> ConnectionMonad a) -> ConnectionMonad a
checkAuthor e u f = do
        liftIO $ print u
        r <- equery e "select autori.id,autori.logo from autori join utenti on autori.id = utenti.id where hash=?" (Only u)
        case (r :: [(Integer,String)]) of
                [(i,l)] -> f i l
                _ -> throwError $ DatabaseError "Unknown Author"
checkAuthorOf e u i f = checkAuthor e u $ \u _ -> do
        r <- equery e "select id from argomenti where autore =? and risorsa = ?" (u,i)
        case (r :: [Only Integer]) of
                [Only i] -> f i
                _ -> throwError $ DatabaseError "Not author"

addArgomento :: Env -> User -> String -> ConnectionMonad ()
addArgomento e u s = checkAuthor e u $ \u _ -> do
        new <- liftIO $ take 50 <$> filter isAlphaNum <$> randomRs ('0','z') <$> newStdGen
        eexecute e "insert into argomenti (argomento,autore,risorsa) values (?,?,?)" $ (s,u,new)
        
--  promoteUser :: Env -> Mail -> User ->

data Argomento = Argomento String String String deriving Show

instance FromRow Argomento where
   fromRow = Argomento <$> field <*> field <*> field

data Argomenti = Argomenti String [Argomento]
listArgomenti :: Env -> User -> ConnectionMonad Argomenti
listArgomenti e u = checkAuthor e u $ \u l -> do 
        as <- equery e "select risorsa,argomento,logo  from argomenti join autori on argomenti.autore = autori.id where autore = ?" (Only u)
        return $ Argomenti l as


changeArgomento ::Env -> User -> String -> String -> ConnectionMonad ()
changeArgomento e u i s = checkAuthorOf e u i $ \i -> eexecute e "update argomenti set argomento = ? where id = ?" (s,i)

deleteArgomento :: Env -> User -> String -> ConnectionMonad ()
deleteArgomento e u i = checkAuthorOf e u i $ \i -> eexecute e "delete from argomenti where id = ?" $ Only i



data Value = Giusta | Sbagliata | Accettabile deriving (Show,Read)

instance FromField Value where
        fromField (fieldData -> SQLText "giusta") = Ok Giusta
        fromField (fieldData -> SQLText "sbagliata") = Ok Sbagliata
        fromField (fieldData -> SQLText "accettabile") = Ok Accettabile
        fromField _ = Errors [SomeException ParseException]
instance ToField Value where
        toField Giusta = SQLText "giusta"
        toField Sbagliata = SQLText "sbagliata"
        toField Accettabile = SQLText "accettabile"

data Risposta = Risposta Integer String Value deriving Show

instance FromRow Risposta where
   fromRow = Risposta <$> field <*> field <*> field 
data RispostaV = RispostaV Integer String Bool

data Domanda = Domanda 
        Integer  --index
        String   --text
        [Risposta] deriving Show
data DomandaV = DomandaV Integer String [RispostaV]

checkRisorsa :: Env -> String -> (Integer -> String -> Integer -> ConnectionMonad a) -> ConnectionMonad a
checkRisorsa e i f = do 
        r <- equery e "select id,argomento,autore from argomenti where risorsa = ?" (Only i)
        case (r :: [(Integer,String,Integer)]) of
                [(i,x,a)] -> f i x a
                _ -> throwError $ DatabaseError $ "Unknown Resource:" ++ i
checkDomanda e u i f = do
        r <- equery e "select argomenti.id from argomenti join domande join utenti on domande.argomento = argomenti.id and  utenti.id = argomenti.autore where hash =? and domande.id = ?" (u,i)
        case (r :: [Only Integer]) of
                [Only i] -> f 
                _ -> throwError $ DatabaseError "Domanda altrui"

checkRisposta e u i f = do
        r <- equery e "select argomenti.id from argomenti join domande join risposte join utenti on domande.argomento = argomenti.id and  risposte.domanda = domande.id  and  utenti.id = argomenti.autore where hash =? and risposte.id = ?" (u,i)
        case (r :: [Only Integer]) of
                [Only i] -> f 
                _ -> throwError $ DatabaseError "Unknown User"

data QuestionarioAutore = QuestionarioAutore
        String --testo titolo
        [Domanda]
        String
data QuestionarioVisitatore =  QuestionarioVisitatore Bool String [DomandaV] String Bool Campagna

data Campagna = Campagna 
        String  -- logo
        String  -- start
        String  --end
        String -- place

instance FromRow Campagna where
   fromRow = Campagna <$> field <*> field <*> field <*> field

setLogo e u l = checkAuthor e u $ \u _ -> do
                eexecute e "update autori set logo=? where id=?" (l,u)
setBegin e u l = checkAuthor e u $ \u _ -> do 
                eexecute e "update autori set begin=? where id=?" (takeWhile (/='"') $ dropWhile (=='"') l,u)
setExpire e u l = checkAuthor e u $ \u _ -> eexecute e "update autori set expire=? where id=?" (takeWhile (/='"') $ dropWhile (=='"') l,u)
setPlace e u l = checkAuthor e u $ \u _ -> eexecute e "update autori set place=? where id=?" (l,u)

listDomandeAutore :: Env -> User -> String -> ConnectionMonad QuestionarioAutore
listDomandeAutore e u i = etransaction e $ listDomandeAutore' e u i 

listDomandeVisitatore :: Env ->  User -> String -> ConnectionMonad QuestionarioVisitatore
listDomandeVisitatore e u i = etransaction e $ listDomandeVisitatore' e u  i False 

listDomandeAutore' e u i = checkAuthorOf e u i $ \i -> do 
                        [(n,lo)] <- equery e "select argomento,logo  from argomenti join autori on autori.id = argomenti.autore where argomenti.id=?" $ Only i
                        ds <- equery e "select id,domanda from domande where argomento = ? " $ Only i
                        fs <- forM ds $ \(i,d) -> do
                                rs <- equery e "select id,risposta,valore from risposte where domanda = ?" $ Only i
                                return $ Domanda i d rs
                        return $ QuestionarioAutore n fs lo
listDomandeVisitatore' e u i nu = checkUtente e u $ \u -> checkRisorsa e i $ \i _ y -> do
                        [(n,lo)] <- equery e "select argomento,logo  from argomenti join autori on autori.id = argomenti.autore where argomenti.id=?" $ Only i
                        ds <- equery e "select id,domanda from domande where argomento = ? " $ Only i
                        fs <- forM ds $ \(i,d) -> do
                                rs <- equery e "select id,risposta from risposte where domanda = ?" $ Only i
                                zs <- equery e "select risposta from feedback where domanda = ? and utente=?" $ (i,u)
                                return $ DomandaV i d $ map (\(i,r) -> RispostaV i r $ i `elem` map fromOnly zs) rs
                        [c] <- equery e "select logo,begin,expire,place from autori where id=?" (Only y)
                        return $ QuestionarioVisitatore (u==y) n fs lo nu c
                        

addDomanda :: Env -> User -> String -> String -> ConnectionMonad ()
addDomanda e u i s = checkAuthorOf e u i $ \i -> eexecute e "insert into domande (domanda,argomento) values (?,?)" (s,i)

deleteDomanda :: Env -> User -> Integer -> ConnectionMonad ()
deleteDomanda e u i = checkDomanda e u i $ eexecute e "delete from domande where id = ?" $ Only i

changeDomanda  :: Env -> User -> Integer  -> String  -> ConnectionMonad ()
changeDomanda e u i s = checkDomanda e u i $ eexecute e "update domande set domanda = ? where id= ? " (s,i)


addRisposta :: Env -> User -> Integer ->  Value -> String -> ConnectionMonad ()
addRisposta e u i v s = checkDomanda e u i $ eexecute e "insert into risposte (risposta,domanda,valore) values (?,?,?)" (s,i,v)

changeRisposta :: Env -> User -> Integer -> String -> ConnectionMonad ()
changeRisposta e u i s = checkRisposta e u i $ eexecute e "update risposte set risposta = ? where id= ? " (s,i)

changeRispostaValue :: Env -> User -> Integer -> Value -> ConnectionMonad ()
changeRispostaValue e u i v = checkRisposta e u i $ eexecute e "update risposte set valore = ? where id= ? " (v,i)

deleteRisposta :: Env -> User -> Integer -> ConnectionMonad ()
deleteRisposta e u i = checkRisposta e u i $ eexecute e "delete from risposte where id= ?" $ Only i

feedbackArgomenti :: Env -> User -> ConnectionMonad [Argomento]
feedbackArgomenti e u = checkUtente e u $ \u -> equery e "select argomenti.risorsa,argomenti.argomento,autori.logo from argomenti join domande join feedback join autori on feedback.domanda = domande.id and domande.argomento = argomenti.id and argomenti.autore = autori.id where feedback.utente = ? group by argomenti.risorsa" (Only u)

feedbackUtente :: Env -> String -> ConnectionMonad [Integer]
feedbackUtente e u =  map fromOnly `fmap` equery e "select risposta from feedback where utente = ?" (Only u)

addFeedback e u r = checkUtente e u $ \u -> etransaction e $ do
                c <- equery e "select risposte.id,domande.id from assoc join domande join risposte on assoc.argomento = domande.argomento and domande.id = risposte.domanda where assoc.utente = ? and risposte.id = ?" (u,r)
                case (c::[(Integer,Integer)]) of 
                        [(r,d)] ->  eexecute e "insert or replace into feedback values (?,?,?)" (u,d,r)
                        _ -> throwError $ DatabaseError $ "User not associated with the QR of this answer"
  
removeFeedback = undefined         
{-             
removeFeedback e u i = checkUtente e u $ \u -> checkRisorsa e i $ \i _ _ -> etransaction e $ do
                c <- equery e "select domande.id from argomenti join domande  on argomento.id = domande.argomento  argomento.id = ?" (Only i)
                case (c::[Only Integer]) of 
                        [Only d] ->  eexecute e "delete from feedback where utente=? and domanda=?" (u,d)
                        _ -> throwError $ DatabaseError $ "User not associated with the QR of this answer"
-}
changeAssoc :: Env -> String -> String -> ConnectionMonad UserAndQuestionario
changeAssoc e u' h = checkUtente' e u' (\u -> checkRisorsa e h $ \i _ _ -> etransaction e $ do 
        eexecute e "delete from assoc where utente = ? " (Only u)
        eexecute e "insert into assoc values (?,?)" (u,i)
        l <- listDomandeVisitatore' e u' h False
        return $ UserAndQuestionario u' l) $ addAssoc e h

data UserAndQuestionario = UserAndQuestionario User QuestionarioVisitatore

addAssoc e h = do
        new <- liftIO $ take 50 <$> filter isAlphaNum <$> randomRs ('0','z') <$> newStdGen
        q <- etransaction e $ do
                eexecute e "insert into utenti (hash,conferma) values (?,0)" (Only new)
                u <- lastRow e 
                checkRisorsa e h $ \i _ _ -> eexecute e "insert into assoc values (?,?)" (u,i)
                listDomandeVisitatore' e new h True
        return $ UserAndQuestionario new q

        
checkUtente' e u f g = do
        r <- equery e "select id from utenti where hash=?" (Only u)
        case (r :: [Only Integer]) of
                [Only i] -> f i
                _ -> g 
checkUtente e u f = checkUtente' e u f $ throwError $ DatabaseError "Unknown Hash for User"

checkAssoc e u d f = do
        r <- equery e "select utenti.id from assoc  join domande join utenti on assoc.utente = utenti.id and assoc.argomento = domande.argomento where utenti.hash = ? and domande.id = ?" (u,d)
        case (r :: [Only Integer]) of
                [Only i] -> f i
                _ -> throwError $ DatabaseError "Unknown user-argument Association"

checkValidation e h f = do
        x <- equery e "select id from utenti where identification = ?" (Only h)
        case x of 
                [Only (u :: Integer)] -> f u
                _ -> throwError $ DatabaseError "Unknown validation"
validateUser e u h = checkUtente e u $ \u -> checkValidation e h $ \h -> do
        liftIO $ print (u,h)
        eexecute e "insert or replace into identificati  (validatore,utente) values (?,?)" (u,h)

checkIdentificatore e u f = checkUtente e u $ \u -> do
        r <- equery e "select id from realizzatori where id=?" (Only u)
        case (r :: [Only Integer]) of
                [Only i] -> f i
                _ -> throwError $ DatabaseError "Unknown Hash for Identifier"

data Roles = Roles Bool (Maybe String) Bool (Maybe Campagna)

role e u = checkUtente e u $ \u -> do
        b1 <- equery e "select id from  autori where id=?" (Only u)
        em  <- equery e "select email,conferma from utenti where id= ?" (Only u)
        let (en,c) = case em of 
                [] -> (Nothing,False)
                [(a,b)] -> (a,b)
        [campagna] <- case b1 of 
                        [Only x] -> if x > 0 then fmap (map Just) $ equery e "select logo,begin,expire,place from autori where id=?" (Only u)
                                else return [Nothing]
                        _ -> return [Nothing]
        return $ Roles (not . null $ (b1 :: [Only Integer])) en c campagna
setMail e u r = checkUtente e u $ \u -> etransaction e $ do
        t <- equery e "select conferma from utenti where id=?" (Only u)
        case t of
                [Only False] -> eexecute e "update utenti set email=? ,conferma=0 where id =?" (r,u)
                _ -> throwError $ DatabaseError "replacing a confirmed email"
confirmMail e u = checkUtente e u $ \u -> eexecute e "update utenti set conferma=1 where id =?" (Only u)

askValidation e u = checkUtente e u $ \u -> do
        new <- liftIO $ take 50 <$> filter isAlphaNum <$> randomRs ('0','z') <$> newStdGen
        eexecute e "update utenti set identification = ? where id=?" (new,u)
        return new
       
validators :: Env -> User -> ConnectionMonad [String]
validators e u = checkAuthor e u $ \u _ -> do
        map fromOnly `fmap` equery e "select email from realizzatori join utenti on realizzatori.utente = utenti.id where autore = ?" (Only u)

promote e u h =  checkAuthor e u $ \u _ -> checkValidation e h $ \h -> do
        r <- equery e "select conferma from utenti where id = ? " (Only h)
        case r of
                [Only False] -> throwError $ DatabaseError "mail non confermata"
                [Only True] ->  eexecute e "insert or replace into realizzatori  (autore,utente) values (?,?)" (u,h)
                _ -> throwError $ DatabaseError "impossible happened"
        
revoke e u m = checkAuthor e u $ \u _ -> do
        eexecute e "delete from realizzatori where autore = ? and utente = (select id from utenti where email = ?)" (u,m)

isValidate e u h = checkUtente e u $ \u -> checkRisorsa e h $ \h _ a -> do
        r <- equery e "select identificati.utente,argomenti.risorsa from realizzatori join identificati join argomenti join autori on autori.id = argomenti.autore and argomenti.autore = realizzatori.autore and realizzatori.utente = identificati.validatore where identificati.utente = ? and argomenti.id= ?  and Datetime('now') > Datetime(autori.begin)" (u,h)
        return (not . null $ (r :: [Only Integer]))

validations :: Env -> User -> Int 
validations = undefined
