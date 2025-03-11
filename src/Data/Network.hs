{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables, FlexibleContexts #-}

module Data.Network (makeRequest, RequestParams(..), StatusResponse(..)) where

import Domain.DI
import Domain.Actor.Logger
import Data.Utils (byteString)

import Control.Monad.Reader
import Data.ByteString
import Data.CaseInsensitive
import Control.Monad.IO.Class
import GHC.Generics
import Data.Aeson.Types
import Network.HTTP.Simple

makeRequest :: forall req res m. (MonadIO m, HasDI m, ToJSON req, Show req, FromJSON res, Show res) =>
    RequestParams req -> m res
makeRequest params = do
    logger <- asks logger
    liftIO $ do
        debug logger tag ((++) "Request: " $ show params)
        response <- httpJSON $ createRequest params :: IO (Response res)
        let responseBody = getResponseBody response
        debug logger tag ((++) "Response: " $ show responseBody)
        return responseBody

createRequest :: (ToJSON req) => RequestParams req -> Request
createRequest params =
    setRequestMethod (byteString $ method params) $
    setRequestQueryString [(byteString key, Just (byteString value)) | (key, value) <- query params] $
    setRequestHeaders [(mk $ byteString key, byteString value) | (key, value) <- headers params] $
    setOptionalRequestBody (body params) $
    parseRequest_ $ url params

setOptionalRequestBody :: (ToJSON req) => Maybe req -> Request -> Request
setOptionalRequestBody Nothing request = request
setOptionalRequestBody (Just body) request = setRequestBodyJSON body request

data RequestParams b = RequestParams {
    method :: String,
    url :: String,
    query :: [(String, String)],
    headers :: [(String, String)],
    body :: Maybe b
} deriving Show

-- DTO's --

data StatusResponse payload = StatusResponse {
    code :: Int,
    message :: String,
    payload :: payload
} deriving (Show, Generic)

instance (FromJSON payload) => FromJSON (StatusResponse payload) where
    parseJSON = withObject "StatusResponse" $ \o -> do
        code <- o .: "code"
        message <- o .: "message"
        payload <- o .: "data"
        return StatusResponse {
            code = code,
            message = message,
            payload = payload
        }

-- Constants --

tag :: String
tag = "Network"