module Domain.Entity.Currency (Currency(..)) where

data Currency = Currency {
    ticker :: String,
    name :: String
}