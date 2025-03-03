module Main (main) where

import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange

main :: IO ()
main = do
    result <- ping CoinExExchange { apiKey = "some-api-key" }
    print result
