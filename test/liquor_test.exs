defmodule LiquorTest do
  use ExUnit.Case
  doctest Liquor

  setup_all do
    template = "<%= og.url %>"
    template_youtube = "<%= og.video:secure_url %>"

    {:ok,
     params: %{
       content: """
       {% ninjas protecting-your-content-against-ai-scrappers %}
       {% github elixircl/elixircl %}
       {% youtube JNWPsaO4PNM %}
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
         Liquor.Tags.Tag.new("youtube", template_youtube, "https://www.youtube.com/watch?v=")
       ]
     }}
  end

  test "that render tags properly", state do
    %{content: content, tags: tags, fetch: fetch} = state[:params]

    assert Liquor.render(content, tags, fetch) ==
             "https://ninjas.cl/blog/protecting-your-content-against-ai-scrappers\nhttps://github.com/ElixirCL/ElixirCL\nhttps://www.youtube.com/embed/JNWPsaO4PNM\n{% invalid tag %}\n"
  end
end
