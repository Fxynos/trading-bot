module Presentation.Config (Config(..)) where

data Config = Config {
    tick :: Int,
    gap :: Float,
    amount :: Float,
    currency :: String,
    accessId :: String,
    secretKey :: String
}

instance Show Config where
    show (Config tick gap amount currency _ _) =
        "Config: tick = " ++ (show tick) ++
        ", gap = " ++ (show gap) ++
        ", amount = " ++ (show amount) ++
        ", currency = " ++ (show currency)