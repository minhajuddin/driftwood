defmodule Driftwood.Controller do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    logs = Enum.flat_map(Driftwood.Store.all, fn [{request_id, log}] -> [to_string(request_id), to_string(log.level), " ", log.message, "\n"] end)
    send_resp(conn, 200, :erlang.iolist_to_binary(logs))
  end
end
