module JenkinsBuild exposing (..)

import Common exposing (dateDecoder, formatDate)
import Date exposing (Date)
import Date.Extra as Date
import Html exposing (Html, a, h2, h3, li, p, span, text, ul)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder, andThen)
import Json.Decode.Pipeline exposing (decode, required, resolve, optional)
import Time exposing (Time)


-- MODEL


type alias Build =
    { displayName : String
    , projectName : String
    , description : String
    , number : Int
    , building : Bool
    , id : String
    , result : String
    , duration : Time
    , timestamp : Date
    , url : String
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
            [ h2 [] [ text build.displayName ]
            , p [] [ text <| formatDate build.timestamp ]
            ]
        ]



-- DECODERS


buildDecoder : Decoder Build
buildDecoder =
    decode Build
        |> required "displayName" Decode.string
        |> required "projectName" Decode.string
        |> optional "description" Decode.string ""
        |> required "number" Decode.int
        |> required "building" Decode.bool
        |> required "id" Decode.string
        |> optional "result" Decode.string "UNKNOWN"
        |> required "duration" Decode.float
        |> required "timestamp" dateDecoder
        |> required "url" Decode.string


buildsDecoder : Decoder (List Build)
buildsDecoder =
    Decode.list buildDecoder
