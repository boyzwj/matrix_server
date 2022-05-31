defmodule Blog.Author do
  use Memento.Table,
    attributes: [:username, :fullname]
end

defmodule Blog.Post do
  use Memento.Table,
    attributes: [:id, :title, :content, :status, :author],
    index: [:status, :author],
    type: :ordered_set,
    autoincrement: true
end

defmodule Schema do
  def init(nodes \\ [node()]) do
    Memento.stop()
    :ok = Memento.Schema.create([node()])
    Memento.start()
    Process.sleep(1000)
    Memento.Table.create!(Blog.Author, disc_copies: nodes)
    Memento.Table.create!(Blog.Post, disc_copies: nodes)
  end
end
