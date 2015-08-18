import System.Process
import System.IO
import Control.Monad
import System.Environment
import Network.HTTP
import Network.Browser

main = do
        args <- getArgs
        let camread =  "cpulimit -l 30 zbarcam --raw --nodisplay"
        (_, Just hout, _, _) <- createProcess (shell camread){ std_out = CreatePipe }
        forever $ do
                l <- hGetLine hout
                putStrLn "\a"
                rsp <- browse $ do
                                        addCookie (MkCookie "qrmaniacs.com" "userName" "LYL85EwHXYX9PYYkTxFOaW6CHy45ndGUeiG447B0v3E5fcd6Sh" Nothing Nothing Nothing)
                                        setAllowRedirects True -- handle HTTP redirects
                                        request $ getRequest l
                print rsp
                
