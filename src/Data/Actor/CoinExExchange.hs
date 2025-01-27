module Data.Actor.CoinExExchange (CoinExExchange(..)) where

import Domain.Actor.Exchange
import Control.Exception
import Data.Utils (UnimplementedException(..))

data CoinExExchange = CoinExExchange { apiKey :: String }

instance Exchange CoinExExchange where
    getBalance exchange = throw UnimplementedException
    getRate exchange fromCurrency toCurrency = throw UnimplementedException
    getMarket exchange fromCurrency toCurrency = throw UnimplementedException
    placeSpotOrder exchange amount toCurrency = throw UnimplementedException