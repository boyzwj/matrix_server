defmodule Api.Render do
  def markdown(text, title \\ "") do
    {:ok, html_doc, _} = Earmark.as_html(text)
    # style = md_style2()
    """
    <!doctype html>
    <html>
    <head>
    <meta charset="utf-8"/>
    <title>Matr1x #{title}</title>
    <link rel="stylesheet" href="/static/theme/dracula.css" type="text/css"/>
    </head>
    <body>
    <div id = "content">
    #{html_doc}
    </div>
    </body>
    </html>
    """
  end
end
