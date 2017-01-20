module Common exposing (..)

import Date exposing (Date)
import Date.Extra as Date
import Json.Decode as Decode exposing (Decoder)
import Time exposing (Time)


dateDecoder : Decoder Date
dateDecoder =
    Decode.map Date.fromTime Decode.float


formatDate : Date -> String
formatDate date =
    Date.toUtcFormattedString "yyyy-MM-dd HH:mm:ss X" date


pluralize : Int -> String -> String -> String
pluralize count single plural =
    if count == 1 then
        single
    else
        plural


humanizeDuration : Time -> String
humanizeDuration time =
    if Time.inSeconds time < 60 then
        let
            seconds =
                round <| Time.inSeconds time

            unit =
                pluralize seconds "second" "seconds"
        in
            toString seconds ++ " " ++ unit
    else if Time.inMinutes time < 60 then
        let
            minutes =
                round <| Time.inMinutes time

            unit =
                pluralize minutes "minute" "minutes"

            millis =
                time - (toFloat minutes * 60 * 1000)

            rest =
                if millis > 0 then
                    humanizeDuration millis
                else
                    ""
        in
            toString minutes ++ " " ++ unit ++ " " ++ rest
    else
        let
            hours =
                round <| Time.inHours time

            unit =
                pluralize hours "hour" "hours"

            minutes =
                time - (toFloat hours * 60 * 60 * 1000)

            rest =
                if minutes > 0 then
                    humanizeDuration minutes
                else
                    ""
        in
            toString hours ++ " " ++ unit ++ " " ++ rest
