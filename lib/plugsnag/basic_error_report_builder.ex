defmodule Plugsnag.BasicErrorReportBuilder do
  @moduledoc """
  Error report builder that adds basic context to the ErrorReport.
  """
  @default_filter_parameters ~w(password)
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
        params: filter_params(conn.params),
        headers: collect_req_headers(conn)
      }
    }
  end

  defp collect_req_headers(conn) do
    Enum.reduce(conn.req_headers, %{}, fn({header, _}, acc) ->
      Map.put(acc, header, Plug.Conn.get_req_header(conn, header) |> List.first)
    end)
  end

  defp filter_params(params), do: do_filter_params(params, Application.get_env(:plugsnag, :filter_parameters, @default_filter_parameters))

  def do_filter_params(%{__struct__: mod} = struct, _params_to_filter) when is_atom(mod), do: struct
  def do_filter_params(%{} = map, params_to_filter) do
    Enum.into map, %{}, fn {k, v} ->
      if is_binary(k) && String.contains?(k, params_to_filter) do
        {k, "[FILTERED]"}
      else
        {k, do_filter_params(v, params_to_filter)}
      end
    end
  end
  def do_filter_params([_|_] = list, params_to_filter), do: Enum.map(list, &do_filter_params(&1, params_to_filter))
  def do_filter_params(other, _params_to_filter), do: other
end
