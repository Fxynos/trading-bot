module Domain.Actor.Exchange (Exchange(..), OrderSide(..)) where

import Domain.Entity.Currency
import Domain.Entity.Amount
import Domain.Entity.Market

import Control.Monad.IO.Class

-- TODO use IO directly
class Exchange e where
    getBalance :: (MonadIO m) => e -> m [Amount]
    getRate :: (MonadIO m) => e -> Currency -> Currency -> m Float
    getMarket :: (MonadIO m) => e -> Currency -> Currency -> m Market
    placeFokOrder :: (MonadIO m) => e -> Currency -> Currency -> OrderSide -> Float -> Float -> m Bool

data OrderSide = Buy | Sell

instance Show OrderSide where
    show Buy = "buy"
    show Sell = "sell"