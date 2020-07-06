defmodule Plugsnag do
  defmacro __using__(options \\ []) do
    quote location: :keep do
      use Plug.ErrorHandler

      defp handle_errors(conn, %{reason: exception, kind: :error} = assigns) do
        # Only handle exceptions that get rendered as an HTTP 5xx status
        if Plug.Exception.status(exception) >= 500 do
          do_handle_errors(conn, assigns)
        end
      end

      defp handle_errors(conn, %{reason: _exception} = assigns) do
        do_handle_errors(conn, assigns)
      end

      defp do_handle_errors(conn, %{reason: exception}) do
        error_report_builder =
          unquote(
            Keyword.get(
              options,
              :error_report_builder,
              Plugsnag.BasicErrorReportBuilder
            )
          )

        options =
          %Plugsnag.ErrorReport{}
          |> error_report_builder.build_error_report(conn)
          |> Map.from_struct()
          |> Keyword.new()

        reporter = Application.get_env(:plugsnag, :reporter, Bugsnag)
        apply(reporter, :report, [exception | [options]])
      end
    end
  end
end
