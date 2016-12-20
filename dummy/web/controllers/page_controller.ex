defmodule Dummy.PageController do
  use Dummy.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
