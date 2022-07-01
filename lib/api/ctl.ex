defmodule Api.Ctl do
  # import Plug.Conn
  use Plug.Router
  use Common
  plug(:match)
  plug(:dispatch)

  get "/" do
    online_num = :pg.get_members(Role.Svr) |> length()
    room_num = :ets.info(Room, :size)

    text = """
    # 基础功能
    ## [查看报错](/ctl/error) [协议定义](/ctl/pblua) [在线列表:#{online_num}](/ctl/online) [房间列表:#{room_num}](/ctl/room)
    -------------
    # 运维功能
    ## [重 启](/ctl/restart) [清 档](/ctl/clear_db)
    """

    conn |> send_markdown(text)
  end

  get "error" do
    text =
      with {:ok, data} <- File.read(Application.get_env(:logger, :error_log)[:path]) do
        data
      else
        _ ->
          "## 暂时没有错误日志"
      end
      |> (&"""
          # 错误日志
          ------
             #{&1}
          """).()

    conn |> send_markdown(text)
  end

  get "pblua" do
    text =
      with {:ok, data} <- File.read("#{:code.priv_dir(:matrix_server)}/static/PT.lua") do
        data
      else
        _ ->
          "没有生成"
      end
      |> (&"""
          # 协议定义
          ## [download](/static/PT.lua)
          ---------------------
          ```lua
          #{&1}
          ```
          """).()

    conn |> send_markdown(text)
  end

  get "restart" do
    :init.restart()
    text = "# 重启完成 ..."
    conn |> send_markdown(text)
  end

  get "clear_db" do
    Redis.clearall()
    text = "# 完成清档"
    conn |> send_markdown(text)
  end

  get "online" do
    pids = :pg.get_members(Role.Svr)

    text =
      if pids == [] do
        """
        # 在线列表
        ----------
        ## 当前没有在线
        """
      else
        items =
          for pid <- pids do
            role_id = :sys.get_state(pid).role_id
            ~M{account,role_name,head_id,avatar_id} = Role.Svr.get_data(pid, Role.Mod.Role)

            "|#{role_id}| * #{inspect(pid)} * |  <#{account}> | #{role_name} | #{head_id} | #{avatar_id} | [* 查看 *](/ctl/online/#{role_id}) |"
          end
          |> Enum.join("\n")

        """
        # 在线列表
        ----------
        | RoleID |   PID  |  Account  | RoleName | HeadID | AvatarID |     |
        |:-------|:------:|:---------:|:--------:|:------:|:--------:|----:|
        #{items}
        """
      end

    conn |> send_markdown(text)
  end

  get "online/:role_id" do
    role_id = String.to_integer(role_id)

    content =
      for {mod, data} <- Role.Svr.get_all_data(role_id) do
        "|#{mod} |```#{Jason.encode!(data)}```|"
      end
      |> Enum.join("\n")
      |> (&"""
          # 角色信息
          ## RoleID: #{role_id}
          ---------------------
          | Module |   Data   |
          |:-------|---------:|
          #{&1}
          """).()

    conn |> send_markdown(content)
  end

  get "room" do
    text =
      for {_, ~M{room_id,type,status,create_time,owner,password,member_num}} <-
            :ets.tab2list(Room) do
        "|#{room_id}|#{member_num}|#{owner}|#{type}|#{status}|#{password}|#{create_time}|"
      end
      |> Enum.join("\n")
      |> (&"""
          # 房间列表
          ---------------------------
          |RoomID|MemberNum|Owner| Type |Status|Password|CreateTime|
          |:----:|:-------:|:---:|:----:|:----:|:------:|---------:|
          #{&1}
          """).()

    conn |> send_markdown(text)
  end

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Oops!")
  end

  defp send_markdown(conn, text) do
    content = Api.Render.markdown(text <> footer())

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, content)
  end

  defp footer() do
    """
    \n------------------------------
    # [返回](/ctl)
    """
  end
end
