module JenkinsJob exposing (..)

-- MODEL

import Html exposing (Html, table, tbody, td, text, th, tr)
import Html.Attributes exposing (class)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)


type alias Job =
    { name : String
    , color : String
    , timestamp : Int
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
