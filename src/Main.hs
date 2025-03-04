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
        balance <- getBalance CoinExExchange {
            accessId = "your-value",
            secretKey = "your-value"
        }
        putStrLn $ showBalance balance

showBalance :: [Amount] -> String
showBalance [] = ""
showBalance balance =
    let lines = [(currency amount) ++ ": " ++ (show $ value amount) | amount <- balance]
    in foldl (\line1 line2 -> line1 ++ "\n" ++ line2) (head lines) (tail lines)