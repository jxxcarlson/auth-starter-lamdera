module Backend.Cmd exposing (getRandomNumber)

import Dict
import Http
import Lamdera exposing (sendToFrontend)
import Types exposing (..)


getRandomNumber : Cmd BackendMsg
getRandomNumber =
    Http.get
        { url = randomNumberUrl 9
        , expect = Http.expectString GotAtomsphericRandomNumber
        }


{-| maxDigits < 10
-}
randomNumberUrl : Int -> String
randomNumberUrl maxDigits =
    let
        maxNumber =
            10 ^ maxDigits

        prefix =
            "https://www.random.org/integers/?num=1&min=1&max="

        suffix =
            "&col=1&base=10&format=plain&rnd=new"
    in
    prefix ++ String.fromInt maxNumber ++ suffix
