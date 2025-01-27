module Main (main) where

import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange

main :: IO ()
main = print balance
    where
        exchange = CoinExExchange { apiKey = "some-api-key" } -- TODO
        balance = value (head $ getBalance exchange)