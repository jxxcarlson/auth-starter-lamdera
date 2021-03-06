module View.Utility exposing
    ( cssNode
    , elementAttribute
    , noFocus
    , showIf
    , showIfIsAdmin
    )

import Element exposing (Element)
import Html
import Html.Attributes as HA
import Types exposing (FrontendModel, FrontendMsg)


showIfIsAdmin : FrontendModel -> Element msg -> Element msg
showIfIsAdmin model element =
    showIf (Maybe.map .username model.currentUser == Just "jxxcarlson") element


showIf : Bool -> Element msg -> Element msg
showIf isVisible element =
    if isVisible then
        element

    else
        Element.none


noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }


cssNode : String -> Element FrontendMsg
cssNode fileName =
    Html.node "link" [ HA.rel "stylesheet", HA.href fileName ] [] |> Element.html


elementAttribute : String -> String -> Element.Attribute msg
elementAttribute key value =
    Element.htmlAttribute (HA.attribute key value)
