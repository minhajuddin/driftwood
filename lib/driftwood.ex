defmodule Driftwood do
  @moduledoc false

  use GenEvent

  @default_format "$dateT$time [$level] $metadata $message\n"

  defstruct level: nil, format: @default_format, metadata: nil

  #defstruct [format: nil, metadata: nil, level: nil, colors: nil, device: nil,
             #max_buffer: nil, buffer_size: 0, buffer: [], ref: nil, output: nil]

  def init({__MODULE__, opts}) when is_list(opts) do
    config = Keyword.merge(Application.get_env(:logger, :driftwood), opts)
    {:ok, init(config, %__MODULE__{})}
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, state) do
    %{level: log_level} = state
    cond do
      meet_level?(level, log_level) ->
        # do the logging
        output = format_event(level, msg, ts, md, state)
        IO.puts(output)
    end
    {:ok, state}
  end

  def handle_event(:flush, state) do
    # we don't buffer
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  defp configure(options, state) do
    config = Keyword.merge(Application.get_env(:logger, :console), options)
    Application.put_env(:logger, :driftwood, config)
    init(config, state)
  end

  defp init(config, state) do
    level = Keyword.get(config, :level)
    format = Logger.Formatter.compile Keyword.get(config, :format)
    metadata = Keyword.get(config, :metadata, [])

    %{state | format: format, metadata: Enum.reverse(metadata),
              level: level}
  end

  defp meet_level?(_lvl, nil), do: true

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp format_event(level, msg, ts, md, %{format: format, metadata: keys}) do
    Logger.Formatter.format(format, level, msg, ts, take_metadata(md, keys))
  end

  defp take_metadata(metadata, keys) do
    Enum.reduce keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error     -> acc
      end
    end
  end

end
