module Domain.Actor.Exchange (Exchange(..)) where

import Domain.Entity.Currency
import Domain.Entity.Amount
import Domain.Entity.Market

import Control.Monad.IO.Class

class Exchange e where
    getBalance :: (MonadIO m) => e -> m [Amount]
    getRate :: e -> Currency -> Currency -> Amount
    getMarket :: e -> Currency -> Currency -> Market
    placeSpotOrder :: e -> Amount -> Currency -> Amount