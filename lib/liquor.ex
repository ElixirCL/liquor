defmodule Liquor do
  @moduledoc """
    Contains the main functions to initialize and render the tags.
  """
  alias Liquor.Tags.Tag

  @typedoc "Initialized the map with the content, tags and fetch. Fetch must call the URL and return the HTML string to extract the OpenGraph data."
  @type t :: %{content: String.t(), tags: list(Tag.t()), fetch: (String.t() -> String.t())}

  @doc """
  Initializes the Liquor map with content, tags and fetch function.
  """
  @spec init(String.t(), list(Tag.t()), (String.t() -> String.t())) :: Liquor.t()
  def init(content, tags, fetch) do
    %{content: content, fetch: fetch, tags: tags}
  end

  @doc """
    Initializes, finds and render the tags
  """
  @spec render(String.t(), list(Tag.t()), (String.t() -> String.t())) :: String.t()
  def render(content, tags, fetch) do
    Liquor.init(content, tags, fetch)
    |> Liquor.Tags.find()
    |> Liquor.Tags.render()
  end
end
