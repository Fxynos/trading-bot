{-# LANGUAGE FlexibleContexts #-}

module Domain.Actor.Bot (Bot(..)) where

import Domain.DI

class Bot b where
    onCreate :: AppMonad m => b -> m ()
    invalidate :: AppMonad m => b -> m ()
    finish :: AppMonad m => b -> m ()