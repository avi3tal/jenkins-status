module JenkinsJob exposing (..)

-- MODEL

import Common exposing (dateDecoder, formatDate)
import Date exposing (Date)
import Html exposing (Html, div, table, tbody, td, text, th, tr)
import Html.Attributes exposing (class, style)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)


type alias Job =
    { name : String
    , color : String
    , timestamp : Date
    , downstream : DownStream
    , building : Bool
    }


type DownStream
    = DownStream (List Job)



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
                , td [] (downStreamView job.downstream)
                ]
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
        |> required "name" Decode.string
        |> required "color" Decode.string
        |> required "timestamp" dateDecoder
        |> required "downstream" downStreamDecoder
        |> required "building" Decode.bool
