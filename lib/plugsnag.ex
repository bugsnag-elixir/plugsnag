defmodule Plugsnag do
  defmacro __using__(options \\ []) do
    quote location: :keep do
      use Plug.ErrorHandler

      defp handle_errors(conn, %{reason: exception, kind: :error} = assigns) do
        # Only handle exceptions that get rendered as an HTTP 5xx status
        if Plug.Exception.status(exception) >= 500 do
          Plugsnag.handle_errors(conn, assigns, unquote(options))
        end
      end

      defp handle_errors(conn, %{reason: _exception} = assigns) do
        Plugsnag.handle_errors(conn, assigns, unquote(options))
      end
    end
  end

  def handle_errors(conn, %{reason: exception}, opts \\ []) do
    error_report_builder =
      Keyword.get(opts, :error_report_builder, Plugsnag.BasicErrorReportBuilder)

    options =
      %Plugsnag.ErrorReport{}
      |> error_report_builder.build_error_report(conn)
      |> Map.from_struct()
      |> Keyword.new()

    reporter = Application.get_env(:plugsnag, :reporter, Bugsnag)
    apply(reporter, :report, [exception | [options]])
  end
end
