module Main (main) where

import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange as CoinExExchange
import Domain.Actor.Logger
import Data.Actor.Logger

main :: IO ()
main = do
    let logger = CompositeLogger [(CompositeLoggerItem TerminalLogger), (CompositeLoggerItem (FileLogger "log.txt"))]
    info logger tag "Start"
    warn logger tag "Sample warning message"
    err logger tag "Sample error message"

exchange :: CoinExExchange
exchange = CoinExExchange {
   accessId = "your-value",
   secretKey = "your-value"
}

showBalance :: [Amount] -> String
showBalance [] = ""
showBalance balance =
    let lines = [(currency amount) ++ ": " ++ (show $ value amount) | amount <- balance]
    in foldl (\line1 line2 -> line1 ++ "\n" ++ line2) (head lines) (tail lines)

-- Constants --

tag :: String
tag = "Main"