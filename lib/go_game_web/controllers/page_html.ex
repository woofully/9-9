defmodule GoGameWeb.PageHTML do
  use GoGameWeb, :html
  use Phoenix.Component  # <--- ADD THIS LINE here too

  embed_templates "page_html/*"
end
