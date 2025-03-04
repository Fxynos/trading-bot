module Main (main) where

import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange as CoinExExchange

main :: IO ()
main = do
    result <- CoinExExchange.ping
    print result
