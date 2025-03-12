module Presentation.UI (printBalance, printHelp, printConfig, args) where

import Presentation.Config as Config
import Domain.Entity.Amount as Amount

import System.Environment
import Data.Map as Map

-- Views --

printBalance :: [Amount] -> IO ()
printBalance [] = putStrLn "\n[Balance]\nEmpty at all.\n"
printBalance balance = do
    let lines = [(Amount.currency amount) ++ ": " ++ (show $ value amount) | amount <- balance]
    let balance = Prelude.foldl (\line1 line2 -> line1 ++ "\n" ++ line2) (head lines) (tail lines)
    putStrLn balance

printHelp :: IO ()
printHelp = putStrLn "\n[Help]\
    \\nExpected arguments:\
    \\n--tick - invalidation period in ms, e.g. 15000\
    \\n--gap - cell gap in quote currency, e.g. 0.5\
    \\n--amount - order amount in base currency, e.g. 5.0\
    \\n--base - base currency, e.g. DNX\
    \\n--quote - quote currency, e.g. USDT\
    \\n--id - CoinEx access id\
    \\n--key - CoinEx secret key\
    \\n\
    \\nUsage: --tick 15000 --gap 2.5 --amount 7.5 --currency DNX --id 0123456789ABCDEF --key 0123456789ABCDEF"

printConfig :: Config -> IO ()
printConfig config = putStrLn (
    "\n[Configuration]" ++
    "\nTick (ms): " ++ (show $ tick config) ++
    "\nGap (quote currency): " ++ (show $ gap config) ++
    "\nOrder amount (base currency): " ++ (show $ amount config) ++
    "\nBase currency: " ++ (baseCurrency config) ++
    "\nQuote currency: " ++ (quoteCurrency config) ++
    "\nCoinEx access id: " ++ (mask $ accessId config) ++
    "\nCoinEx secret key: " ++ (mask $ secretKey config) ++ "\n"
    )

-- Input --

args :: IO (Maybe Config)
args = do
    rawArgs <- getArgs :: IO [String]
    let args = asMap rawArgs :: Map String String
    let resolvedArgs = combine [
            (Map.lookup "--tick" args),
            (Map.lookup "--gap" args),
            (Map.lookup "--amount" args),
            (Map.lookup "--base" args),
            (Map.lookup "--quote" args),
            (Map.lookup "--id" args),
            (Map.lookup "--key" args)
            ] :: Maybe [String]

    return $ case resolvedArgs of
        Nothing ->
            Nothing
        Just [tickStr, gapStr, amountStr, baseCurrency, quoteCurrency, accessId, secretKey] ->
            Just Config {
                tick = read tickStr,
                gap = read gapStr,
                amount = read amountStr,
                baseCurrency = baseCurrency,
                quoteCurrency = quoteCurrency,
                accessId = accessId,
                secretKey = secretKey
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

mask :: String -> String
mask s = Prelude.take (Prelude.length s) (repeat '*')