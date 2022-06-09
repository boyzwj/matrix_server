defmodule Service.Session do
  use Memento.Table,
    attributes: [:id, :role_id]

  # index: [:role_id]

  # type: :ordered_set,
  # autoincrement: true
end

defmodule Service.TokenAccount do
  use Memento.Table,
    attributes: [:token, :role_id, :reg_ip, :create_time]
end

# defmodule User.Character do
#   use Memento.Table,
#     attributes: [:id, :name, :title, :base_attrs, :battle_attrs, :position, :hp, :sp, :mp],
#     index: [:name],
#     type: :ordered_set,
#     autoincrement: true
# end

defmodule DBInit.TableDef do
  def stores() do
    [Service.TokenAccount | PB.PP.modules()]
  end

  def services do
    [Service.Session]
  end

  def tables() do
    # (stores() |> Enum.map(&{&1, :rocksdb_copies})) ++
    (stores() |> Enum.map(&{&1, :disc_copies})) ++
      (services() |> Enum.map(&{&1, :ram_copies}))
  end
end
