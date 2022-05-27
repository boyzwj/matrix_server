defmodule Authorize do
  use Common

  def authorize(_token) do
    {:ok, 1001}
  end
end
