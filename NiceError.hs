module NiceError where

import DB0

niceError (DatabaseError "Unknown Author") = "Non sei un autore, non hai una campagna"
niceError x = show x
