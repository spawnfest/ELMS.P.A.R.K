defmodule Elmspark.Elmspark.EllmProgram do
  defstruct [
    :imports,
    :model_fields,
    :model_alias,
    :view,
    :init,
    :messages,
    :update,
    :stage,
    :code,
    :error,
    global_imports: ["Basics", "Html", "Html.Attributes", "Html.Events", "Maybe"]
  ]



  def new() do
    %__MODULE__{}
  end

  def set_stage(%__MODULE__{} = program, stage) do
    Map.put(program, :stage, stage)
  end

  def to_code(
        %__MODULE__{
          stage: :add_view_function,
          view: view,
          update: update,
          model_alias: model_alias,
          init: init,
          messages: messages
        } =
          _program
      ) do
    init = String.replace(init, "\n", "")

    """
    module Main exposing (main)

    import Html exposing (..)
    import Html.Attributes exposing (..)
    import Html.Events exposing (..)
    import Array exposing (Array, length, get)
    import Browser

    #{model_alias}

    #{messages}

    main : Program ()  Model Msg
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    init : Model
    init = #{init}

    #{update}

    #{view}
    """
  end

  def to_code(
        %__MODULE__{
          stage: :add_update_function,
          update: update,
          model_alias: model_alias,
          init: init,
          messages: messages
        } = _program
      ) do
    """
    module Main exposing (main)

    import Html exposing (Html)
    import Browser

    #{model_alias}

    #{messages}

    main : Program ()  Model Msg
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    init : Model
    init = #{init}

    #{update}

    view : Model -> Html Msg
    view _=
        Html.div [] []
    """
  end

  def to_code(
        %__MODULE__{
          messages: messages,
          model_alias: model_alias,
          init: init,
          stage: :add_messages
        } = _program
      ) do
    """
    module Main exposing (main)

    import Html exposing (Html)
    import Browser

    #{model_alias}


    #{messages}

    main : Program () Model ()
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    init : Model
    init = #{init}

    update : () -> Model -> Model
    update _ model =
        model

    view : Model -> Html ()
    view _=
        Html.div [] []
    """
  end

  def to_code(
        %__MODULE__{model_alias: model_alias, init: init, stage: :add_init_function} = _program
      ) do
    """
    module Main exposing (main)

    import Html exposing (Html)
    import Browser

    #{model_alias}

    main : Program () Model ()
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    init : Model
    init = #{init}

    update : () -> Model -> Model
    update _ model =
        model

    view : Model -> Html ()
    view _=
        Html.div [] []
    """
  end

  def to_code(%__MODULE__{stage: :add_model_alias} = _program) do
    """
    module Main exposing (main)

    import Html exposing (Html)
    import Browser

    main : Program () () ()
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    init : ()
    init =
        ()

    update : () -> () -> ()
    update _ model =
        model

    view : () -> Html ()
    view _=
        Html.div [] []
    """
  end


  def to_code(%__MODULE__{stage: :add_imports, imports: imports} = _program) do
    """
    module Main exposing (main)

    import Html exposing (Html)
    import Browser
    #{imports_to_code(imports)}

    main : Program () () ()
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    init : ()
    init =
        ()

    update : () -> () -> ()
    update _ model =
        model

    view : () -> Html ()
    view _=
        Html.div [] []
    """
  end

  defp imports_to_code(imports) do
    imports
    |> Enum.map(& "import #{&1}")
    |> Enum.join("\n")
  end
end
