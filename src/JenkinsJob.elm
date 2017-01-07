module JenkinsJob exposing (..)

-- MODEL

import Date exposing (Date)
import Date.Extra as Date
import Html exposing (Html, div, table, tbody, td, text, th, tr)
import Html.Attributes exposing (class, style)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)


type alias Job =
    { name : String
    , color : String
    , timestamp : Date
    , downstream : DownStreams
    , building : Bool
    }


type DownStreams
    = DownStreams (List Job)



-- VIEW


view : Job -> Html msg
view job =
    table [ class "job-table" ]
        [ tbody []
            [ tr []
                [ th [] [ text "Name" ]
                , td [] [ text job.name ]
                ]
            , tr []
                [ th [] [ text "Color" ]
                , td []
                    [ colorIndicator job.color ]
                ]
            , tr []
                [ th [] [ text "Started On" ]
                , td [] [ text <| formatDate job.timestamp ]
                ]
            , tr []
                [ th [] [ text <| formatDownStreamTitle job.downstream ]
                , td [] (downStreamsView job.downstream)
                ]
            ]
        ]


formatDownStreamTitle : DownStreams -> String
formatDownStreamTitle downStreams =
    let
        suffix =
            case downStreams of
                DownStreams jobs ->
                    if List.length jobs == 0 then
                        ""
                    else
                        " (" ++ (toString <| List.length jobs) ++ ")"
    in
        "Down Stream Jobs" ++ suffix


formatDate : Date -> String
formatDate date =
    Date.toUtcFormattedString "yyyy-MM-dd HH:mm:ss X" date


downStreamsView : DownStreams -> List (Html msg)
downStreamsView downStreams =
    case downStreams of
        DownStreams jobs ->
            if List.length jobs > 0 then
                List.map view jobs
            else
                [ text "-" ]


colorIndicator : String -> Html msg
colorIndicator color =
    div [ class <| "color-indicator " ++ color ] []



-- DECODERS


downStreamDecoder : Decoder DownStreams
downStreamDecoder =
    Decode.map DownStreams (Decode.list (Decode.lazy (\_ -> jobDecoder)))


dateFromTimestampDecoder : Decoder Date
dateFromTimestampDecoder =
    Decode.map toFloat Decode.int
        |> Decode.map Date.fromTime


jobDecoder : Decoder Job
jobDecoder =
    decode Job
        |> required "name" Decode.string
        |> required "color" Decode.string
        |> required "timestamp" dateFromTimestampDecoder
        |> required "downstream" downStreamDecoder
        |> required "building" Decode.bool
