# ELMS.P.A.R.K


# TODOs:

- Elm Documentation Server
  - Integrate

[x] Offer the LLM a set of choices of modules that it thinks it will need.
- Collect imports (Also need to match aliases, etc.)

- DynamicSupervisor manages a genserver for each project / blueprint.
- Each project will have a directory that is used for doing work.
  - Blueprint id?
  - Spin up each project's genserver with the blueprint_id, via tuple


CORE LOOP

We could ask the LLM to split the 

blueprint

- title : string
- description :string
- how do you know it works (Acceptance Criteria) :string


Example: As a User I am able to Click "Yes" and a popup shows up and says "You have won"

- I can click on a square and it turns to an oval.


into 3 core questions

What needs to be seen? (view) 

Can you split the above into a set of functions that are needed between 3 - 5?

What needs to be stored? (model) 

What needs to change?(update)


We can then have downstream questions that build on top of that possibly? 



Shell:

```elm
module Shell exposing (main)

main : Application
main =
    { view = view
    , update = update
    , init = init
    }
```

```elixit
%ElmProgram{}
-- |> reduce(shell(), &append_bottom/2)
|> then(pipeline)
```

```bash
# WITH Land
text
|> elm_format
|> elm-make
```

|> persist_js_for_slug


Everytime we 

%Shell{
}


InProgress shell

```elm
module ModelShell exposing (main)

main : Application
main =
    { view = view
    , update = update
    , init = init
    }

init : Model
init _=
    Debug.todo "init"

update : () -> Model -> (Model, Cmd Msg)
update _ _=
    Debug.todo "update

view : Model -> Html Msg
view _=
    Debug.todo "view"
```
- gen(Model)


```elm
module InitShell exposing (main)

main : Application
main =
    { view = view
    , update = update
    , init = init
    }

update : () -> Model -> (Model, Cmd Msg)
update _ _=
    Debug.todo "update

view : Model -> Html Msg
view _=
    Debug.todo "view"
```
- append(Model)
- gen(init)


```elm
module MsgShell exposing (main)

main : Application
main =
    { view = view
    , update = update
    , init = init
    }

update : () -> Model -> (Model, Cmd Msg)
update _ _=
    Debug.todo "update

view : Model -> Html Msg
view _=
    Debug.todo "view"
```
- append(Model)
- append(init)
- gen(Msg)

```elm
module UpdateShell exposing (main)

main : Application
main =
    { view = view
    , update = update
    , init = init
    }

view : Model -> Html Msg
view _=
    Debug.todo "view"
```
- append(Model)
- append(init)
- append(Msg)
- gen(update)


```elm
module ViewShell exposing (main)

main : Application
main =
    { view = view
    , update = update
    , init = init
    }
```
- append(Model)
- append(init)
- append(Msg)
- append(update)
- gen(view)


Dependencies

- Model
What is the data?
- init
What is the initial state for that data?
- Msg
How does the data change? What messages would need to be triggered from the view.

- update
- view
