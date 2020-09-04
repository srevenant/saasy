defmodule Core.Email.Templates do
  use Core.ContextClient
  import Bamboo.Email

  def getcfg() do
    Application.get_env(:core, :email)
    |> Enum.into(%{})
    |> case do
      # if email_from is a list, it should be a tuple (but json doesn't allow that)
      %{email_from: [name, email]} = cfg ->
        Map.put(cfg, :email_from, {name, email})

      other ->
        other
    end
  end

  def gen_html_email(to, subj, html) do
    cfg = getcfg()

    new_email(to: to, from: cfg.email_from)
    |> subject(subj)
    |> put_header("List-Unsubscribe", cfg.unsubscribe)
    |> html_body("<html><body>#{html}</body></html>")
    |> text_body(text2html(html))
  end

  def text2html(html) do
    # doesn't have to be pretty, very few will actually see it
    html
    |> String.replace(~r/<li>/, "\\g{1}- ", global: true)
    |> String.replace(
      ~r/<\/?\s?br\/?>|<\/\s?p\/?>|<\/\s?li\/?>|<\/\s?div>|<\/\s?h.>/,
      "\\g{1}\n\r",
      global: true
    )
    |> HtmlSanitizeEx.strip_tags()
  end
end
