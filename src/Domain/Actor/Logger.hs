module Domain.Actor.Logger (Logger(..), Level(..)) where

class Logger this where
    -- abstract --
    trace :: this -> String -> Level -> String -> IO ()

    -- default impl --
    info, warn, err :: this -> String -> String -> IO ()

    info this tag message = trace this tag INFO message
    warn this tag message = trace this tag WARNING message
    err this tag message = trace this tag ERROR message

data Level = INFO | WARNING | ERROR deriving Show