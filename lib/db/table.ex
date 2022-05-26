defmodule DB.Table do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use Common
      import Ecto.Query
      use Nebulex.Caching
      alias DB.LocalCache, as: Cache
      alias DB.Repo
      import Ecto.Changeset

      def all() do
        Repo.all(__MODULE__)
      end

      @decorate cache_evict(cache: Cache, all_entries: true)
      def clear() do
        Repo.delete_all(__MODULE__)
      end

      def max(field \\ :id) do
        Repo.aggregate(__MODULE__, :max, field) || 0
      end

      def count(field \\ :id) do
        Repo.aggregate(__MODULE__, :count, field) || 0
      end
    end
  end
end
