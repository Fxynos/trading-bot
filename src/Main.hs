{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange as CoinExExchange

import Data.Network

main :: IO ()
main = do
    pong <- CoinExExchange.ping
    if pong /= "pong" then
        fail "Exchange isn't available"
    else do
        print "Exchange responded successfully"
        print $ prepare 123 (RequestParams {
            method = "GET",
            url = "https://api.coinex.com/v2/time",
            query = [("ticker", "USD")],
            headers = [],
            body = Nothing
        })
