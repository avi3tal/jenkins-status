module JenkinsJob exposing (..)

-- MODEL

import Common exposing (dateDecoder, formatDate, humanizeDuration)
import Date exposing (Date)
import Html exposing (Html, a, caption, div, table, tbody, td, text, th, tr)
import Html.Attributes exposing (class, href, style, target)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Time exposing (Time)


type alias Job =
    { displayName : String
    , projectName : String
    , description : String
    , building : Bool
    , id : String
    , result : String
    , duration : Time
    , timestamp : Date
    , url : String
    }


type DownStream
    = DownStream (List Job)



-- VIEW


view : Job -> Html msg
view job =
    table [ class "job-table" ]
        [ caption [] [ text job.projectName ]
        , tbody []
            [ tr []
                [ th [] [ text "Name" ]
                , td [] [ a [ href job.url, target "_blank" ] [ text job.displayName ] ]
                ]
            , tr []
                [ th [] [ text "Description" ]
                , td [] [ text job.description ]
                ]
            , tr []
                [ th [] [ text "Building" ]
                , td [] [ text <| toString job.building ]
                ]
            , tr []
                [ th [] [ text "Result" ]
                , td []
                    --                    [ colorIndicator job.color ]
                    [ text job.result ]
                ]
            , tr []
                [ th [] [ text "Started On" ]
                , td [] [ text <| formatDate job.timestamp ]
                ]
            , tr []
                [ th [] [ text "Duration" ]
                , td [] [ text <| humanizeDuration job.duration ]
                ]
              --            , tr []
              --                [ th [] [ text <| formatDownStreamTitle job.subBuilds ]
              --                , td [] (downStreamView job.subBuilds)
              --                ]
            ]
        ]


formatDownStreamTitle : DownStream -> String
formatDownStreamTitle downStream =
    let
        suffix =
            case downStream of
                DownStream jobs ->
                    if List.length jobs == 0 then
                        ""
                    else
                        " (" ++ (toString <| List.length jobs) ++ ")"
    in
        "Down Stream Jobs" ++ suffix


downStreamView : DownStream -> List (Html msg)
downStreamView downStream =
    case downStream of
        DownStream jobs ->
            if List.length jobs > 0 then
                List.map view jobs
            else
                [ text "-" ]


colorIndicator : String -> Html msg
colorIndicator color =
    div [ class <| "color-indicator " ++ color ] []



-- DECODERS


downStreamDecoder : Decoder DownStream
downStreamDecoder =
    Decode.map DownStream (Decode.list (Decode.lazy (\_ -> jobDecoder)))


jobDecoder : Decoder Job
jobDecoder =
    decode Job
        |> required "displayName" Decode.string
        |> required "projectName" Decode.string
        |> optional "description" Decode.string ""
        |> required "building" Decode.bool
        |> required "id" Decode.string
        |> required "result" Decode.string
        |> required "duration" Decode.float
        |> required "timestamp" dateDecoder
        |> required "url" Decode.string



--        |> required "subBuilds" downStreamDecoder
