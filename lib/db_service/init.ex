defmodule DBInit do
  require Logger
  alias DBInit.TableDef
  alias Memento.Table

  def initialize(db_list) do
    case db_list do
      [] ->
        create_database(db_list)

      _ ->
        copy_database(db_list)
    end
  end

  def create_database(_store_list) do
    Logger.info("Creating database...")
    Memento.stop()
    Memento.Schema.create([node()])
    Memento.start()
    :mnesia_rocksdb.register()
    create_tables()
  end

  def copy_database(store_list) do
    Memento.start()
    :mnesia_rocksdb.register()
    {:ok, _} = Memento.add_nodes(store_list)
    Table.set_storage_type(:schema, node(), :disc_copies)
    copy_tables()
  end

  defp create_tables() do
    Logger.info("Creating tables...", ansi_color: :yellow)
    :mnesia.create_table(GID, [{:disc_copies, [node()]}, attributes: [:id, :value]])

    for {tab, type} <- TableDef.tables() do
      with :ok <- Table.create(tab, [{type, [node()]}]) do
        Logger.info("Table [#{inspect(tab)}] create ok ..", ansi_color: :yellow)
      else
        {:error, {:already_exists, _}} ->
          Logger.info("Load exist table [#{inspect(tab)}] ", ansi_color: :yellow)
          check_update_table(tab)

        {:error, reason} ->
          Logger.error("Table init error #{inspect(reason)}")
      end

      tab
    end
    |> Table.wait()
  end

  defp copy_tables() do
    Logger.info("Copying tables...", ansi_color: :yellow)
    :mnesia.add_table_copy(GID, node(), :disc_copies)

    for {tab, type} <- TableDef.tables() do
      with :ok <- Table.create_copy(tab, node(), type) do
        Logger.info("copy table [#{inspect(tab)}] finish", ansi_color: :yellow)
      else
        {:error, {:already_exists, _, _}} ->
          Logger.info("Load exist table [#{inspect(tab)}] ", ansi_color: :yellow)
          check_update_table(tab)

        {:error, {:no_exists, {^tab, _}}} ->
          :ok = Table.create(tab, [{type, [node() | Node.list()]}])
          Logger.info("create new table [#{inspect(tab)}] ", ansi_color: :yellow)

        {:error, reason} ->
          Logger.error("Table init error #{inspect(reason)}")
      end

      tab
    end
    |> Table.wait()
  end

  defp check_update_table(tab) do
    old = Table.info(tab, :attributes)
    new = tab.__info__.attributes

    if old != new do
      Table.wait([tab], 5000)

      Logger.info("Table [#{inspect(tab)}] column changed, updating ...",
        ansi_color: :yellow
      )

      :mnesia.transform_table(
        tab,
        fn data ->
          [tab | values] = Tuple.to_list(data)
          values = old |> Enum.zip(values)

          struct(tab, values)
          |> Memento.Query.Data.dump()
        end,
        new
      )
    end
  end
end
