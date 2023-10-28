defmodule ElmSpark.StubProgram.ModelStub do
  @moduledoc """
  A stub Elm program that will allow for iterating compilation of a Elm Model
  which will act as the core of the program.

  All other functions in the stub program are stubbed out to allow for Elm to
  focus its compilation efforts on just the Model.
  """

  alias ElmSpark.LLM
  alias Elmspark.Elmspark.Blueprint

  # @spe runc(%Blueprint{})
  def run(
        %{
          title: title,
          description: description,
          works: works
        } = blueprint
      ) do
    # msg = extract_blueprint_architecture_prompt(blueprint) |> LLM.user_message()
    #msg = generate(blueprint) |> LLM.user_message()
    #LLM.chat_completions([msg])
    pipeline(blueprint)
  end

  def pipeline(blueprint) do
    msg = generate(blueprint, &LLM.user_message/1)
    res = LLM.chat_completions([msg])

    case res do
      {:ok, %{choices: [%{message: %{content: fields}}]}} ->
        msg = generate_type_alias(fields, &LLM.user_message/1)
        res = LLM.chat_completions([msg])

      {:error, e} ->
        {:error, e}
    end
  end

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

  def generate(
        %{
          # processed_upstream,
          title: title,
          description: description,
          works: works
        },
        present
      ) do
    message = """
    Given the title: #{title}, the description: #{description}, and the user acceptance criteria #{works}, what are the fields that are necessary to create a working Elm application that matches the input.

    List out the fields as a list of strings with their types. Your response should look something like this:
    ```
    [ "field1" : "field1sType"
    , "field2" : "field2sType"
    ]
    """

    present.(message)

    # ""
    # LLM.user_message({}
    # LLM.chat_completions()
  end

  def generate_type_alias(fields, present) do
    message = """
    Turn this list of fields: #{fields} into a Elm type alias called Model. Each field should be on its own line.

    So for example if the fields given were:
    ```
      [ ("color", String)
      , ("size", Int)
      ]
    ```

    Then your response should look like this:
    ```
    type alias Model =
      { color : String
      , size : Int
      }
    """

    present.(message)
  end

  def extract_blueprint_architecture_prompt(%{
        # processed_upstream,
        title: title,
        description: description,
        works: works
      }) do
    """
    Given the title: #{title}, the description: #{description}, and the user acceptance criteria #{works}, what is the data required to generate the Elm Model?

    Generate the Elm Model, and only the Elm model. Your response should look something like this:

    ```
    type alias Model =
      { key : Type
      ...
      }
    ```
    """

    # ""
    # LLM.user_message({}
    # LLM.chat_completions()
  end
end
