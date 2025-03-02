{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main (main) where

import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange

import Data.Network

import GHC.Generics
import Data.Aeson.Types
import Network.HTTP.Simple

main :: IO ()
main = do
    response <- makeRequest RequestParams {
       method = "GET",
       url = "https://api.coinex.com/v2/ping",
       query = [],
       headers = [],
       body = Nothing
    } :: IO (Response StatusResponse)
    print $ getResponseBody response

data StatusResponse = StatusResponse {
    code :: Int,
    message :: String
} deriving (Show, Generic)

instance FromJSON StatusResponse