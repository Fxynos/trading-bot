module Main (main) where

import Control.Exception

main :: IO ()
main = print balance
    where
        exchange = Exchange { apiKey = "some-api-key" } -- TODO
        balance = value (head $ getBalance exchange)

-- Actors --

data Exchange = Exchange {
    apiKey :: String
}

getBalance :: Exchange -> [Amount]
getBalance exchange = throw UnimplementedException

getRate :: Exchange -> Currency -> Currency -> Amount
getRate exchange fromCurrency toCurrency = throw UnimplementedException

getMarket :: Exchange -> Currency -> Currency -> Market
getMarket exchange fromCurrency toCurrency = throw UnimplementedException

placeSpotOrder :: Exchange -> Amount -> Currency -> Amount
placeSpotOrder exchange amount toCurrency = throw UnimplementedException

data Bot = Bot {
    exchange :: Exchange
}

onCreate :: Bot -> State -> ()
onCreate bot savedState = throw UnimplementedException

invalidate :: Bot -> ()
invalidate bot = throw UnimplementedException

finish :: Bot -> State
finish bot = throw UnimplementedException

data StateDataSource {
    filePath :: String
}

get :: StateDataSource -> State
get dataSource = throw UnimplementedException

set :: StateDataSource -> State -> ()
set dataSource state = throw UnimplementedException

-- Entities --

data State = State {
    rate: Amount,
    balance: [Amount]
}

data Market = Market {
    makerFee :: Float,
    takerFee :: Float,
    minAmount :: Amount
}

data Amount = Amount {
    currency :: Currency,
    value :: Float
}

data Currency = Currency {
    ticker :: String,
    name :: String
}

-- Shared --

data UnimplementedException = UnimplementedException deriving Show
instance Exception UnimplementedException