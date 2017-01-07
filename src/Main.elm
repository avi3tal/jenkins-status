module Main exposing (..)

import Html exposing (Html, a, div, h1, h3, li, p, pre, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (class, classList, colspan, id)
import Html.Events exposing (onClick)
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder, field, succeed)
import Json.Decode.Pipeline exposing (decode, required)
import JenkinsBuild exposing (Build, buildsDecoder)
import JenkinsJob exposing (DownStream, Job, jobDecoder)


-- MODEL


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
    | LoadedBuildInfo (Result Http.Error BuildInfo)
    | BuildMsg JenkinsBuild.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        BuildMsg buildMsg ->
            case buildMsg of
                JenkinsBuild.SelectBuild build ->
                    ( { model
                        | selectedBuild = Just build
                        , buildInfo = Nothing
                      }
                    , getBuildInfo build
                    )

        LoadedBuilds (Ok builds) ->
            let
                firstBuild =
                    List.head builds

                cmd =
                    firstBuild
                        |> Maybe.map getBuildInfo
                        |> Maybe.withDefault Cmd.none
            in
                ( { model | builds = builds, selectedBuild = firstBuild }, cmd )

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
        [ h1 [] [ text "Jenkins Status" ]
        , h3 [] [ text "Builds" ]
        , Html.map BuildMsg (JenkinsBuild.listView model.builds model.selectedBuild)
        , buildInfoView model.buildInfo
        ]


buildInfoView : Maybe BuildInfo -> Html Msg
buildInfoView buildInfoMaybe =
    case buildInfoMaybe of
        Just buildInfo ->
            div [ class "job-info-container" ]
                (List.map JenkinsJob.view buildInfo.jobs)

        Nothing ->
            text ""



-- DECODERS


buildInfoDecoder : Decoder BuildInfo
buildInfoDecoder =
    decode BuildInfo
        |> required "displayName" Decode.string
        |> required "jobs" (Decode.list jobDecoder)



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
