defmodule Elmspark.Elmspark do
  alias ExOpenAI.Components.Model
  alias __MODULE__.EllmProgram
  alias ElmSpark.LLM
  alias Elmspark.Elmspark.ElmMakeServer
  alias Elmspark.Elmspark.EllmProgram
  alias Elmspark.Elmspark.Blueprint
  alias Elmspark.Elmspark.Events
  alias Elmspark.Repo

  require Logger

  def attempt_with_many(value, fun_with_retry_list) when is_list(fun_with_retry_list) do
    do_attempt_with_many(value, fun_with_retry_list, 0)
  end

  defp do_attempt_with_many(value, [], _attempt) do
    {:ok, value}
  end

  # TODO: fix the infinte errors.
  defp do_attempt_with_many(
         _value,
         [{fun, _max_retries} = head | _rest],
         {feedback_attempt, failures}
       )
       when feedback_attempt > _max_retries do
    {:error, {:max_retries_reached, fun}}
  end

  defp do_attempt_with_many(
         _value,
         [{fun, _max_retries} = head | _rest],
         {feedback_attempt, failures}
       )
       when failures > 3 do
    {:error, {:max_failures_reached, fun}}
  end

  defp do_attempt_with_many(value, [{fun, max_retries} | rest], {feedback_attempt, failures})
       when attempt <= max_retries do
    case fun.(value) do
      {:ok, result} ->
        do_attempt_with_many(result, rest, {0, 0})

      {:error, %EllmProgram{} = program} ->
        do_attempt_with_many(
          program,
          [{fun, max_retries} | rest],
          {feedback_attempt + 1, failures}
        )

      {:error, e} ->
        Logger.error("Error in attempt_with_many: #{inspect(e)}")
        do_attempt_with_many(value, [{fun, max_retries} | rest], {feedback_attempt, failures + 1})
    end
  end

  def gen_app(project_id, blueprint) do
    Logger.info("Generating app for project #{project_id}")

    attempt_with_many(project_id, [
      # 0 retries for gen_imports
      {&gen_imports(blueprint, &1), 0},
      # 3 retries for gen_model
      {&gen_model(blueprint, &1), 0},
      # 2 retries for gen_init
      {&gen_init/1, 0},
      # 5 retries for gen_msg
      {&gen_msg/1, 0},
      # 3 retries for gen_update
      {&gen_update/1, 0},
      # 2 retries for gen_view
      {&gen_view/1, 0},
      # 1 retry for gen_js
      {&gen_js/1, 0}
    ])
  end

  def gen_imports(blueprint, project_id) do
    available_modules = Elmspark.ElmDocumentationServer.available_modules()
    Logger.info("Generating imports for project #{project_id}")

    project_id
    |> EllmProgram.new()
    |> EllmProgram.set_stage("choose_imports")
    |> fetch_imports_from_llm(blueprint, available_modules)
    |> case do
      {:ok, ellm_program} ->
        ellm_program
        |> EllmProgram.changeset(%{})
        |> Repo.insert()

        Events.broadcast("gen_imports", ellm_program)
        {:ok, ellm_program}

      error ->
        error
    end
  end

  def gen_model(blueprint, ellm_program) do
    Logger.info("Generating model for project #{ellm_program.project_id}")

    ellm_program
    |> EllmProgram.set_stage("add_model_alias")
    |> fetch_fields_from_llm(blueprint)
    |> convert_fields_to_elm_type_alias()
    |> compile_elm_program()
    |> respond_to_feedback_with_llm
    |> case do
      {:ok, ellm_program} ->
        ellm_program
        |> EllmProgram.changeset(%{})
        |> Repo.insert()

        Events.broadcast("gen_model", ellm_program)
        {:ok, ellm_program}

      error ->
        error
    end
  end

  def gen_init(ellm_program) do
    Logger.info("Generating init for project #{ellm_program.project_id}")

    ellm_program
    |> EllmProgram.set_stage("add_init_function")
    |> fetch_init_from_llm()
    |> compile_elm_program()
    |> respond_to_feedback_with_llm
    |> case do
      {:ok, ellm_program} ->
        ellm_program
        |> EllmProgram.changeset(%{})
        |> Repo.insert()

        Events.broadcast("gen_init", ellm_program)
        {:ok, ellm_program}

      error ->
        error
    end
  end

  def gen_msg(ellm_program) do
    Logger.info("Generating msg for project #{ellm_program.project_id}")

    ellm_program
    |> EllmProgram.set_stage("add_messages")
    |> fetch_messages_from_llm()
    |> compile_elm_program()
    |> respond_to_feedback_with_llm
    |> case do
      {:ok, ellm_program} ->
        ellm_program
        |> EllmProgram.changeset(%{})
        |> Repo.insert()

        Events.broadcast("gen_msg", ellm_program)
        {:ok, ellm_program}

      error ->
        error
    end
  end

  def gen_update(ellm_program) do
    Logger.info("Generating update for project #{ellm_program.project_id}")

    ellm_program
    |> EllmProgram.set_stage("add_update_function")
    |> fetch_update_from_llm()
    |> compile_elm_program()
    |> respond_to_feedback_with_llm
    |> case do
      {:ok, ellm_program} ->
        ellm_program
        |> EllmProgram.changeset(%{})
        |> Repo.insert()

        Events.broadcast("gen_update", ellm_program)
        {:ok, ellm_program}

      error ->
        error
    end
  end

  def gen_view(ellm_program) do
    Logger.info("Generating view for project #{ellm_program.project_id}")

    ellm_program
    |> EllmProgram.set_stage("add_view_function")
    |> fetch_view_from_llm()
    |> compile_elm_program()
    |> respond_to_feedback_with_llm
    |> case do
      {:ok, ellm_program} ->
        ellm_program
        |> EllmProgram.changeset(%{})
        |> Repo.insert()

        Events.broadcast("gen_view", ellm_program)
        {:ok, ellm_program}

      error ->
        error
    end
  end

  def gen_js(ellm_program) do
    with {:ok, _idk} <-
           ElmMakeServer.gen_js(ellm_program.project_id, EllmProgram.to_code(ellm_program)) do
      {:ok, ellm_program}
    else
      _ ->
        {:error, ellm_program}
    end
  end

  def get_blueprint(id), do: Repo.get(Blueprint, id)

  def create_blueprint(attrs) do
    %Blueprint{}
    |> Blueprint.changeset(attrs)
    |> Repo.insert()
  end

  def change_blueprint(blueprint, attrs) do
    blueprint
    |> Blueprint.changeset(attrs)
  end

  defp fetch_imports_from_llm(%EllmProgram{} = ellm_program, blueprint, available_modules) do
    globally_available_imports = ellm_program.global_imports
    additional_possibilities = available_modules -- globally_available_imports

    globally_available_system_msg =
      LLM.system_message(
        "The following modules are always globally available: #{Enum.join(globally_available_imports, "@@")}"
      )

    additional_system_msg =
      LLM.system_message(
        "The additional modules are #{Enum.join(additional_possibilities, "@@")}."
      )

    msg = generate_imports(blueprint, &LLM.user_message/1)
    res = LLM.chat_completions([globally_available_system_msg, additional_system_msg, msg])

    case res do
      {:ok, %{choices: [%{message: %{content: selected_imports}}]}} ->
        imports =
          (String.split(selected_imports, "@@") -- ellm_program.global_imports)
          |> MapSet.new()
          |> MapSet.intersection(MapSet.new(available_modules))
          |> MapSet.to_list()

        {:ok, %{ellm_program | imports: imports}}

      {:error, e} ->
        {:error, e}
    end
  end

  defp fetch_fields_from_llm(%EllmProgram{} = ellm_program, blueprint) do
    msg = generate(blueprint, &LLM.user_message/1)
    res = LLM.chat_completions([msg])

    case res do
      {:ok, %{choices: [%{message: %{content: fields}}]}} ->
        %{ellm_program | model_fields: fields}

      {:error, e} ->
        {:error, e}
    end
  end

  defp fetch_update_from_llm(ellm_program) do
    fetch_from_llm(ellm_program, &generate_update(&1, &2), :update)
  end

  def respond_to_feedback_with_llm({:ok, _ok}) do
    {:ok, _ok}
  end

  def respond_to_feedback_with_llm(
        {:error, %EllmProgram{stage: "add_model_alias"} = ellm_program}
      ) do
    msg = generate_feedback(ellm_program, &LLM.user_message/1)
    res = LLM.chat_completions([msg])

    case res do
      {:ok, %{choices: [%{message: %{content: feedback}}]}} ->
        %{ellm_program | model_alias: feedback}
        |> compile_elm_program()

      {:error, e} ->
        {:error, e}
    end
  end

  def respond_to_feedback_with_llm(
        {:error, %EllmProgram{stage: "add_init_function"} = ellm_program}
      ) do
    msg = generate_feedback(ellm_program, &LLM.user_message/1)
    res = LLM.chat_completions([msg])

    case res do
      {:ok, %{choices: [%{message: %{content: feedback}}]}} ->
        %{ellm_program | init: feedback}
        |> compile_elm_program()

      # Broadcast.event(:feedback_received, %{})
      {:error, e} ->
        {:error, e}
    end
  end

  def respond_to_feedback_with_llm({:error, %EllmProgram{stage: "add_messages"} = ellm_program}) do
    msg = generate_feedback(ellm_program, &LLM.user_message/1)
    res = LLM.chat_completions([msg])

    case res do
      {:ok, %{choices: [%{message: %{content: feedback}}]}} ->
        %{ellm_program | messages: feedback}
        |> compile_elm_program()

      {:error, e} ->
        {:error, e}
    end
  end

  def respond_to_feedback_with_llm(
        {:error, %EllmProgram{stage: "add_update_function"} = ellm_program}
      ) do
    msg = generate_feedback(ellm_program, &LLM.user_message/1)
    res = LLM.chat_completions([msg])

    case res do
      {:ok, %{choices: [%{message: %{content: feedback}}]}} ->
        %{ellm_program | update: feedback}
        |> compile_elm_program()

      {:error, e} ->
        {:error, e}
    end
  end

  def respond_to_feedback_with_llm(
        {:error, %EllmProgram{stage: "add_view_function"} = ellm_program}
      ) do
    msg = generate_feedback(ellm_program, &LLM.user_message/1)
    res = LLM.chat_completions([msg])

    case res do
      {:ok, %{choices: [%{message: %{content: feedback}}]}} ->
        %{ellm_program | view: feedback}
        |> compile_elm_program()

      {:error, e} ->
        {:error, e}
    end
  end

  defp fetch_view_from_llm(ellm_program) do
    fetch_from_llm(ellm_program, &generate_view(&1, &2), :view)
  end

  defp fetch_init_from_llm(ellm_program) do
    fetch_from_llm(ellm_program, &generate_init(&1, &2), :init)
  end

  def fetch_messages_from_llm(ellm_program) do
    fetch_from_llm(ellm_program, &generate_messages(&1, &2), :messages)
  end

  defp convert_messages_to_elm_type_alias(%EllmProgram{messages: messages} = ellm_program) do
    fetch_from_llm(
      ellm_program,
      fn _ -> generate_msg_alias(messages, &LLM.user_message/1) end,
      :msg
    )
  end

  defp convert_fields_to_elm_type_alias(%EllmProgram{model_fields: fields} = ellm_program) do
    msg = generate_type_alias(fields, &LLM.user_message/1)
    res = LLM.chat_completions([msg])

    case res do
      {:ok, %{choices: [%{message: %{content: type_alias}}]}} ->
        %{ellm_program | model_alias: type_alias}

      {:error, e} ->
        {:error, e}
    end
  end

  defp convert_fields_to_elm_type_alias(%EllmProgram{model_fields: fields} = ellm_program) do
    fetch_from_llm(
      ellm_program,
      fn _ -> generate_type_alias(fields, &LLM.user_message/1) end,
      :model_alias
    )
  end

  defp fetch_from_llm(ellm_program, generator_function, attribute_to_update) do
    msg = generator_function.(ellm_program, &LLM.user_message/1)

    available_functions_msg =
      """
      You must used qualified imports.

      For example:
        If you want to use the function get for the import Array do: Array.get
        If you want to use the type Array for the import Array do: Array.Array
      """
      |> LLM.system_message()

    res = LLM.chat_completions([available_functions_msg, msg])

    case res do
      {:ok, %{choices: [%{message: %{content: content}}]}} ->
        Map.put(ellm_program, attribute_to_update, content)

      {:error, e} ->
        {:error, e}
    end
  end

  def generate_imports(
        %{
          title: title,
          description: description,
          works: works
        },
        present
      ) do
    message = """
    Given the title: #{title}, the description: #{description}, and the user acceptance criteria #{works}, pick Modules from the Available Modules that you will need to build this project in Elm.

    Return the Available modules that separted by "@@". Your response should look something like this:
    "Module1@@Module2@@Module3"
    """

    present.(message)
  end

  def generate(
        %{
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
    DO NOT include the Msg in your response.
    Only inlcude basic types like String, Int, Float, Bool, etc.
    DO NOT rely on custom created types.
    """

    present.(message)
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

  def generate_msg_alias(messages, present) do
    message = """
    Turn this list of messages: #{messages} into a Elm type alias called Msg. Each message should be on its own line.

    So for example if the messages given were:
    ```
      [ ("ChangeColor", String)
      , ("ChangeSize", Int)
      ]
    ```

    Then your response should look like this:
    ```
    type Msg = ChangeColor String | ChangeSize Int
    Keep it on one line.
    """

    present.(message)
  end

  def generate_feedback(ellm_program, present) do
    message = """
    Given this elm error message:
    #{ellm_program.error}
    Please provide a correction on how you would fix the error message
    This was your task
    #{stage_task(ellm_program)}

    """

    present.(message)
  end

  def stage_task(%EllmProgram{stage: "add_model_alias"} = program) do
    message = """
    Turn this list of fields: #{program.model_fields} into a Elm type alias called Model. Each field should be on its own line.

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
  end

  def stage_task(%EllmProgram{stage: "add_init_function"} = program) do
    message = """
    Turn this list of fields: #{program.model_fields} into a Elm type alias called Model. Each field should be on its own line.

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
  end

  def stage_task(%EllmProgram{stage: "add_messages"} = program) do
    message = """
    Turn this list of messages: #{program.messages} into a Elm type alias called Msg. Each message should be on its own line.

    So for example if the messages given were:
    ```
      [ ("ChangeColor", String)
      , ("ChangeSize", Int)
      ]
    ```

    Then your response should look like this:
    ```
    type Msg = ChangeColor String | ChangeSize Int
    Keep it on one line.
    """
  end

  def stage_task(%EllmProgram{stage: "add_update_function"} = program) do
    message = """
    Given the following model alias:
    #{program.model_alias}
    and the
    #{program.messages}
    Please generate the update function for the Elm Program.
    Only respond with the expression that is the update function.
    For example:
    type alias Model = { name : String }
    type Msg = ChangeName String
    You would respond with:

    update : Msg -> Model -> Model
    update msg model =
        case msg of
            ChangeName name ->
            { model | name = name }


    """
  end

  def stage_task(%EllmProgram{stage: "add_view_function"} = program) do
    message = """
    Given the following model alias:
    #{program.model_alias}
    and the
    #{program.messages}
    Please generate the view function for the Elm Program.
    Only respond with the expression that is the view function.
    For example:
    type alias Model = { name : String }
    type Msg = ChangeName String
    You would respond with:

    view : Model -> Html Msg
    view model =
        div []
            [ input [ onInput ChangeName ] []
            , div [] [ text model.name ]
            ]
    """
  end

  def generate_init(
        ellm_program,
        present
      ) do
    message = """
    Given the following model alias:
    #{ellm_program.model_alias}
    Please generate the init function for the Elm Program.
    Only respond with the expression that is the init function.
    For example:
    type alias Model = { name : String }
    You would respond with:

    init: Model
    init = 
      { name = "Bob" }
    """

    present.(message)
  end

  def generate_messages(
        ellm_program,
        present
      ) do
    message = """
    Given the following model alias:
    #{ellm_program.model_alias}
    Please generate the messages for the Elm Program.
    Only respond with the expression that is the messages.
    For example:
    type alias Model = { name : String }
    You would respond with:

    type Msg = ChangeName String
    """

    present.(message)
  end

  def generate_update(
        ellm_program,
        present
      ) do
    message = """
    Given the following model alias:
    #{ellm_program.model_alias}
    and the
    #{ellm_program.messages}
    Please generate the update function for the Elm Program.
    Only respond with the expression that is the update function.
    For example:
    type alias Model = { name : String }
    type Msg = ChangeName String
    You would respond with:

    update : Msg -> Model -> Model
    update msg model =
        case msg of
            ChangeName name ->
            { model | name = name }


    """

    present.(message)
  end

  def generate_view(ellm_program, present) do
    message = """
    Given the following model alias:
    #{ellm_program.model_alias}
    and the
    #{ellm_program.messages}
    Please generate the view function for the Elm Program.
    Only respond with the expression that is the view function.
    For example:
    type alias Model = { name : String }
    type Msg = ChangeName String
    You would respond with:

    view : Model -> Html Msg
    view model =
        div []
            [ input [ onInput ChangeName ] []
            , div [] [ text model.name ]
            ]
    """

    present.(message)
  end

  defp compile_elm_program(%EllmProgram{project_id: blueprint_id} = ellm_program, opts \\ []) do
    program_test = EllmProgram.to_code(ellm_program)
    output = Keyword.get(opts, :output, nil)

    if output do
      case ElmMakeServer.gen_js(blueprint_id, program_test) do
        {:ok, _output} -> {:ok, %{ellm_program | code: program_test}}
        {:error, e} -> {:error, e}
      end
    else
      case ElmMakeServer.make_elm(blueprint_id, program_test) do
        {:ok, output} ->
          Logger.info("Successfully compiled Elm program Stage:#{inspect(ellm_program.stage)}")

          {:ok, %{ellm_program | code: program_test}}

        {:error, e} ->
          Logger.error(
            "Elm Compile Failed #{inspect(ellm_program)} Stage:#{inspect(ellm_program.stage)}"
          )

          with {:ok, decoded} <- e |> Jason.decode() do
            [hd_error | _] = Map.get(decoded, "errors")

            decoded_error =
              Enum.map(hd_error["problems"], fn problem ->
                %{title: problem["title"], message: problem["message"]}
              end)
              |> Enum.flat_map(fn x -> Enum.filter(x.message, fn x -> not is_map(x) end) end)

            {:error, %{ellm_program | error: decoded_error}}
          end
      end
    end
  end
end
