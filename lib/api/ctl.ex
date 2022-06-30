defmodule Api.Ctl do
  # import Plug.Conn
  use Plug.Router
  use Common
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<h1>Welcome Matrix API</h1>")
  end

  get "api" do
    online_num = :pg.get_members(Role.Svr) |> length()

    content =
      """
      # 基础功能
      ### [查看报错](api/error) [在线列表:#{online_num}](api/onlinelist) [房间列表](api/roomlist) [重 启](api/restart) [清 档](api/clear_db)
      """
      |> Api.Render.markdown()

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, content)
  end

  get "api/error" do
    with {:ok, text} <- File.read(Application.get_env(:logger, :error_log)[:path]) do
      content = Api.Render.markdown(text)

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, content)
    else
      _ ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "no error yet")
    end
  end

  get "api/restart" do
    :init.restart()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "重启中")
  end

  get "api/clear_db" do
    Redis.clearall()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "完成清档")
  end

  get "api/onlinelist" do
    pids = :pg.get_members(Role.Svr)

    text =
      if pids == [] do
        "# 当前没有在线"
      else
        items =
          for pid <- pids do
            role_id = :sys.get_state(pid).role_id
            ~M{account,role_name,head_id,avatar_id} = Role.Svr.get_data(pid, Role.Mod.Role)

            "| [#{role_id}](roleinfo/#{role_id}) | * #{inspect(pid)} * |  <#{account}> | #{role_name} | #{head_id} | #{avatar_id} |"
          end
          |> Enum.join("\n")

        """
        | RoleID |   PID  |  Account  | RoleName | HeadID | AvatarID |
        |:------:|:------:|:---------:|:--------:|:------:|:--------:|
        #{items}
        """
      end

    content = Api.Render.markdown(text)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, content)
  end

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Oops!")
  end
end
