defmodule Dsa do
  use Common
  defstruct resources: nil, workers: %{}, now: nil

  def init() do
    %Dsa{}
  end

  def secondloop(state) do
    state
  end

  def start_game(state, args) do
    Logger.debug("start game, args: #{inspect(args)}")
    {:ok, state}
  end
end
