defmodule LiquorTest do
  use ExUnit.Case
  doctest Liquor

  setup_all do

    template = "<%= og.url %>"

    {:ok, params: %{
      content: """
      {% ninjas protecting-your-content-against-ai-scrappers %}
      {% github elixircl/elixircl %}
      {% invalid tag %}
      """,
      template: template,
      fetch: fn url ->
        Req.get!(url)
        |> then(& &1.body)
      end,
      tags: [
        Liquor.Tags.Tag.new("github", template, "https://github.com/"),
        Liquor.Tags.Tag.new("ninjas", template, "https://ninjas.cl/blog/"),
      ]
    }}
  end

  test "that render tags properly", state do

    %{content: content, tags: tags, fetch: fetch} = state[:params]

    assert Liquor.render(content, tags, fetch) == "https://ninjas.cl/blog/protecting-your-content-against-ai-scrappers\nhttps://github.com/ElixirCL/ElixirCL\n{% invalid tag %}\n"
  end
end
