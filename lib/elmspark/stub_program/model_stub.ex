defmodule ElmSpark.StubProgram.ModelStub do
  @moduledoc """
  A stub Elm program that will allow for iterating compilation of a Elm Model
  which will act as the core of the program.

  All other functions in the stub program are stubbed out to allow for Elm to
  focus its compilation efforts on just the Model.
  """

  #alias ElmSpark.LLM

  @base_elm_program """
  module ModelShell exposing (main)

  import Html exposing (Html)

  main : Application
  main =
      { view = view
      , update = update
      , init = init
      }

  init : Model
  init =
      Debug.todo "init"

  update : () -> Model -> (Model, Cmd Msg)
  update _ model =
      (model, Cmd.none)

  view : Model -> Html Msg
  view _=
      Html.div [] []
  """

  def generate(%{
        #processed_upstream,
        title: title,
        description: description,
        works: works
      }) do
    message = """
    Given the title: #{title}, the description: #{description}, and the user acceptance criteria #{works}, what is the data required to generate the Elm Model?
    """

    # ""
    # LLM.user_message({}
    # LLM.chat_completions()
  end
end
