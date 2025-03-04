module Main (main) where

import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange as CoinExExchange

main :: IO ()
main = do
    pong <- CoinExExchange.ping
    if pong /= "pong" then
        fail "Exchange isn't available"
    else do
        putStrLn "Exchange responded successfully"

        balance <- getBalance exchange
        putStrLn $ "\n[Balance]\n" ++ (showBalance balance)

        rate <- getRate exchange "DNX" "USDT"
        putStrLn $ "\n[Rate]\n" ++ (showBalance [rate])

        success <- placeFokOrder exchange "DNX" "USDT" Buy 87.6 0.08
        putStrLn $ "\nPlace FOK order succeded: " ++ (show success)

exchange :: CoinExExchange
exchange = CoinExExchange {
   accessId = "your-value",
   secretKey = "your-value"
}

showBalance :: [Amount] -> String
showBalance [] = ""
showBalance balance =
    let lines = [(currency amount) ++ ": " ++ (show $ value amount) | amount <- balance]
    in foldl (\line1 line2 -> line1 ++ "\n" ++ line2) (head lines) (tail lines)