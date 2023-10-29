module Main exposing (main)

import Basics exposing (..)
import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List
import Maybe exposing (..)


type alias Model =
    { grid : List (List String)
    , currentPlayer : String
    , winner : Maybe String
    }


type Msg
    = ChangeGrid (List (List String))
    | ChangeCurrentPlayer String
    | ChangeWinner (Maybe String)


main : Program () Model Msg
main =
    Browser.sandbox
        { view = view
        , update = update
        , init = init
        }


init : Model
init =
    { grid = [ [] ]
    , currentPlayer = ""
    , winner = Nothing
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeGrid grid ->
            { model | grid = grid }

        ChangeCurrentPlayer currentPlayer ->
            { model | currentPlayer = currentPlayer }

        ChangeWinner winner ->
            { model | winner = winner }


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text model.currentPlayer ]
        , div [] [ text (Maybe.withDefault "" model.winner) ]
        , div [] (List.map (\row -> div [] (List.map (\cell -> div [] [ text cell ]) row)) model.grid)
        ]
