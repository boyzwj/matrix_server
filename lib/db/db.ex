defmodule DB do
  require Logger
  use Application

  def start(_type, _args) do
    Logger.info("db starting ...")
    {:ok, sup_id} = DB.Sup.start_link([])

    [{DB.Repo, []}, {DB.LocalCache, []}]
    |> Enum.each(fn child ->
      DB.Sup.start_child(child)
    end)

    {:ok, sup_id}
  end
end
