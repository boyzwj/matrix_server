defmodule GID do
  def get_role_id() do
    block_id = FastGlobal.get(:block_id, 1)
    Redis.incr("role_id:#{block_id}")
  end

  def get_battle_id() do
    Redis.incr("battle_id")
  end
end
