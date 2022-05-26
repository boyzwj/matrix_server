defmodule DB.Role.Account do
  use DB.Table

  @primary_key {:id, :id, autogenerate: true}
  schema "role_account" do
    field(:account, :string)
    field(:account_name, :string)
    field(:reg_ip, :string)
    timestamps()
  end

  def changeset(struct, params) do
    cast(struct, params, [
      :id,
      :account,
      :account_name,
      :reg_ip
    ])
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert()
  end

  @ttl :timer.hours(1)

  @decorate cacheable(cache: Cache, key: {__MODULE__, id}, opts: [ttl: @ttl])
  def get(id, opts \\ []) do
    Repo.get(__MODULE__, id, opts)
  end

  @decorate cacheable(cache: Cache, key: {__MODULE__, id}, opts: [ttl: @ttl])
  def get!(id, opts \\ []) do
    Repo.get!(__MODULE__, id, opts)
  end

  @decorate cacheable(cache: Cache, key: {__MODULE__, account_name}, opts: [ttl: @ttl])
  def get_by_account_name(account_name) do
    Repo.get_by(__MODULE__, account_name: account_name)
  end

  @decorate cache_put(
              cache: Cache,
              keys: [{__MODULE__, data.id}, {__MODULE__, data.account_name}],
              match: &match_update/1,
              opts: [ttl: @ttl]
            )
  def update(%__MODULE__{} = data, attrs) do
    data
    |> changeset(attrs)
    |> Repo.update()
  end

  @decorate cache_evict(
              cache: Cache,
              keys: [{__MODULE__, data.id}, {__MODULE__, data.account_name}]
            )
  def delete(%__MODULE__{} = data) do
    Repo.delete(data)
  end

  defp match_update({:ok, value}), do: {true, value}
  defp match_update({:error, _}), do: false
end
