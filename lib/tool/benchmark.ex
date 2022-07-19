defmodule Tool.Benchmark do
  def test() do
    Benchee.run(%{
      "protobuf" => fn ->
        %Pbm.Room.Update2C{
          __uf__: [],
          room: %Pbm.Room.Room{
            __uf__: [],
            create_time: 0,
            map_id: 0,
            member_num: 0,
            members: [],
            owner_id: 0,
            password: "",
            room_id: 0,
            status: 0
          }
        }
        |> PB.encode!()
      end,
      "term2binary" => fn ->
        %Pbm.Room.Update2C{
          __uf__: [],
          room: %Pbm.Room.Room{
            __uf__: [],
            create_time: 0,
            map_id: 0,
            member_num: 0,
            members: [],
            owner_id: 0,
            password: "",
            room_id: 0,
            status: 0
          }
        }
        |> :erlang.term_to_binary()
      end
    })
  end
end
