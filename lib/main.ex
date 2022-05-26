defmodule Main do
  require Logger
  @moduledoc false

  use Application

  require Logger

  @node_all_in_one "0"
  @node_gate_way "1"
  @node_lobby "2"
  @node_db "3"

  def start(type, args) do
    node_type = System.get_env("NODE_TYPE", @node_all_in_one)
    do_start(node_type, type, args)
  end

  def do_start(@node_all_in_one, type, args) do
    Logger.info("******* start node type [all in one] ********")
    Gateway.start(type, args)
    DB.start(type, args)
  end

  def do_start(@node_gate_way, type, args) do
    Gateway.start(type, args)
  end

  def do_start(@node_lobby, type, args) do
  end

  def do_start(@node_db, type, args) do
    DB.start(type, args)
  end

  def config_change(changed, _new, removed) do
    :ok
  end
end
