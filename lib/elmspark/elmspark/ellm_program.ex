defmodule Elmspark.Elmspark.EllmProgram do
  defstruct [
    :model_fields,
    :model_alias,
    :view,
    :init,
    :messages,
    :update,
    :stage,
    :code
  ]

  def new() do
    %__MODULE__{}
  end

  def set_stage(%__MODULE__{} = program, stage) do
    Map.put(program, :stage, stage)
  end

  def to_string(
        %__MODULE__{
          stage: 6,
          view: view,
          update: update,
          model_alias: model_alias,
          init: init,
          messages: messages
        } =
          _program
      ) do
    """
    module Main exposing (main)

    import Html exposing (Html)
    import Html exposing (..)
    import Html.Attributes exposing (..)
    import Html.Events exposing (..)
    import Browser

    #{model_alias}

    #{messages}

    main : Program ()  Model Msg
    main =
        Browser.sandbox {
        view = view
        , update = update
        , init = init
        }

    init : Model
    init = #{init}

    update : Msg -> Model -> Model
    update msg model = #{update}



    #{view}
    """
  end

  def to_string(
        %__MODULE__{
          stage: 5,
          update: update,
          model_alias: model_alias,
          init: init,
          messages: messages
        } =
          _program
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

    update : Msg -> Model -> Model
    update msg model = #{update}

    view : Model -> Html Msg
    view _=
        Html.div [] []
    """
  end

  def to_string(
        %__MODULE__{stage: 4, model_alias: model_alias, init: init, messages: messages} = _program
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

    update : Msg -> Model -> Model
    update _ model =
        model

    view : Model -> Html Msg
    view _=
        Html.div [] []
    """
  end

  def to_string(%__MODULE__{model_alias: model_alias, init: init, stage: 3} = _program) do
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

  def to_string(%__MODULE__{model_alias: model_alias, stage: 2} = _program) do
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
    init =
        Debug.todo "init"

    update : () -> Model -> Model
    update _ model =
        model

    view : Model -> Html ()
    view _=
        Html.div [] []
    """
  end

  def to_string(%__MODULE__{stage: 1} = _program) do
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
end
