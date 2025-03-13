{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables, InstanceSigs, DuplicateRecordFields, FlexibleContexts #-}

module Data.Actor.CoinExExchange (CoinExExchange(..), ping, prepare, signRequest) where

import Domain.DI
import Domain.Actor.Exchange
import Domain.Actor.Logger
import Domain.Entity.Amount
import Data.Network
import Data.Utils (UnimplementedException(..), lazyByteString, fromLazyByteString, fromByteString)

import Control.Exception
import Control.Monad.Reader
import GHC.Generics
import Data.Aeson
import Data.Aeson.Types
import Control.Monad.IO.Class
import Data.Digest.Pure.SHA

data CoinExExchange = CoinExExchange { accessId :: String, secretKey :: String }

instance Exchange CoinExExchange where
    getBalance :: forall m. (MonadIO m, HasDI m) => CoinExExchange -> m [Amount]
    getBalance exchange = do
        request <- signRequest exchange RequestParams {
            method = "GET",
            url = "https://api.coinex.com/v2/assets/spot/balance",
            query = [],
            headers = [],
            body = Nothing :: Maybe Value
        }
        response <- makeRequest request :: m (StatusResponse [AmountDto])
        return $ map amountToDomain (payload response)

    getRate :: forall m. (MonadIO m, HasDI m) => CoinExExchange -> Currency -> Currency -> m Float
    getRate exchange baseCurrency quoteCurrency = do
        request <- signRequest exchange RequestParams {
            method = "GET",
            url = "https://api.coinex.com/v2/spot/ticker",
            query = [("market", baseCurrency ++ quoteCurrency)],
            headers = [],
            body = Nothing :: Maybe Value
        }
        response <- makeRequest request :: m (StatusResponse [RateDto])
        return $ getValue $ head $ payload response

    placeFokOrder :: forall m. (MonadIO m, HasDI m) => CoinExExchange -> Currency -> Currency -> OrderSide -> Float -> Float -> m Bool
    placeFokOrder exchange baseCurrency quoteCurrency side baseCurrencyAmount price = do
        request <- signRequest exchange RequestParams {
            method = "POST",
            url = "https://api.coinex.com/v2/spot/order",
            query = [],
            headers = [],
            body = Just PlaceOrderDto {
               marketType = "SPOT",
               orderType = "fok",
               market = baseCurrency ++ quoteCurrency,
               ccy = Nothing,
               amount = show $ baseCurrencyAmount,
               price = Just (show price),
               side = show side
            }
        }
        response <- makeRequest request :: m (StatusResponse Value)
        logger <- asks logger
        liftIO $ debug logger tag ("Placing FOK order result: (" ++ (show $ code response) ++ ") " ++ (message response))
        return (code response == 0)

    getMarket exchange baseCurrency quoteCurrency = throw UnimplementedException

-- Service requests --

{- @return "pong" as well -}
ping :: forall m. (MonadIO m, HasDI m) => m String
ping = do
    response <- makeRequest RequestParams {
        method = "GET",
        url = "https://api.coinex.com/v2/ping",
        query = [],
        headers = [],
        body = Nothing :: Maybe Value
    } :: m (StatusResponse PingDto)
    return $ result $ payload response

{- @return exchange system time in unix ms -}
systemTime :: forall m. (MonadIO m, HasDI m) => m Integer
systemTime = do
    response <- makeRequest RequestParams {
        method = "GET",
        url = "https://api.coinex.com/v2/time",
        query = [],
        headers = [],
        body = Nothing :: Maybe Value
    } :: m (StatusResponse SystemTimeDto)
    return $ timestamp $ payload response

-- Auth --

{- Replaces [headers] completely. -}
signRequest :: (MonadIO m, HasDI m, ToJSON b) => CoinExExchange -> RequestParams b -> m (RequestParams b)
signRequest exchange params = do
    timestamp <- systemTime
    return RequestParams {
        method = method params,
        url = url params,
        query = query params,
        headers = [
            ("X-COINEX-SIGN", digestHmac256 (secretKey exchange) (prepare timestamp params)),
            ("X-COINEX-KEY", accessId exchange),
            ("X-COINEX-TIMESTAMP", show timestamp),
            ("X-COINEX-WINDOWTIME", show windowTimeMs)
        ],
        body = body params
    }

digestHmac256 :: String -> String -> String
digestHmac256 secret message = showDigest $ hmacSha256 (lazyByteString secret) (lazyByteString message)

prepare :: (ToJSON b) => Integer -> RequestParams b -> String
prepare timestamp params =
    (method params) ++
    (path $ url $ params) ++
    (prepareQuery $ query params) ++
    (prepareBody $ body params) ++
    (show timestamp)

prepareBody :: (ToJSON b) => Maybe b -> String
prepareBody (Just body) = fromLazyByteString $ encode body
prepareBody Nothing = ""

{- @return query starting with `?` if entries are present -}
prepareQuery :: [(String, String)] -> String
prepareQuery [] = ""
prepareQuery query =
    let entries = [key ++ "=" ++ value | (key, value) <- query]
    in '?' : foldl (\entry1 entry2 -> entry1 ++ "&" ++ entry2) (head entries) (tail entries)

{-
    @param url in format `{scheme}://{address}/{path}`, `path` can't be blank, url doesn't contain query params
    @return path
    Note: on next steps of recursion `url` is not valid URL actually.
-}
path :: String -> String
path url
    | Prelude.head url /= '/' = path $ Prelude.tail url
    | Prelude.head url == '/' && url !! 1 == '/' = path $ Prelude.drop 2 url -- if 2 slashes in the row, skip both
    | otherwise = url -- first single slash is reached

-- DTO's --

data PingDto = PingDto { result :: String } deriving (Show, Generic)

instance FromJSON PingDto

data SystemTimeDto = SystemTimeDto {
    timestamp :: Integer -- unix ms
} deriving (Show, Generic)

instance FromJSON SystemTimeDto

data AmountDto = AmountDto {
    available :: String,
    frozen :: String,
    ccy :: String
} deriving (Show, Generic)

instance FromJSON AmountDto

data RateDto = RateDto {
    last :: String
} deriving (Show, Generic)

instance FromJSON RateDto

-- `last` field name interferes with a Prelude function name, so we need the getter
getValue :: RateDto -> Float
getValue (RateDto value) = read value

data PlaceOrderDto = PlaceOrderDto {
    marketType :: String,
    orderType :: String,
    market :: String,
    ccy :: Maybe String, -- related to amount; optional and can be used only with market order type
    amount :: String, -- volume of order
    price :: Maybe String, -- base currency to quote one; required for some order types
    side :: String -- "sell" or "buy"
} deriving (Show, Generic)

instance ToJSON PlaceOrderDto where
    toJSON = genericToJSON defaultOptions {
        fieldLabelModifier = \field ->
            case field of
                "marketType" -> "market_type"
                "orderType" -> "type"
                _ -> field
    }

-- Mappers --

amountToDomain :: AmountDto -> Amount
amountToDomain (AmountDto available _ currency) =
    let value = read $ available :: Float
    in Amount currency value

-- Constants --

tag :: String
tag = "CoinExExchange"

windowTimeMs :: Int
windowTimeMs = 5000