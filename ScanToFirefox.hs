
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
                createProcess (shell $ "firefox " ++ l)
                return ()
                
