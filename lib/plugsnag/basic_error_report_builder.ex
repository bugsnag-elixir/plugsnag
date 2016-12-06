defmodule Plugsnag.BasicErrorReportBuilder do
  @moduledoc """
  Error report builder that adds basic context to the ErrorReport.
  """
  @default_filter_parameters params: ~w(password)
  @behaviour Plugsnag.ErrorReportBuilder

  def build_error_report(error_report, conn) do
    %{error_report | metadata: build_metadata(conn)}
  end

  defp build_metadata(conn) do
    conn =
      conn
      |> Plug.Conn.fetch_query_params

    %{
      request: %{
        request_path: conn.request_path,
        method: conn.method,
        port: conn.port,
        scheme: conn.scheme,
        query_string: conn.query_string,
        params: filter(:params, conn.params),
        headers: collect_req_headers(conn)
      }
    }
  end

  defp collect_req_headers(conn) do
    headers = Enum.reduce(conn.req_headers, %{}, fn({header, _}, acc) ->
      Map.put(acc, header, Plug.Conn.get_req_header(conn, header) |> List.first)
    end)
    filter(:headers, headers)
  end

  defp filters_for(:headers) do
    do_filters_for(:headers) |> Enum.map(&String.downcase/1)
  end

  defp filters_for(field), do: do_filters_for(field)

  defp do_filters_for(field) do
    Application.get_env(:plugsnag, :filter, @default_filter_parameters)
    |> Keyword.get(field, [])
  end

  defp filter(field, data), do: do_filter(data, filters_for(field))

  def do_filter(%{__struct__: mod} = struct, _params_to_filter) when is_atom(mod), do: struct
  def do_filter(%{} = map, params_to_filter) do
    Enum.into map, %{}, fn {k, v} ->
      if is_binary(k) && String.contains?(k, params_to_filter) do
        {k, "[FILTERED]"}
      else
        {k, do_filter(v, params_to_filter)}
      end
    end
  end
  def do_filter([_|_] = list, params_to_filter), do: Enum.map(list, &do_filter(&1, params_to_filter))
  def do_filter(other, _params_to_filter), do: other
end
