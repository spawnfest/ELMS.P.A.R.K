defmodule ElmSpark.LLM do
  @moduledoc """
  Lightweight wrapper for functions to call OpenAI
  """

  alias ExOpenAI.Chat
  #msgs = [
  #  %{role: "user", content: "Hello!"},
  #  %{role: "assistant", content: "What's up?"},
  #  %{role: "user", content: "What ist the color of the sky?"}
  #]

  # :system is the context for the whole convo
  # :assistant is the chat gpt agents
  # :user is us

  def chat_completions(msgs) do
    #Chat.create_chat_completion(msgs, "gpt-4")
    Chat.create_chat_completion(msgs, "gpt-3.5-turbo")
  end

  def user_message(msg) do
    %{role: "user", content: msg}
  end
  def system_message(msg) do
    %{role: "system", content: msg}
  end
end
