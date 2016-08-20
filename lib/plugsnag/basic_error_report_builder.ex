defmodule Plugsnag.BasicErrorReportBuilder do
  @moduledoc """
  Error report builder that adds basic context to the ErrorReport.
  """

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
        params: conn.params,
        headers: collect_req_headers(conn)
      }
    }
  end

  defp collect_req_headers(conn) do
    Enum.reduce(conn.req_headers, %{}, fn({header, _}, acc) ->
      Map.put(acc, header, Plug.Conn.get_req_header(conn, header) |> List.first)
    end)
  end
end
