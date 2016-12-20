defmodule Driftwood.Utils do
  def unix_minutes do
    DateTime.utc_now
    |> DateTime.to_unix
    |> div(60)
  end
end
