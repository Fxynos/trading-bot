{-# LANGUAGE FlexibleContexts #-}

module Domain.Actor.Exchange (Exchange(..), OrderSide(..)) where

import Domain.Entity.Amount
import Domain.Entity.Market
import Domain.DI

import Control.Monad.IO.Class

class Exchange e where
    getBalance :: (MonadIO m, HasDI m) => e -> m [Amount]
    getRate :: (MonadIO m, HasDI m) => e -> Currency -> Currency -> m Float
    getMarket :: (MonadIO m, HasDI m) => e -> Currency -> Currency -> m Market
    placeFokOrder :: (MonadIO m, HasDI m) => e -> Currency -> Currency -> OrderSide -> Float -> Float -> m Bool

data OrderSide = Buy | Sell

instance Show OrderSide where
    show Buy = "buy"
    show Sell = "sell"