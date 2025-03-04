module Main (main) where

import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange as CoinExExchange

main :: IO ()
main = do
    pong <- CoinExExchange.ping
    putStrLn $ "/ping: " ++ pong
    timestamp <- CoinExExchange.systemTime
    putStrLn $ "/time: " ++ (show timestamp)
