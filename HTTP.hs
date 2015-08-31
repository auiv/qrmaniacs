{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Monad
import Control.Monad.Writer
import Data.Char
import System.IO
import Network
import Data.Time.LocalTime
import Protocol
import DB0
import System.Process
import System.Time
import qualified Data.ByteString.UTF8 as BS
import qualified Data.ByteString as BSF
import Text.Read 
import Network.HTTP.Server
import Network.HTTP.Server.Logger
import Network.URL as URL
import Network.URI (URI (..), URIAuth (..),parseURI)
import Text.JSON
import Text.JSON.String(runGetJSON)
import Control.Exception(try,SomeException)
import System.FilePath
import Data.List
import Data.List.Split
import Data.List.Utils
import Control.Concurrent
import System.Process.ByteString as SPBSF
import System.Environment
import JSON
import Mailer
import NiceError
jsError x = makeObj [("error",showJSON $ show x)]
jsDBError x  = makeObj [("dberror",showJSON $ show x)]
jsCompund x y = makeObj [("result",showJSON x)]

sendResponse
  :: JSON a => WGet -> Maybe (Get a) -> IO (Response BS.ByteString)
sendResponse g v = sendResponse' g v (\k -> (id,k))

sendResponse'
  :: JSON b => WGet -> Maybe (Get a) -> (a -> (Response BS.ByteString -> Response BS.ByteString,b)) -> IO (Response BS.ByteString)
sendResponse' g v f = case v of 
        Nothing -> return $ sendJSON BadRequest $ jsError "Not parsed"
        Just v -> do
                let (WGet g') = g
                (x,w) <- runWriterT $ g' v
                case x of 
                        Left x -> return $ sendJSON BadRequest $  jsDBError $ x
                        Right x -> do 
                                        let (t,y) = f x 
                                        return $ t $ sendJSON OK $  jsCompund y w
dotheget ::  WGet -> Maybe (Get a) -> IO (Either DBError a)
dotheget g v = case v of 
        Nothing -> return $ Left $ DatabaseError "Not parsed"
        Just v -> do
                let (WGet g') = g
                (x,_) <- runWriterT $ g' v
                return x

sendResponseP' p v f = case v of 
        Nothing -> return $ sendJSON BadRequest $ jsError $ "Not parsed"
        Just v -> do
                (x,w) <- runWriterT $ p v
                case x of 
                        Left x -> return $ sendJSON BadRequest $ jsDBError $ x
                        Right () -> f >> return (sendJSON OK $ jsCompund JSNull w)

sendResponseP p v = sendResponseP' p v $ return ()

redirectHome :: String -> Response BS.ByteString
redirectHome r = insertHeader HdrLocation r $ (respond SeeOther :: Response BS.ByteString)

logoutAsError = insertHeader HdrSetCookie ""  
main :: IO ()
main = do
        [mailer,pwd,reloc] <- getArgs
        (t,p,g) <- prepare
        let onuser Nothing f = return $ logoutAsError $ sendJSON BadRequest $ jsDBError $ DatabaseError "Unknown user"
            onuser (Just u) f = f u
            responseP = sendResponseP  p
            findUserName x = fmap tail . lookup "userName" . map (break (=='=')) $ splitOn ";" x 
        putStrLn "running"
        let     
                responser url request = do
                          let   URI a (Just (URIAuth _ b _)) _ _ _  = rqURI request
                                href = reloc
                                Just uri = parseURI href
                                Just domain = uriRegName `fmap` uriAuthority  uri
                                path = uriPath uri
                                user = findHeader HdrCookie request >>= findUserName
                          
                          putStr "Request: "
                          getClockTime >>= print
                          print request
                          
                          case rqMethod request of
                            PUT -> do 
                                case splitOn "/" $ url_path url of
                                        ["DeleteArgomento",i] -> onuser user $ \u -> responseP $ do
                                                        return $ DeleteArgomento u i
                                        ["DeleteDomanda",i] -> onuser user $ \u -> responseP $ do
                                                        i' <- readMaybe i
                                                        return $ DeleteDomanda u i'
                                        ["DeleteRisposta",i] -> onuser user $ \u -> responseP $ do
                                                        i' <- readMaybe i
                                                        return $ DeleteRisposta u i'
                                        ["ChangeRispostaValue",i,v] -> onuser user $ \u -> responseP $ do
                                                        i' <- readMaybe i
                                                        v' <- readMaybe v
                                                        return $ ChangeRispostaValue u i' v'

                                        ["RemoveFeedback",i] -> onuser user $ \u -> responseP $ do
                                                        i' <- readMaybe i
                                                        return $ RemoveFeedback u i'
                                        ["AddFeedback",i] -> onuser user $ \u -> responseP $ do
                                                        i' <- readMaybe i
                                                        return $ AddFeedback u i'
                                        ["SetMail",e] -> onuser user $ \u -> do 
                                                        sendResponseP' p (Just  $ SetMail u e) $ sendAMail mailer pwd e reloc  (LoginMail u)
                                        ["Revoke",m] -> onuser user $ \u  -> do        
                                                        responseP (Just $ Revoke u m)
                                        _ -> return $ sendJSON BadRequest $ JSNull

                            POST -> do 
                                let msg = BS.toString $ rqBody request
                                putStrLn "Body:"
                                print $ rqBody request
                                case splitOn "/" $ url_path url of
                                        ["SetBegin"] -> onuser user $ \u -> do 
                                                        putStrLn "------"
                                                        putStrLn msg
                                                        putStrLn $ init.tail$ msg
                                                        responseP  (Just  $ SetBegin u $ msg)
                                        ["SetExpire"] -> onuser user $ \u -> do 
                                                        responseP  (Just  $ SetExpire u $ msg)
                                        ["SetPlace"] -> onuser user $ \u -> do 
                                                       responseP  (Just  $ SetPlace u msg) 
                                        ["SetLogo"] -> onuser user $ \u -> do 
                                                        responseP  (Just  $ SetLogo u msg) 
                                        ["AddArgomento"] -> onuser user $ \u -> responseP $ do
                                                        return $ AddArgomento u msg
                                        ["AddDomanda",i] -> onuser user $ \u -> responseP $ do
                                                        return $ AddDomanda u i msg 
                                        ["ChangeDomanda",i] -> onuser user $ \u -> responseP $ do
                                                        i' <- readMaybe i
                                                        return $ ChangeDomanda u i' msg
                                        ["ChangeArgomento",i] -> onuser user $ \u -> responseP $ do
                                                        return $ ChangeArgomento u i msg
                                        ["ChangeRisposta",i] -> onuser user $ \u -> responseP $ do
                                                        i' <- readMaybe i
                                                        return $ ChangeRisposta u i' msg
                                        ["AddRisposta",i,v] -> onuser user $ \u -> responseP $ do
                                                        i' <- readMaybe i
                                                        v' <- readMaybe v
                                                        return $ AddRisposta u i' v' msg 
                                        _ -> return $ sendJSON BadRequest $ JSNull
                            GET -> do 
                                case splitOn "/" $ url_path url of
                                        ["ArgomentiAutore"] -> onuser user $ \u -> sendResponse g $ do
                                                        return $ ArgomentiAutore u 
                                        ["Login",u] -> do
                                                        responseP (Just $ ConfirmMail u)
                                                        return $ (insertHeader HdrSetCookie ("userName=" ++ u ++ ";Domain="++domain++";Path="++path++";Expires=Tue, 15-Jan-2100 21:47:38 GMT;")) 
                                                                $ redirectHome   reloc                                                   

                                        ["Domande",i] -> onuser user $ \u -> sendResponse g $ do
                                                        return $ Domande u i 
                                        ["DomandeAutore",i] -> onuser user $ \u -> sendResponse g $ do
                                                        return $ DomandeAutore u i 
                                        ["ChangeAssoc",i] -> case user of
                                                                 Just u -> sendResponse' g (Just $ ChangeAssoc u i) (\(UserAndQuestionario u q) -> (insertHeader HdrSetCookie ("userName=" ++ u ++ ";Domain="++domain++";Path="++path++";Expires=Tue, 15-Jan-2100 21:47:38 GMT;"),q))
                                                                 Nothing -> sendResponse' g (Just $ AddAssoc i) (\(UserAndQuestionario u q) ->
                                                                          (insertHeader HdrSetCookie ("userName=" ++ u ++ ";Domain="++domain++";Path="++path++";Expires=Tue, 15-Jan-2100 21:47:38 GMT;"),q))
                                        ["QR","Identify"] -> onuser user $ \u -> do
                                                let url = reloc ++ "/Identify/" ++ u
                                                let c = "qrencode -s 10 -o qr.tmp \""++ url ++ "\""
                                                callCommand c
                                                qr <- BSF.readFile "qr.tmp"
                                                return $ sendPng qr
                                        ["QR","Login"] -> onuser user $ \u -> sendQR $ reloc ++ "/Login/" ++ u
                                        ["QR","AskValidation"]  -> sendQR $ reloc ++ "/AskValidation"
                                        ["QR","AskPromotion"]  -> sendQR $ reloc ++ "/AskPromotion"
                                        ["QR",h] -> sendQR $ reloc ++ "/#/Resource/" ++ h
                                        ["Visitati"] -> onuser user $ \u ->
                                                fmap (insertHeader HdrSetCookie ("userName=" ++ u ++ ";Domain="++domain++";Path="++path++";Expires=Tue, 15-Jan-2100 21:47:38 GMT;")) 
                                                        . sendResponse g $ do
                                                        return $ Visitati u 
                                        ["QR"] -> sendQR reloc
                                        ["Validate",h] -> onuser user $ \u -> do 
                                                  x <- dotheget g $ Just $ Validate u h
                                                  return $ case x of 
                                                    Left y -> insertHeader HdrLocation (reloc ++ "/CantValidate/" ++ niceError y) $ respond SeeOther
                                                    Right _ -> insertHeader HdrLocation (reloc ++ "/#/Validated") $ respond SeeOther
                                        ["Logout"] -> fmap (insertHeader HdrSetCookie ("userName=;Domain="++domain++";Path="++path++";Expires=Tue, 15-Jan-2000 21:47:38 GMT;")) 
                                                        $ return $ sendText OK "Bye!"
                                        ["Role"] -> onuser user $ \u -> sendResponse g $ Just $ Role u
                                        ["AskValidation"] -> onuser user $ \u -> do
                                                x <- dotheget g $ Just (AskValidation u)
                                                case x of 
                                                        Left y -> return $ sendJSON BadRequest $ showJSON y
                                                        Right x -> do
                                                                let url = reloc ++ "/Validate/" ++ x
                                                                let c = "qrencode -s 10 -o qr.tmp \""++ url ++ "\""
                                                                callCommand c
                                                                qr <- BSF.readFile "qr.tmp"
                                                                return $ sendPng qr
                                        ["AskPromotion"] -> onuser user $ \u -> do
                                                x <- dotheget g $ Just (AskValidation u)
                                                case x of 
                                                        Left y -> return $ sendJSON BadRequest $ showJSON y
                                                        Right x -> do
                                                                let url = reloc ++ "/Promote/" ++ x
                                                                let c = "qrencode -s 10 -o qr.tmp \""++ url ++ "\""
                                                                callCommand c
                                                                qr <- BSF.readFile "qr.tmp"
                                                                return $ sendPng qr

                                        ["Validators"] -> onuser user $ \u -> do
                                                sendResponse g (Just $ Validators u)
                                        
                                        ["IsValidate",h] -> onuser user $ \u -> do
                                                sendResponse g (Just $ IsValidate u h)
                                        ["Promote",o] -> onuser user $ \u  -> do        
                                                  x <- dotheget g $ Just $ Promote u o
                                                  return $ case x of 
                                                    Left y -> insertHeader HdrLocation (reloc ++ "/#/CantPromote/" ++ niceError  y) $ respond SeeOther
                                                    Right _ -> insertHeader HdrLocation (reloc ++ "/#/Promoted") $ respond SeeOther
                                        [""] -> do
                                                v <- readFile "static/index.html"
                                                
                                                return $ sendHTML OK $  v
                                        _ -> do print $ url_path url 
                                                return $ sendJSON BadRequest $ JSNull
        serverWith defaultConfig { srvLog = quietLogger, srvPort = 8889 }
                $ \_ url request -> do
                        resp <- responser url request
                        putStr "Response: "
                        getClockTime >>= print
                        print resp
                        putStrLn "Body:"
                        print $ rspBody resp
                        print "--------------------------------------------------"
                        return resp      
sendPng :: BS.ByteString -> Response BS.ByteString
sendPng s = 
                 insertHeader HdrContentEncoding "image/png"
                $ (respond OK :: Response BS.ByteString) { rspBody = s }


sendText s v    = -- insertHeader HdrContentLength (show $ BS.length v' * 2) $
                insertHeader HdrContentEncoding "UTF-8"
                $ insertHeader HdrContentEncoding "text/plain"
                $ (respond s :: Response BS.ByteString) { rspBody = v'}
 where v'= BS.fromString v;

sendJSON s v    = insertHeader HdrContentType "application/json"  
                $ sendText s (showJSValue v "")

sendHTML s v    = insertHeader HdrContentType "text/html"
                $ sendText s v


sendQR url = do
      (_,qr,_) <- SPBSF.readProcessWithExitCode "qrencode" ["-s10","-o-",url] ""
      return $ sendPng qr
