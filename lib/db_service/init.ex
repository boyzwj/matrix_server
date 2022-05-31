defmodule DBInit do
  require Logger
  alias DBInit.TableDef
  alias Memento.Table

  def initialize(contact) do
    db_list = GenServer.call({DBContact.NodeManager, contact}, :db_list)

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
    create_tables()
  end

  def copy_database(store_list) do
    Memento.start()
    {:ok, _} = Memento.add_nodes(store_list)
    Table.set_storage_type(:schema, node(), :disc_copies)
    copy_tables()
  end

  defp create_tables() do
    Logger.info("Creating tables...", ansi_color: :yellow)

    for tab <- TableDef.tables() do
      with :ok <- Table.create(tab, disc_copies: [node()]) do
        Logger.info("Table [#{inspect(tab)}] create ok ..", ansi_color: :yellow)
      else
        {:error, {:already_exists, _, _}} ->
          Logger.info("Load exist table [#{inspect(tab)}] ", ansi_color: :yellow)

        {:error, reason} ->
          Logger.error("Table init error #{inspect(reason)}")
      end
    end
  end

  defp copy_tables() do
    Logger.info("Copying tables...", ansi_color: :yellow)
    table_defs = TableDef.tables()
    Logger.info("Tables to be copied: #{inspect(table_defs, pretty: true)}")

    for tab <- table_defs do
      :ok = Table.create_copy(tab, node(), :disc_copies)
    end
  end
end
