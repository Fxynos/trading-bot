{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables #-}

module Data.Network (makeRequest, RequestParams(..), StatusResponse(..)) where

import Data.Utils (byteString)

import Data.ByteString
import Data.CaseInsensitive
import Control.Monad.IO.Class
import GHC.Generics
import Data.Aeson.Types
import Network.HTTP.Simple

makeRequest :: forall r m. (MonadIO m, FromJSON r) => RequestParams -> m r
makeRequest params = do
    response <- liftIO $ httpJSON $ createRequest params :: m (Response r)
    return $ getResponseBody response

createRequest :: RequestParams -> Request
createRequest params =
    setRequestMethod (method params) $
    setRequestQueryString [(byteString key, Just (byteString value)) | (key, value) <- query params] $
    setRequestHeaders [(mk $ byteString key, byteString value) | (key, value) <- headers params] $
    parseRequest_ $ url params

data RequestParams = RequestParams {
    method :: ByteString,
    url :: String,
    query :: [(String, String)],
    headers :: [(String, String)],
    body :: Maybe String -- TODO use body
}

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