defmodule DB.Repo.Migrations.Create do
  use Ecto.Migration

  def change do
    create table(:role_account) do
      add(:account, :string)
      add(:account_name, :string)
      add(:reg_ip, :string)
      timestamps()
    end
    create(index(:role_account,[:account]))
    execute("ALTER TABLE role_account AUTO_INCREMENT = 1000001")

  end
end
