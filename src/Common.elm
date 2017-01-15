module Common exposing (..)

import Date exposing (Date)
import Date.Extra as Date
import Json.Decode as Decode exposing (Decoder)


dateDecoder : Decoder Date
dateDecoder =
    Decode.map Date.fromTime Decode.float


formatDate : Date -> String
formatDate date =
    Date.toUtcFormattedString "yyyy-MM-dd HH:mm:ss X" date
