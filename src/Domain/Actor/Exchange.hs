module Domain.Actor.Exchange (Exchange(..)) where

import Domain.Entity.Currency
import Domain.Entity.Amount
import Domain.Entity.Market

import Control.Monad.IO.Class

class Exchange e where
    getBalance :: (MonadIO m) => e -> m [Amount]
    getRate :: (MonadIO m) => e -> Currency -> Currency -> m Amount
    getMarket :: e -> Currency -> Currency -> Market
    placeSpotOrder :: e -> Amount -> Currency -> Amount