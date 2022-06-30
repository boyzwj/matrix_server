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
    content = """
    <a href = \"api/error\">查看报错</a><br>
    <a href = \"api/onlinelist\">在线列表</a><br>
    <a href = \"api/clear_db\">清 档</a><br>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, content)
  end

  get "api/error" do
    with {:ok, text} <- File.read(Application.get_env(:logger, :error_log)[:path]) do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, text)
    else
      _ ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "no error yet")
    end
  end

  get "api/clear_db" do
    Redis.clearall()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "完成清档")
  end

  get "api/onlinelist" do
    content = """
    <head>
    <title></title>
    <style type="text/css">
    table
    {
        border-collapse: collapse;
        margin: 0 auto;
        text-align: center;
    }
    table td, table th
    {
        border: 1px solid #cadeea;
        color: #666;
        height: 30px;
    }
    table thead th
    {
        background-color: #CCE8EB;
        width: 100px;
    }
    table tr:nth-child(odd)
    {
        background: #fff;
    }
    table tr:nth-child(even)
    {
        background: #F5FAFA;
    }
    </style>
    </head>
    <table width="90%" class="table">
    <tr><th>RoleID</th><th>PID</th><th>Account</th><th>RoleName</th><th>HeadID</th><th>AvatarID</th></tr>
    """

    content =
      for pid <- :pg.get_members(Role.Svr), into: content do
        role_id = :sys.get_state(pid).role_id
        ~M{account,role_name,head_id,avatar_id} = Role.Svr.get_data(pid, Role.Mod.Role)

        "<tr><td>#{role_id}</td><td>#{inspect(pid)}</td><td> #{account}</td> <td>#{role_name}</td><td>#{head_id}</td><td>#{avatar_id}</td></tr>"
      end

    content <> "</table>"

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
