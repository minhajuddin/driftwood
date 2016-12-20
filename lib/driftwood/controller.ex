defmodule Driftwood.Controller do
  @behaviour Plug
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, render_index([logs: Driftwood.Store.all]))
  end

  require EEx
  EEx.function_from_file(:defp, :render_index, Path.join(__DIR__, "templates/index.html.eex"), [:assigns], trim: true)
end
