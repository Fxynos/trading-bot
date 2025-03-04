{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables #-}

module Data.Network (makeRequest, RequestParams(..), StatusResponse(..)) where

import Data.Utils (byteString)

import Data.ByteString
import Data.CaseInsensitive
import Control.Monad.IO.Class
import GHC.Generics
import Data.Aeson.Types
import Network.HTTP.Simple

makeRequest :: forall req res m. (MonadIO m, ToJSON req, FromJSON res) => RequestParams req -> m res
makeRequest params = do
    response <- liftIO $ httpJSON $ createRequest params :: m (Response res)
    return $ getResponseBody response

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