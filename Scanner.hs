
{-# LANGUAGE OverloadedStrings #-}
import Data.Time.Clock
import Data.Time.Calendar
import qualified Control.Exception as E
import Network.HTTP.Types.Status (statusCode)
import Network.Connection (TLSSettings (..))
import Network.HTTP.Conduit
import System.Process
import System.IO
import Control.Monad
import System.Environment

key = "lwmb4vxUxv2iScU9q51mbqaVNziQmOpypPArqnHHHLrR58kYtN"
cookie :: Cookie
cookie = Cookie { cookie_name = "userName"
                 , cookie_value = key
                 , cookie_expiry_time = future
                 , cookie_domain = "192.168.1.119"
                 , cookie_path = "/qrmaniacs"
                 , cookie_creation_time = past
                 , cookie_last_access_time = past
                 , cookie_persistent = False
                 , cookie_host_only = False
                 , cookie_secure_only = False
                 , cookie_http_only = False
                 }

past :: UTCTime
past = UTCTime (ModifiedJulianDay 56200) (secondsToDiffTime 0)

future :: UTCTime
future = UTCTime (ModifiedJulianDay 1562000) (secondsToDiffTime 0)




main = do
        args <- getArgs
        let camread =  "cpulimit -l 30 zbarcam --raw --nodisplay"
        (_, Just hout, _, _) <- createProcess (shell camread){ std_out = CreatePipe }
        manager <- newManager tlsManagerSettings
        forever $ do
                l <- hGetLine hout
                request' <- parseUrl l
                let request = request' { cookieJar = Just $ createCookieJar [cookie] }
                (fmap Just (httpLbs request manager)) `E.catch`
                        (\(StatusCodeException s _ _) -> print s >> return Nothing)
