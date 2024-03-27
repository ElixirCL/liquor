defmodule Liquor.Tags do
  @moduledoc """
  Tags finds the "Liquor Tags" inside a plain text document.
  Eg: `{% embed https://ninjas.cl %}` then fetches the open graph
  data from the url and renders using a pseudo EEx template.
  """
  alias __MODULE__
  alias __MODULE__.Tag

  # MARK: - Typedefs
  @type t :: list(%{tags: list(Tag.t()), content: String.t()})

  # MARK: - Helpers

  defp get_matches(tag, content) do
    # Get the tags present in the document
    # Eg: {% embed https://ninjas.cl %}
    # Dot (.) is escaped since is a valid regex char
    Regex.scan(~r/\{%\s*#{String.replace(tag, ".", "\.")}\s*([\S]+)\s*%\}/u, content)
    |> then(fn
      nil ->
        []

      matches ->
        matches
        # We convert the match to a Map for easier use. Parse the URI string.
        |> Enum.map(fn [match, uri] -> %{match: match, uri: URI.parse(uri)} end)
    end)
  end

  defp parse(tags, content) do
    # Parses the content to find each tag
    # Returns a map with the result
    tags
    |> Enum.map(fn tag -> %{tag: tag, matches: get_matches(tag.tag, content)} end)
  end

  defp fetch_data_for_each_match(tag, matches, fetch) do
    Task.await_many(
      Enum.map(matches, fn %{uri: uri} = match ->
        Task.async(fn ->
          # We can use the full URL or just a URI path
          # Depending on the tag we use the URI from the tag to
          # create the final URI.
          # If is already full URI then we just use it.
          # Finally fetch the OpenGraph data.
          og =
            case uri.scheme do
              nil -> URI.parse("#{URI.to_string(tag.uri)}#{URI.to_string(uri)}")
              _ -> uri
            end
            |> URI.to_string()
            |> fetch.()
            |> OpenGraph.parse()

          # We render the final output string for the tag
          # and create a new Map with the match, opengraph and output data
          bindings = [
            og: og
          ]

          Map.merge(match, %{og: og, output: Tag.render(tag, bindings)})
        end)
      end),
      :infinity
    )
  end

  # MARK: - Public API

  @doc """
  Finds the tags inside a document.
  And generate an output with the open graph data for each match.

  ## Examples

      iex> Liquor.init("{% embed https://ninjas.cl %}", [Liquor.Tags.Tag.new("embed", "<%= og.url %>")], fn url -> Req.get!(url) |> then(& &1.body) end) |> Liquor.Tags.find() |> then(& List.first(&1.tags)) |> then(& List.first(&1.matches).output)
      "https://ninjas.cl"
  """
  @spec find(Liquor.t()) :: %{content: String.t(), tags: list(Tag.t())}
  def find(init) do
    init.tags
    |> parse(init.content)
    |> Enum.map(fn %{tag: tag, matches: matches} ->
      # Return the tag with the complete data
      %{tag: tag, matches: fetch_data_for_each_match(tag, matches, init.fetch)}
    end)
    |> then(&%{content: init.content, tags: &1})
  end

  @doc """
  Given a list of tags with open graph data.
  Replace each tag with the rendered output from the tag.

  ## Examples

      iex> Liquor.init("{% embed https://ninjas.cl %}", [Liquor.Tags.Tag.new("embed", "<%= og.url %>")], fn url -> Req.get!(url) |> then(& &1.body) end) |> Liquor.Tags.find() |> Liquor.Tags.render()
      "https://ninjas.cl"
  """
  @spec render(Tags.t()) :: String.t()
  def render(results) do
    results.tags
    |> Enum.filter(fn tag -> tag.matches != [] end)
    |> Enum.flat_map(fn item -> item.matches end)
    |> Enum.reduce(results.content, fn item, acc ->
      String.replace(acc, item.match, item.output)
    end)
  end
end
