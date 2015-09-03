{-# LANGUAGE OverloadedStrings #-}
module Mailer where 

import Prelude hiding (readFile, putStrLn)
import Control.Monad
import Data.Text.Lazy.IO (readFile,putStrLn)
import Data.Text.Lazy (Text,replace,pack)
import qualified Data.Text as S (pack)
import Network.Mail.Client.Gmail
import Network.Mail.Mime (Address (..))

data Mailer = LoginMail String
type Mail=String

getTemplateMail (LoginMail l) = do
        x <- readFile "invitation.txt"
        let x' = replace "linklogin" (pack l) $ x
        return ("QRManiacs login link",x')

sendAMail :: Mail -> String -> Mail -> Mailer -> IO ()
sendAMail from pwd to ty@(LoginMail link) = do
        let to' = S.pack to
        (t,b) <- getTemplateMail ty
        sendGmailBis (pack from) (pack pwd) (Address (Just "QRManiacs service") $ S.pack $ from ++ "@gmail.com") [Address (Just to') to'] [] [] t b [AProcess "qrencode" ["-m15","-s10", "-o-",link] Nothing "login.png"] 50000000

