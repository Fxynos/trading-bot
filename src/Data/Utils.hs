module Data.Utils (
    UnimplementedException(..),
    lazyByteString, fromLazyByteString,
    byteString, fromByteString
) where

import Control.Exception
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.ByteString.Char8 as BC

-- Exceptions --

data UnimplementedException = UnimplementedException deriving Show
instance Exception UnimplementedException

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