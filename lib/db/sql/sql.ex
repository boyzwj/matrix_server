defmodule DB.SQL do
  require Logger
  use Application
  alias DB.SQL.Sup
  alias DB.SQL.Repo
  alias DB.SQL.LocalCache

  def start(_type, _args) do
    Logger.info("db starting ...")
    {:ok, sup_id} = Sup.start_link([])

    [{Repo, []}, {LocalCache, []}]
    |> Enum.each(fn child ->
      Sup.start_child(child)
    end)

    {:ok, sup_id}
  end
end
