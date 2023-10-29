defmodule Elmspark.Elmspark.EllmProgram do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "ellm_programs" do
    field :imports, {:array, :string}
    field :model_fields, :string
    field :model_alias, :string
    field :view, :string
    field :init, :string
    field :messages, :string
    field :update, :string
    field :stage, :string, default: "choose_imports"
    field :error, {:array, :string}
    field :code, :string, virtual: true

    field :global_imports, {:array, :string},
      default: ["Basics", "Browser", "Html", "Html.Attributes", "Html.Events", "Maybe"]

    belongs_to :blueprint, Blueprint
    belongs_to :project, Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(blueprint, attrs) do
    blueprint
    |> cast(attrs, [
      :imports,
      :model_fields,
      :model_alias,
      :view,
      :init,
      :messages,
      :update,
      :stage,
      :error,
      :code,
      :global_imports,
      :blueprint_id,
      :project_id
    ])
    |> validate_required([:project_id, :stage])
  end

  def new(project_id) do
    %__MODULE__{project_id: project_id}
  end

  def set_stage(%__MODULE__{} = program, stage) do
    Map.put(program, :stage, stage) |> Map.put(:id, nil)
  end

  def to_code(
        %__MODULE__{
          stage: "add_view_function",
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
          stage: "add_update_function",
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
          stage: "add_messages",
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
          stage: "add_init_function",
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
        %__MODULE__{stage: "add_model_alias", imports: imports, global_imports: global_imports} =
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
        %__MODULE__{stage: "choose_imports", imports: imports, global_imports: global_imports} =
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
