module HttpClient (fetch, Http(..), ErrorCode(..), Url(..)) where

import Data.Function
import Data.Either
import Control.Monad.Eff
import Control.Monad.Cont.Trans

foreign import data Net :: !

type ErrorCode = String
type Url = String

type M = Eff (fs :: Net)

foreign import fetchImpl
  """
   function fetchImpl(url, onSuccess, onFailure) {
     var fetch = require('node-fetch');
     console.log('requests ' + url);
     fetch(url)
       .then(function (response) { return response.json(); })
       .then(function (json) { return JSON.stringify(json); })
       .then(function (json) { return json.replace(/"([^"]+)":/g,function($0,$1){return ('"'+$1.toLowerCase()+'":');}); })
       .then(function (json) { return JSON.parse(json); })
       .then(function (x) {
         onSuccess(x);
        })
       .catch(function (error) {
         onFailure(error);
        });
  }
  """ :: forall a. Fn3 Url
                         (a -> M Unit)
                         (ErrorCode -> M Unit)
                         (M Unit)

fetchCb :: forall a. Url -> (Either ErrorCode a -> M Unit) -> M Unit
fetchCb url k =
   runFn3 fetchImpl
          url
          (k <<< Right)
          (k <<< Left)

type Http a = ContT Unit M a

fetchSafe :: forall a. Url -> Http (Either ErrorCode a)
fetchSafe path = ContT $ fetchCb path

fetch :: forall a. Url -> Http a
fetch path = (\(Right x) -> x) <$> fetchSafe path
