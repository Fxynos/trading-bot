{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables, InstanceSigs #-}

module Data.Actor.CoinExExchange (CoinExExchange(..), ping, prepare, signRequest) where

import Domain.Actor.Exchange
import Domain.Entity.Amount
import Domain.Entity.Currency
import Data.Network
import Data.Utils (UnimplementedException(..), lazyByteString, fromByteString)

import Control.Exception
import GHC.Generics
import Data.Aeson.Types
import Control.Monad.IO.Class
import Data.Digest.Pure.SHA

data CoinExExchange = CoinExExchange { accessId :: String, secretKey :: String }

instance Exchange CoinExExchange where
    getBalance :: forall m. (MonadIO m) => CoinExExchange -> m [Amount]
    getBalance exchange = do
        request <- signRequest exchange RequestParams {
            method = "GET",
            url = "https://api.coinex.com/v2/assets/spot/balance",
            query = [],
            headers = [],
            body = Nothing
        }
        response <- makeRequest request :: m (StatusResponse [AmountDto])
        return $ map amountToDomain (payload response)

    getRate :: forall m. (MonadIO m) => CoinExExchange -> Currency -> Currency -> m Amount
    getRate exchange baseCurrency quoteCurrency = do
        request <- signRequest exchange RequestParams {
            method = "GET",
            url = "https://api.coinex.com/v2/spot/ticker",
            query = [("market", baseCurrency ++ quoteCurrency)],
            headers = [],
            body = Nothing
        }
        response <- makeRequest request :: m (StatusResponse [RateDto])
        return Amount { currency = baseCurrency, value = getValue $ head $ payload response }

    getMarket exchange fromCurrency toCurrency = throw UnimplementedException
    placeSpotOrder exchange amount toCurrency = throw UnimplementedException

-- Service requests --

{- @return "pong" as well -}
ping :: forall m. (MonadIO m) => m String
ping = do
    response <- makeRequest RequestParams {
        method = "GET",
        url = "https://api.coinex.com/v2/ping",
        query = [],
        headers = [],
        body = Nothing
    } :: m (StatusResponse PingDto)
    return $ result $ payload response

{- @return exchange system time in unix ms -}
systemTime :: forall m. (MonadIO m) => m Integer
systemTime = do
    response <- makeRequest RequestParams {
        method = "GET",
        url = "https://api.coinex.com/v2/time",
        query = [],
        headers = [],
        body = Nothing
    } :: m (StatusResponse SystemTimeDto)
    return $ timestamp $ payload response

-- Auth --

{- Replaces [headers] completely. -}
signRequest :: forall m. (MonadIO m) => CoinExExchange -> RequestParams -> m RequestParams
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

prepare :: Integer -> RequestParams -> String
prepare timestamp params =
    (fromByteString $ method params) ++
    (path $ url $ params) ++
    (prepareQuery $ query params) ++
    (prepareBody $ body params) ++
    (show timestamp)

prepareBody :: Maybe String -> String
prepareBody (Just body) = body
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

-- Mappers --

amountToDomain :: AmountDto -> Amount
amountToDomain dto =
    let currency = ccy dto
        value = read $ available dto :: Float
    in Amount currency value

-- Constants --

windowTimeMs :: Int
windowTimeMs = 5000