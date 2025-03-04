{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables #-}

module Data.Actor.CoinExExchange (CoinExExchange(..), ping) where

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

data Ping = Ping { result :: String } deriving (Show, Generic)

instance FromJSON Ping
