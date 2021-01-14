{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeOperators       #-}

module Webserver where

import           API                      (API)
import           Data.Proxy               (Proxy (Proxy))
import           Network.Wai.Handler.Warp as Warp
import           Servant                  (serve)
import qualified Server

run :: Settings -> IO ()
run settings = do
  let server = Server.handlers
  Warp.runSettings settings (serve (Proxy @API) server)
