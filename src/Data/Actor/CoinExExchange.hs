{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables #-}

module Data.Actor.CoinExExchange (CoinExExchange(..), ping, systemTime) where

import Domain.Actor.Exchange
import Data.Network
import Data.Utils (UnimplementedException(..))

import Control.Exception
import GHC.Generics
import Data.Aeson.Types
import Control.Monad.IO.Class

data CoinExExchange = CoinExExchange { apiKey :: String }

instance Exchange CoinExExchange where
    getBalance exchange = throw UnimplementedException
    getRate exchange fromCurrency toCurrency = throw UnimplementedException
    getMarket exchange fromCurrency toCurrency = throw UnimplementedException
    placeSpotOrder exchange amount toCurrency = throw UnimplementedException

{- @return "pong" as well -}
ping :: forall m. (MonadIO m) => m String
ping = do
    response <- makeRequest RequestParams {
        method = "GET",
        url = "https://api.coinex.com/v2/ping",
        query = [],
        headers = [],
        body = Nothing
    } :: m (StatusResponse Ping)
    return $ result $ payload response

{- @return exchange system time in unix ms -}
systemTime :: forall m. (MonadIO m) => m Integer
systemTime = do
    response <- makeRequest RequestParams {
        method = "GET",
        url = "https://api.coinex.com/v2/time",
        query = [],
        headers = [],
        body = Nothing
    } :: m (StatusResponse SystemTime)
    return $ timestamp $ payload response

-- DTO's --

data Ping = Ping { result :: String } deriving (Show, Generic)

instance FromJSON Ping

data SystemTime = SystemTime {
    timestamp :: Integer -- unix ms
} deriving (Show, Generic)

instance FromJSON SystemTime