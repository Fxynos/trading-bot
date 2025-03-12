{-# LANGUAGE ExistentialQuantification #-}

module Data.Actor.Logger (CompositeLogger(..), CompositeLoggerItem(..), FileLogger(..), TerminalLogger(..)) where

import Domain.Actor.Logger

import Data.Time

-- Composite Logger --

data CompositeLogger = CompositeLogger [CompositeLoggerItem]

instance Logger CompositeLogger where
    -- `mapM_` ignores resulting `[(), ...]`, i.e. just causes side effects
    trace (CompositeLogger loggers) tag level message =
        mapM_ (\(CompositeLoggerItem l) -> trace l tag level message) loggers

-- workaround to hide type param at constructor level in order to use list of different instances in CompositeLogger
data CompositeLoggerItem = forall l. Logger l => CompositeLoggerItem l

-- File logger --

data FileLogger = FileLogger String

instance Logger FileLogger where
    trace (FileLogger filePath) tag level message = do
        timestamp <- currentTimestamp
        appendFile filePath $ (++) (formatRecord timestamp tag level message) "\n"

-- Terminal Logger --

data TerminalLogger = TerminalLogger

instance Logger TerminalLogger where
    trace TerminalLogger tag level message = do
        timestamp <- currentTimestamp
        putStrLn $ formatRecord timestamp tag level message

-- Utils --

formatRecord :: String -> String -> Level -> String -> String
formatRecord timestamp tag level message =
    (fillLengthUpTo 20 timestamp) ++ " " ++
    (fillLengthUpTo 8 $ show level) ++ " " ++
    (fillLengthUpTo 20 ("[" ++ tag ++ "]")) ++ " " ++
    message

fillLengthUpTo :: Int -> String -> String
fillLengthUpTo len s
    | length s < len = (++) s $ take remainingLen $ repeat ' '
    | otherwise = take (len - 3) s ++ "..."
    where remainingLen = len - (length s)

currentTimestamp :: IO String
currentTimestamp = do
    time <- getCurrentTime
    return $ formatTime defaultTimeLocale "%Y.%m.%d %H:%M:%S" time