module Main exposing (..)

import Html exposing (Html, a, div, h1, h3, li, p, pre, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (class, classList, colspan, id)
import Html.Events exposing (onClick)
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder, field, succeed)
import Json.Decode.Pipeline exposing (decode, required)


-- MODEL


type alias Build =
    { name : String }


type alias Job =
    { name : String
    , color : String
    , timestamp : Int
    , downstream : DownStreams
    , building : Bool
    }


type DownStreams
    = DownStreams (List Job)


type alias BuildInfo =
    { displayName : String
    , jobs : List Job
    }


type alias Model =
    { builds : List Build
    , selectedBuild : Maybe Build
    , buildInfo : Maybe BuildInfo
    }


model : Model
model =
    { builds = []
    , selectedBuild = Nothing
    , buildInfo = Nothing
    }



-- UPDATE


type Msg
    = NoOp
    | LoadedBuilds (Result Http.Error (List Build))
    | SelectBuild Build
    | LoadedBuildInfo (Result Http.Error BuildInfo)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SelectBuild build ->
            ( { model
                | selectedBuild = Just build
                , buildInfo = Nothing
              }
            , getBuildInfo build
            )

        LoadedBuilds (Ok builds) ->
            let
                firstBuildMaybe =
                    List.head builds

                cmd =
                    case firstBuildMaybe of
                        Just firstBuild ->
                            getBuildInfo firstBuild

                        Nothing ->
                            Cmd.none
            in
                ( { model | builds = builds, selectedBuild = firstBuildMaybe }, cmd )

        LoadedBuilds (Err error) ->
            let
                _ =
                    Debug.log "Oops!" error
            in
                ( model, Cmd.none )

        LoadedBuildInfo (Ok buildInfo) ->
            ( { model | buildInfo = Just buildInfo }, Cmd.none )

        LoadedBuildInfo (Err error) ->
            let
                _ =
                    Debug.log "Oops!" error
            in
                ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "main-app" ]
        [ h1 [] [ text "Jenkins Status!" ]
        , h3 [] [ text "Builds" ]
        , buildListView model.builds model.selectedBuild
        , buildInfoView model.buildInfo
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


buildInfoView : Maybe BuildInfo -> Html Msg
buildInfoView buildInfoMaybe =
    case buildInfoMaybe of
        Just buildInfo ->
            div [ class "job-info-container" ]
                (List.map jobView buildInfo.jobs)

        Nothing ->
            text ""


jobView : Job -> Html Msg
jobView job =
    table [ class "job-table" ]
        [ tbody []
            [ tr []
                [ th [] [ text "Name" ]
                , td [] [ text job.name ]
                ]
            , tr []
                [ th [] [ text "Color" ]
                , td [] [ text job.color ]
                ]
            , tr []
                [ th [] [ text "Started On" ]
                , td [] [ text <| toString job.timestamp ]
                ]
            , tr []
                [ th [] [ text "Down Stream Jobs #" ]
                , td []
                    [ text <|
                        toString <|
                            case job.downstream of
                                DownStreams jobs ->
                                    List.length jobs
                    ]
                ]
            ]
        ]



-- DECODERS


buildDecoder : Decoder Build
buildDecoder =
    decode Build
        |> required "name" Decode.string


buildsDecoder : Decoder (List Build)
buildsDecoder =
    Decode.list buildDecoder


buildInfoDecoder : Decoder BuildInfo
buildInfoDecoder =
    decode BuildInfo
        |> required "displayName" Decode.string
        |> required "jobs" (Decode.list jobDecoder)


downStreamDecoder : Decoder DownStreams
downStreamDecoder =
    Decode.map DownStreams (Decode.list (Decode.lazy (\_ -> jobDecoder)))


jobDecoder : Decoder Job
jobDecoder =
    decode Job
        |> required "name" Decode.string
        |> required "color" Decode.string
        |> required "timestamp" Decode.int
        |> required "downstream" downStreamDecoder
        |> required "building" Decode.bool



-- COMMANDS


buildsUrl : String
buildsUrl =
    "./builds"


getBuilds : Cmd Msg
getBuilds =
    buildsDecoder
        |> Http.get buildsUrl
        |> Http.send LoadedBuilds


getBuildInfo : Build -> Cmd Msg
getBuildInfo build =
    buildInfoDecoder
        |> Http.get (buildsUrl ++ "/" ++ build.name)
        |> Http.send LoadedBuildInfo


main =
    Html.program
        { init = ( model, getBuilds )
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }
