defmodule User.Account do
  use Memento.Table,
    attributes: [:id, :username, :password, :character_list, :email, :phone],
    index: [:email, :username],
    type: :ordered_set,
    autoincrement: true
end

defmodule User.Character do
  use Memento.Table,
    attributes: [:id, :name, :title, :base_attrs, :battle_attrs, :position, :hp, :sp, :mp],
    index: [:name],
    type: :ordered_set,
    autoincrement: true
end

defmodule DBInit.TableDef do
  def stores() do
    PB.PP.modules()
  end

  def services do
    [User.Account, User.Character]
  end

  def tables() do
    # (stores() |> Enum.map(&{&1, :rocksdb_copies})) ++
    (stores() |> Enum.map(&{&1, :disc_copies})) ++
      (services() |> Enum.map(&{&1, :ram_copies}))
  end
end
