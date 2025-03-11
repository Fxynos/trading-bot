module Presentation.Config (Config(..)) where

data Config = Config {
    tick :: Int,
    gap :: Float,
    amount :: Float,
    baseCurrency :: String,
    quoteCurrency :: String,
    accessId :: String,
    secretKey :: String
}

instance Show Config where
    show (Config tick gap amount baseCurrency quoteCurrency _ _) =
        "Config: tick = " ++ (show tick) ++
        ", gap = " ++ (show gap) ++
        ", amount = " ++ (show amount) ++
        ", base currency = " ++ (show baseCurrency) ++
        ", quote currency = " ++ (show quoteCurrency)