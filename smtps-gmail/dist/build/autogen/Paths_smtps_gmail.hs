module Paths_smtps_gmail (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [1,3,1] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/paolino/.cabal/bin"
libdir     = "/home/paolino/.cabal/lib/x86_64-linux-ghc-7.10.1/smtps_DgYah7OYOVzC6Iw7fA9JX1"
datadir    = "/home/paolino/.cabal/share/x86_64-linux-ghc-7.10.1/smtps-gmail-1.3.1"
libexecdir = "/home/paolino/.cabal/libexec"
sysconfdir = "/home/paolino/.cabal/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "smtps_gmail_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "smtps_gmail_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "smtps_gmail_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "smtps_gmail_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "smtps_gmail_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
