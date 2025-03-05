module Domain.DI (DependencyHolder(..)) where

import Domain.Actor.Logger

class (Monad m) => DependencyHolder m where
    getLogger :: (Logger l) => m l