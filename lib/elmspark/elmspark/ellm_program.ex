defmodule Elmspark.Elmspark.EllmProgram do
  defstruct [
    :blueprint_id,
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
    global_imports: ["Basics", "Browser", "Html", "Html.Attributes", "Html.Events", "Maybe"]
  ]

  def new(blueprint_id) do
    %__MODULE__{blueprint_id: blueprint_id}
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
          messages: messages,
          imports: imports,
          global_imports: global_imports
        } =
          _program
      ) do
    """
    module Main exposing (main)

    #{global_imports_to_code(global_imports)}
    #{imports_to_code(imports)}

    #{model_alias}

    #{messages}

    main : Program ()  Model Msg
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    #{init}

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
          messages: messages,
          imports: imports,
          global_imports: global_imports
        } = _program
      ) do
    """
    module Main exposing (main)

    #{global_imports_to_code(global_imports)}
    #{imports_to_code(imports)}

    #{model_alias}

    #{messages}

    main : Program ()  Model Msg
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    #{init}

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
          stage: :add_messages,
          imports: imports,
          global_imports: global_imports
        } = _program
      ) do
    """
    module Main exposing (main)

    #{global_imports_to_code(global_imports)}
    #{imports_to_code(imports)}

    #{model_alias}


    #{messages}

    main : Program () Model ()
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    #{init}

    update : () -> Model -> Model
    update _ model =
        model

    view : Model -> Html ()
    view _=
        Html.div [] []
    """
  end

  def to_code(
        %__MODULE__{
          model_alias: model_alias,
          init: init,
          stage: :add_init_function,
          imports: imports,
          global_imports: global_imports
        } = _program
      ) do
    """
    module Main exposing (main)

    #{global_imports_to_code(global_imports)}
    #{imports_to_code(imports)}


    #{model_alias}

    main : Program () Model ()
    main =
        Browser.sandbox { view = view
        , update = update
        , init = init
        }

    #{init}

    update : () -> Model -> Model
    update _ model =
        model

    view : Model -> Html ()
    view _=
        Html.div [] []
    """
  end

  def to_code(
        %__MODULE__{stage: :add_model_alias, imports: imports, global_imports: global_imports} =
          _program
      ) do
    """
    module Main exposing (main)

    #{global_imports_to_code(global_imports)}
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

  def to_code(
        %__MODULE__{stage: :add_imports, imports: imports, global_imports: global_imports} =
          _program
      ) do
    """
    module Main exposing (main)

    #{global_imports_to_code(global_imports)}
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

  defp global_imports_to_code(global_imports) do
    global_imports
    |> Enum.map(&"import #{&1} exposing (..)")
    |> Enum.join("\n")
  end

  defp imports_to_code(imports) do
    imports
    |> Enum.map(&"import #{&1}")
    |> Enum.join("\n")
  end
end
