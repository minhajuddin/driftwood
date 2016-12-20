defmodule Driftwood.Backend do
  @moduledoc "stores the logs sent from Logger"
  alias __MODULE__

  use GenEvent

  defstruct metadata: [], level: nil

  def init(Backend) do
    config = Application.get_env(:logger, :driftwood) || []
    level = Keyword.get(config, :level, :info)
    metadata = Keyword.get(config, :metadata, [])
    # we stitch the logs using the request id
    metadata = Enum.uniq([:request_id|metadata])

    {:ok, %Backend{level: level, metadata: metadata}}
  end

  # ignore when not on the current node
  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, message, timestamp, metadata}}, %Backend{level: log_level}=state) do
    cond do
      not meet_level?(level, log_level) ->
        {:ok, state}
      true ->
        log_event(level, message, timestamp, metadata, state)
        {:ok, state}
    end
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event(event, state) do
    IO.puts "UNHANDLED EVENT : #{inspect event} #{inspect state}"
    {:ok, state}
  end

  ## Helpers
  defp meet_level?(_lvl, nil), do: true

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  def log_event(level, message, timestamp, metadata, state) do
    IO.puts(">> #{message}")
  end

end
