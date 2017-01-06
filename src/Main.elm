module Main exposing (..)

import Html exposing (Html, a, div, h1, h3, li, p, pre, text, ul)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder, field, succeed)
import Json.Decode.Pipeline exposing (decode, required)


-- MODEL


type alias Build =
    { name : String }


type alias Model =
    { builds : List Build
    , selectedBuild : Maybe Build
    }


model : Model
model =
    { builds = []
    , selectedBuild = Nothing
    }



-- UPDATE


type Msg
    = NoOp
    | LoadedBuilds (Result Http.Error (List Build))
    | SelectBuild Build


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SelectBuild build ->
            ( { model | selectedBuild = Just build }, Cmd.none )

        LoadedBuilds (Ok builds) ->
            ( { model | builds = builds, selectedBuild = List.head builds }, Cmd.none )

        LoadedBuilds (Err error) ->
            let
                _ =
                    Debug.log "Opps!" error
            in
                ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "main-app" ]
        [ h1 [] [ text "Jenkins Status" ]
        , h3 [] [ text "Builds" ]
        , buildListView model.builds model.selectedBuild
        ]


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



-- COMMANDS


buildUrl : String
buildUrl =
    "./builds"


getBuilds : Cmd Msg
getBuilds =
    buildsDecoder
        |> Http.get buildUrl
        |> Http.send LoadedBuilds


main =
    Html.program
        { init = ( model, getBuilds )
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }
