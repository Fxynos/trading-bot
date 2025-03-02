module Data.Network (makeRequest, RequestParams(..)) where

import Data.ByteString
import Control.Monad.IO.Class
import Data.Aeson.Types
import Network.HTTP.Simple

makeRequest :: (MonadIO m, FromJSON r) => RequestParams -> m (Response r)
makeRequest params = httpJSON $ createRequest params

createRequest :: RequestParams -> Request
createRequest params =
    setRequestMethod (method params) $
    parseRequest_ $ url params

data RequestParams = RequestParams {
    method :: ByteString,
    url :: String,
    query :: [(String, String)], -- TODO use query, headers, body
    headers :: [(String, String)],
    body :: Maybe String
}