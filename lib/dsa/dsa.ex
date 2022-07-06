defmodule Dsa do
  use Common
  defstruct resources: nil, port_from: 13_000, workers: %{}, now: nil

  def init() do
    resources = LimitedQueue.new(10_000)
    %Dsa{resources: resources}
  end

  def secondloop(state) do
    state
  end

  def start_game(state, args) do
    Logger.debug("start game, args: #{inspect(args)}")
    {:ok, state}
  end
end
