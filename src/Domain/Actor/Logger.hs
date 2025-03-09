module Domain.Actor.Logger (Logger(..), Level(..)) where

class Logger this where
    -- abstract --
    trace :: this -> String -> Level -> String -> IO ()

    -- default impl --
    debug, info, warn, err :: this -> String -> String -> IO ()

    debug this tag message = trace this tag DEBUG message
    info this tag message = trace this tag INFO message
    warn this tag message = trace this tag WARNING message
    err this tag message = trace this tag ERROR message

data Level = DEBUG | INFO | WARNING | ERROR deriving Show