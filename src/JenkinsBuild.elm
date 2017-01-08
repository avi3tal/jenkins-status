module JenkinsBuild exposing (..)

import Html exposing (Html, a, li, text, ul)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)


-- MODEL


type alias Build =
    { name : String
    , number : Int
    }


type Msg
    = SelectBuild Build



-- VIEW


listView : List Build -> Maybe Build -> Html Msg
listView builds selectedBuild =
    ul [ class "build-list" ]
        (List.map (itemView selectedBuild) builds)


itemView : Maybe Build -> Build -> Html Msg
itemView selectedBuild build =
    li
        [ classList [ ( "selected", Just build == selectedBuild ) ] ]
        [ a [ onClick (SelectBuild build) ]
            [ text build.name ]
        ]



-- DECODERS


buildDecoder : Decoder Build
buildDecoder =
    decode Build
        |> required "name" Decode.string
        |> required "number" Decode.int


buildsDecoder : Decoder (List Build)
buildsDecoder =
    Decode.list buildDecoder
