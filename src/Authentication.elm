module Authentication exposing
    ( AuthenticationDict
    , encrypt
    , encryptForTransit
    , insert
    , users
    , verify
    , verify_
    )

import Crypto.HMAC exposing (sha256)
import Dict exposing (Dict)
import Env
import User exposing (User)



{-

   > pass = "hello"
   "hello" : String

    > salt = "1234"
    "1234" : String

    > passEncrypted = encrypt salt passTransit
    "12a941b42bcc15da068861f6e1bb383b8b5d961e3f317a1ddc6d8cc5007bfcbd"

    > verify_ salt passTransit passEncrypted
    True : Bool

    > u = {username = "fred", id = "1122", realname = "Fred Barnes", email = "fb@foo.io" }
    { email = "fb@foo.io", id = "1122", realname = "Fred Barnes", username = "fred" }
        : { email : String, id : String, realname : String, username : String }
    > authDict2 = insert u "1234" passTransit authDict
    Dict.fromList [("fred",{ hash = "12a941b42bcc15da068861f6e1bb383b8b5d961e3f317a1ddc6d8cc5007bfcbd", salt = "1234", user = { email = "fb@foo.io", id = "1122", realname = "Fred Barnes", username = "fred" } })]
        : AuthenticationDict
    > verify "fred" passTransit authDict2
    True : Bool

-}


type alias Username =
    String


type alias UserData =
    { user : User, salt : String, hash : String }


type alias AuthenticationDict =
    Dict Username UserData


users : AuthenticationDict -> List User
users authDict =
    authDict |> Dict.values |> List.map .user


insert : User -> String -> String -> AuthenticationDict -> AuthenticationDict
insert user salt transitPassword authDict =
    Dict.insert user.username { user = user, salt = salt, hash = encrypt salt transitPassword } authDict


encryptForTransit : String -> String
encryptForTransit str =
    Crypto.HMAC.digest sha256 Env.transitKey str


encrypt : String -> String -> String
encrypt salt transitPassword =
    Crypto.HMAC.digest sha256 Env.authKey (salt ++ transitPassword)


verify_ : String -> String -> String -> Bool
verify_ salt transitPassword encryptedPassword =
    encrypt salt transitPassword == encryptedPassword


verify : String -> String -> AuthenticationDict -> Bool
verify username transitPassword authDict =
    case Dict.get username authDict of
        Nothing ->
            False

        Just data ->
            verify_ data.salt transitPassword data.hash
