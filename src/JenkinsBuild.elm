module JenkinsBuild exposing (..)

import Html exposing (Html, a, li, text, ul)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)


-- MODEL


type alias Build =
    { name : String }


type Msg
    = SelectBuild Build



-- VIEW


buildListView : List Build -> Maybe Build -> Html Msg
buildListView builds selectedBuild =
    ul [ class "build-list" ]
        (List.map (buildItemView selectedBuild) builds)


buildItemView : Maybe Build -> Build -> Html Msg
buildItemView selectedBuild build =
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


buildsDecoder : Decoder (List Build)
buildsDecoder =
    Decode.list buildDecoder
