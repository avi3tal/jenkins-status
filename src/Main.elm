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
    List Job



--    { displayName : String
--    , jobs : List Job
--    }


type alias Model =
    { builds : List Build
    , selectedBuild : Maybe Build
    , buildInfo : Maybe BuildInfo
    , errorMessage : Maybe String
    , buildInfoLoading : Bool
    }


model : Model
model =
    { builds = []
    , selectedBuild = Nothing
    , buildInfo = Nothing
    , errorMessage = Nothing
    , buildInfoLoading = False
    }


buildToJob : Build -> Job
buildToJob build =
    Job
        build.displayName
        build.projectName
        build.description
        build.building
        build.id
        build.result
        build.duration
        build.timestamp
        build.url



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
                        , buildInfoLoading = True
                      }
                    , getBuildDownstreamProjects build
                    )

        LoadedBuilds (Ok builds) ->
            let
                firstBuild =
                    List.head builds

                cmd =
                    firstBuild
                        |> Maybe.map getBuildDownstreamProjects
                        |> Maybe.withDefault Cmd.none
            in
                ( { model
                    | builds = builds
                    , selectedBuild = firstBuild
                    , errorMessage = Nothing
                    , buildInfoLoading = True
                  }
                , cmd
                )

        LoadedBuilds (Err error) ->
            let
                _ =
                    Debug.log "Oops!" error
            in
                ( { model
                    | errorMessage = Just (toString error)
                  }
                , Cmd.none
                )

        LoadedBuildInfo (Ok buildInfo) ->
            ( { model
                | buildInfo = Just buildInfo
                , errorMessage = Nothing
                , buildInfoLoading = False
              }
            , Cmd.none
            )

        LoadedBuildInfo (Err error) ->
            let
                _ =
                    Debug.log "Oops!" error
            in
                ( { model
                    | errorMessage = Just (toString error)
                    , buildInfoLoading = False
                  }
                , Cmd.none
                )



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "main-app" ]
        [ h1 [] [ text "Jenkins Status" ]
        , (case model.errorMessage of
            Nothing ->
                text ""

            Just error ->
                div [ class "error" ] [ text error ]
          )
        , Html.map BuildMsg (JenkinsBuild.listView model.builds model.selectedBuild)
        , if model.buildInfoLoading then
            text "Loading..."
          else
            buildInfoView
                (Maybe.map
                    (\buildInfo ->
                        case model.selectedBuild of
                            Just build ->
                                buildToJob build :: buildInfo

                            Nothing ->
                                buildInfo
                    )
                    model.buildInfo
                )
        ]


buildInfoView : Maybe BuildInfo -> Html Msg
buildInfoView buildInfoMaybe =
    case buildInfoMaybe of
        Just buildInfo ->
            if List.length buildInfo == 0 then
                div [ class "job-info-container" ]
                    [ text "No Builds" ]
            else
                div [ class "job-info-container" ]
                    (List.map JenkinsJob.view buildInfo)

        Nothing ->
            text ""



-- DECODERS


buildInfoDecoder : Decoder BuildInfo
buildInfoDecoder =
    Decode.list jobDecoder



-- COMMANDS


buildsUrl : String
buildsUrl =
    "./builds"


getBuilds : Cmd Msg
getBuilds =
    buildsDecoder
        |> Http.get buildsUrl
        |> Http.send LoadedBuilds


getBuildDownstreamProjects : Build -> Cmd Msg
getBuildDownstreamProjects build =
    buildInfoDecoder
        |> Http.get (buildsUrl ++ "/downstream/" ++ build.projectName ++ "/" ++ (toString build.number))
        |> Http.send LoadedBuildInfo


main =
    Html.program
        { init = ( model, getBuilds )
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }
