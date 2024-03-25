defmodule Liquor.Tags.Tag do
  @moduledoc """
  The Tag module holds the structure for a Tag.
  A Tag consist of a identification string (tag)
  a URI for OpenGraph (base_url) and a pseudo
  EEx template string.
  """

  alias __MODULE__

  defstruct ~w(tag uri template)a

  @typedoc "A Tag consists of a string identification (tag), an URI and an pseudo EEx template string"
  @type t :: %Tag{tag: String.t(), uri: URI.t(), template: String.t()}

  @doc """
  Helps creating a new Tag.
  The template is a string with pseudo EEx (for safer evaluation).
  The URI is a string that can be used as a base URL
  for all the tags when fetching the Open Graph data.

  ## Examples
      iex> Liquor.Tags.Tag.new("embed", "<%= og.title %>")
      %Liquor.Tags.Tag{tag: "embed", template: "<%= og.title %>", uri: %URI{}}
  """
  @spec new(String.t(), String.t(), String.t()) :: Tag.t()
  def new(tag, template, uri \\ "") do
    %Tag{tag: tag, uri: URI.parse(uri), template: template}
  end

  @doc """
  A safer way to replace the tags
  Instead of EEx.eval_string()
  This function is recommended to use cases
  when the user can send input.

  The template string can use a pseudo EEx tags.
  Example `<%= og.title %>` for rendering the
  open graph data.

  Check https://github.com/bitboxer/opengraph_parser/blob/main/lib/open_graph.ex#L55
  for all the available keys.

  ## Examples
      iex> Liquor.Tags.Tag.render(Liquor.Tags.Tag.new("embed", "<%= og.title %>"), [og: %OpenGraph{title: "A Sample Title"}])
      "A Sample Title"
  """
  @spec render(Tag.t(), list(Keyword.t())) :: String.t()
  def render(%Tag{} = tag, bindings) do
    og =
      Keyword.get(bindings, :og, [])
      |> Map.from_struct()

    Enum.reduce(og, tag.template, fn {key, value}, acc ->
      String.replace(
        acc,
        ~r/<%=\s*og\.#{key}\s*%>/u,
        case value do
          nil -> ""
          value -> to_string(value)
        end
      )
    end)
  end
end
