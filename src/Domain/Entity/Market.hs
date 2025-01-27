module Domain.Entity.Market (Market(..)) where

import Domain.Entity.Amount

data Market = Market {
    makerFee :: Float,
    takerFee :: Float,
    minAmount :: Amount
}