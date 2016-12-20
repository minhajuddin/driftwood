defmodule Driftwood.Backend do
  @moduledoc "stores the logs sent from Logger"
  alias __MODULE__

  use GenEvent

  defstruct metadata: [], level: nil, buffer: [], buffer_logs: true

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

  def handle_event({level, _gl, {Logger, message, timestamp, metadata}}, %Backend{level: log_level, buffer_logs: buffer_logs}=state) do
    cond do
      not meet_level?(level, log_level) ->
        {:ok, state}
      buffer_logs ->
        {:ok, buffer_log(level, message, timestamp, metadata, state)}
      true ->
        log_event(level, message, timestamp, metadata, state)
        {:ok, state}
    end
  end

  def handle_event(:flush, %{buffer_logs: false} = state) do
    {:ok, state}
  end

  def handle_event(:flush, %{buffer: buffer} = state) do
    for log <- buffer, do: Driftwood.Store.save(log)
    {:ok, %{state | buffer: [], buffer_logs: false}}
  end

  def handle_event(event, state) do
    IO.puts "DRIFTWOOD_UNHANDLED_EVENT #{inspect event} #{inspect state}"
    {:ok, state}
  end

  ## Helpers
  defp meet_level?(_lvl, nil), do: true

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp log_event(level, message, timestamp, metadata, state) do
    request_id = Keyword.get(metadata, :request_id) || "OUT_OF_BAND"
    Driftwood.Store.save %{
      level: level,
      message: :erlang.iolist_to_binary(message),
      timestamp: timestamp,
      metadata: metadata,
      request_id: request_id,
    }
  end

  defp buffer_log(level, message, timestamp, metadata, state) do
    request_id = Keyword.get(metadata, :request_id) || "OUT_OF_BAND"
    %{state | buffer: [%{
       level: level,
       message: :erlang.iolist_to_binary(message),
       timestamp: timestamp,
       metadata: metadata,
       request_id: request_id,
     }|state.buffer] }
  end

end
