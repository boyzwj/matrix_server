defmodule Tool.Pbid do
  @status_content 0
  @status_line_comment 1
  @status_range_comment 2

  def proto_ids(path, max_proto_id \\ 65536) do
    file_list =
      path
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".proto"))
      |> Enum.map(&"#{path}/#{&1}")

    %{protos: protos} =
      read_files(
        %{package: "", module: "", protos: [], layer: 0},
        file_list
      )

    for {proto, package} <- protos do
      # id = :erlang.phash2(proto, 65536)
      <<seed::128>> = Util.md5(proto)
      id = rem(seed, max_proto_id)
      %{id: id, proto: proto, package: package}
    end
    |> proto_ids_duplicate_check()
  end

  defp proto_ids_duplicate_check(proto_ids) do
    r = proto_ids |> Enum.group_by(& &1.id) |> Enum.filter(&(length(elem(&1, 1)) > 1))

    if length(r) > 0 do
      raise "proto id is duplicate: #{inspect(r)} "
    else
      proto_ids
    end
  end

  defp read_files(result, []) do
    result
  end

  defp read_files(result, [filename | t]) do
    result
    |> read_file(filename)
    |> read_files(t)
  end

  defp read_file(result, filename) do
    data = File.read!(filename)
    do_read(result, data, @status_content)
  end

  def upper_first(<<a::binary-size(1), data::binary>>) do
    String.upcase(a) <> data
  end

  defp do_read(result, <<"//", data::binary>>, @status_content) do
    status = @status_line_comment
    result |> do_read(data, status)
  end

  defp do_read(result, <<"\n", data::binary>>, @status_line_comment) do
    status = @status_content
    result |> do_read(data, status)
  end

  defp do_read(result, <<"/*", data::binary>>, @status_content) do
    status = @status_range_comment
    result |> do_read(data, status)
  end

  defp do_read(result, <<"*/", data::binary>>, @status_range_comment) do
    status = @status_content
    result |> do_read(data, status)
  end

  defp do_read(result, <<"package ", data::binary>>, @status_content = status) do
    [package, data] = String.split(data, ";", parts: 2)

    module =
      String.split(package, ".")
      |> Enum.map(&upper_first(&1))
      |> Enum.join(".")

    %{result | package: package, module: module} |> do_read(data, status)
  end

  defp do_read(
         %{protos: protos, package: package, module: module, layer: 0} = result,
         <<"message ", data::binary>>,
         @status_content = status
       ) do
    [msg, data] = String.split(data, "{", parts: 2)

    msg =
      msg
      |> String.trim()
      |> String.split("_")
      |> Enum.map(&upper_first(&1))
      |> Enum.join()
      |> (&"#{module}.#{&1}").()

    if String.ends_with?(msg, "2C") || String.ends_with?(msg, "2S") do
      %{result | layer: 1, protos: [{msg, package} | protos]} |> do_read(data, status)
    else
      %{result | layer: 1} |> do_read(data, status)
    end
  end

  defp do_read(%{layer: layer} = result, <<"{", data::binary>>, @status_content = status) do
    %{result | layer: layer + 1} |> do_read(data, status)
  end

  defp do_read(%{layer: layer} = result, <<"}", data::binary>>, @status_content = status) do
    %{result | layer: layer - 1} |> do_read(data, status)
  end

  defp do_read(result, <<_::8, data::binary>>, status) do
    result |> do_read(data, status)
  end

  defp do_read(result, _error, _status) do
    result
  end
end
