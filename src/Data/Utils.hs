module Data.Utils (
    UnimplementedException(..), RuntimeException(..), getOrThrow,
    lazyByteString, fromLazyByteString,
    byteString, fromByteString
) where

import Control.Exception
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.ByteString.Char8 as BC

-- Exceptions --

data UnimplementedException = UnimplementedException deriving Show
instance Exception UnimplementedException

data RuntimeException = RuntimeException deriving Show
instance Exception RuntimeException

getOrThrow :: Exception e => e -> Maybe a -> a
getOrThrow _ (Just a) = a
getOrThrow e Nothing = throw e

-- String convertations --

{-- @return lazy ByteString --}
lazyByteString :: String -> BL.ByteString
lazyByteString s = BL.pack s

fromLazyByteString :: BL.ByteString -> String
fromLazyByteString bs = BL.unpack bs

byteString :: String -> BC.ByteString
byteString s = BC.pack s

fromByteString :: BC.ByteString -> String
fromByteString bs = BC.unpack bs