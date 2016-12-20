defmodule Driftwood.Store do
  @moduledoc """
  TODO
  """

  import Driftwood.Utils

  @name __MODULE__

  # start of client api
  # saves the log message in the :minute_requests and the :request_logs tables
  def save(log) do
    :ets.insert(@name, {unix_minutes, log})
  end

  # returns all the logs
  # TODO
  # this is very stupid code. At the moment it just retuns all the data from the table
  # returns [[request_id, log], [request_id2, log2], ...]
  def all do
    :ets.match(@name, :"$1")
  end
  # end of client api

  # GenServer callbacks

  # TODO: extract a behavior to allow users to swap out storage
  # @behaviour Driftwood.Store
  use GenServer

  def start_link do
    GenServer.start_link(@name, [])
  end

  require Logger
  @doc false
  def init(state) do
    :ets.new(@name, [:named_table, :duplicate_bag, :public,
                     write_concurrency: true, read_concurrency: true])

    Logger.flush # flush as soon as our ets table is ready
    {:ok, state}
  end

end
