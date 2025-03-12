module Presentation.EventLoop (Handler, Event(..), joinIntervalLoop) where

import Domain.DI

import Control.Concurrent.Timer
import Control.Concurrent.Suspend

type Handler m = Event -> m

data Event = START | INVALIDATE | STOP deriving Show

joinIntervalLoop :: Int -> Handler (IO ()) -> IO ()
joinIntervalLoop intervalMs handle = do
    handle START
    handle INVALIDATE

    timer <- repeatedTimer (handle INVALIDATE) (msDelay $ fromIntegral intervalMs) :: IO TimerIO
    getLine -- wait until enter key is pressed to safely exit

    stopTimer timer
    handle STOP
