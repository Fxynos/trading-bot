{-# LANGUAGE FlexibleContexts #-}

module Main (main) where

import Domain.Entity.State
import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange as CoinExExchange
import Domain.Actor.Logger
import Data.Actor.Logger
import Domain.DI
import Domain.Actor.StateDataSource
import Data.Actor.FileStateDataSource

import Control.Monad.Reader
import System.Environment
import Data.Map as Map

main :: IO ()
main = do
    -- retrieve args --

    rawArgs <- getArgs :: IO [String]
    let args = asMap rawArgs :: Map String String

    let resolvedArgs = combine [
            (Map.lookup "--tick" args),
            (Map.lookup "--gap" args),
            (Map.lookup "--amount" args),
            (Map.lookup "--currency" args)
            ] :: Maybe [String]

    case resolvedArgs of
        Nothing -> showHelp
        Just [tickStr, gapStr, amountStr, currency] -> do
            let tick = read tickStr :: Int
            let gap = read gapStr :: Float
            let amount = read amountStr :: Float

            putStrLn (
                "[Configuration]" ++
                "\nTick (ms): " ++ (show tick) ++
                "\nGap (USDT): " ++ (show gap) ++
                "\nAmount (USDT): " ++ (show amount) ++
                "\nBase currency: " ++ currency ++
                "\nQuote currency: USDT"
                )

            -- restore state --

            let stateSource = FileStateDataSource { filePath = "temp/state.json" }
            hasState <- has stateSource
            state <- case hasState of
                True -> get stateSource
                False -> do
                    return State {
                        baseCurrency = currency,
                        rate = 0.05,
                        balance = []
                    } -- TODO fetch current rate and balance

            putStrLn ((++) "Restored rate: " $ show $ rate state)

            set stateSource state

{- Usage: `runReaderT checkLogger $ DependencyHolder logger` -}
checkLogger :: AppMonad m => m () -- TODO remove after debug
checkLogger = do
    logger <- asks logger
    liftIO $ do
        info logger tag "Start"
        warn logger tag "Sample warning message"
        err logger tag "Sample error message"

exchange :: CoinExExchange
exchange = CoinExExchange {
   accessId = "your-value",
   secretKey = "your-value"
}

-- Utils --

{- Asserts that all the items are present, otherwise returns `Nothing` -}
combine :: [Maybe a] -> Maybe [a]
combine (Nothing : _) = Nothing
combine [] = Just []
combine (Just current : next) = do
    nextCombined <- combine next
    return (current : nextCombined)

{- Parses args list as key-value pairs -}
asMap :: [String] -> Map String String
asMap list =
    let indexed = zip [0 ..] list :: [(Int, String)]
        keys = [key | (index, key) <- indexed, mod index 2 == 0] :: [String]
        values = [value | (index, value) <- indexed, mod index 2 /= 0] :: [String]
        entries = zip keys values :: [(String, String)]
    in fromList entries

showBalance :: [Amount] -> String
showBalance [] = ""
showBalance balance =
    let lines = [(currency amount) ++ ": " ++ (show $ value amount) | amount <- balance]
    in Prelude.foldl (\line1 line2 -> line1 ++ "\n" ++ line2) (head lines) (tail lines)

showHelp :: IO ()
showHelp = putStrLn "Expected arguments:\
\n--tick - invalidation period in ms, e.g. 15000\
\n--gap - cell gap in USDT, e.g. 0.5\
\n--amount - order amount in USDT, e.g. 5.0\
\n--currency - base currency (and quote currency is fixed to USDT)"

-- Constants --

tag :: String
tag = "Main"