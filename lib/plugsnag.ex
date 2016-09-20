defmodule Plugsnag do


  defmacro __using__(_env) do
    quote location: :keep do
      use Plug.ErrorHandler

      if :code.is_loaded(Phoenix) do
        defp handle_errors(_conn, %{reason: %Phoenix.Router.NoRouteError{}}) do
          nil
        end
      end

      if :code.is_loaded(Ecto) do
        defp handle_errors(conn, %{reason: %Ecto.NoResultsError{}}) do
          nil
        end
      end

      defp reporter do
        Application.get_env(:plugsnag, :reporter, Bugsnag)
      end

      defp handle_errors(conn, %{reason: exception}) do
        reporter.report(exception, metadata: extract_metadata(conn))
      end

      defp extract_metadata(conn) do
        %{
          conn: %{
            request_path: conn.request_path,
            method: conn.method,
            port: conn.port,
            scheme: conn.scheme,
            query_string: conn.query_string,
            client_ip: format_ip(conn.remote_ip),
            body: conn.body_params
          }
        }
      end

      defp format_ip(ip) do
        ip
        |> Tuple.to_list
        |> Enum.join(".")
      end
    end
  end
end
