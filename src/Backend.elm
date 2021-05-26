module Backend exposing (..)

import Authentication
import Backend.Cmd
import Backend.Update
import Dict
import Lamdera exposing (ClientId, SessionId, sendToFrontend)
import Random
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!"

      -- RANDOM
      , randomSeed = Random.initialSeed 1234
      , uuidCount = 0
      , randomAtmosphericInt = Nothing

      -- USER
      , authenticationDict = Dict.empty
      }
    , Backend.Cmd.getRandomNumber
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        GotAtomsphericRandomNumber result ->
            Backend.Update.gotAtomsphericRandomNumber model result


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        -- ADMIN
        RunTask ->
            ( model, Cmd.none )

        SendUsers ->
            ( model, sendToFrontend clientId (GotUsers (Authentication.users model.authenticationDict)) )

        -- USER
        SignInOrSignUp username transitPassword ->
            let
                _ =
                    Debug.log "SignInOrSignUp" ( username, transitPassword )
            in
            case Dict.get username model.authenticationDict of
                Just userData ->
                    if Authentication.verify username transitPassword model.authenticationDict then
                        ( model
                        , Cmd.batch
                            [ sendToFrontend clientId (SendUser userData.user)
                            , sendToFrontend clientId (SendMessage "Success! You are signed in.")
                            ]
                        )

                    else
                        ( model, sendToFrontend clientId (SendMessage <| "Sorry, password and username don't match") )

                Nothing ->
                    Backend.Update.setupUser model clientId username transitPassword
