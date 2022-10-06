defmodule PdPlugsnag do
  defmacro __using__(options \\ []) do
    quote location: :keep do
      use Plug.ErrorHandler
      import PdPlugsnag

      defp handle_errors(conn, %{reason: exception, kind: :error} = assigns) do
        # Ignore exceptions that don't get rendered as an HTTP 5xx status.
        # These don't really represent unhandled exceptions, and so don't
        # make sense to be sent off to Bugsnag.
        # To extend this behaviour to an otherwise unhandled exception type,
        # provide an implementation of the Plug.Exception protocol for your
        # exception type.
        if Plug.Exception.status(exception) < 500 do
          nil
        else
          do_handle_errors(conn, assigns)
        end
      end

      defp handle_errors(conn, %{reason: _exception} = assigns) do
        do_handle_errors(conn, assigns)
      end

      defp do_handle_errors(conn, %{reason: exception, stack: stack}) do
        error_report_builder =
          unquote(
            Keyword.get(
              options,
              :error_report_builder,
              PdPlugsnag.BasicErrorReportBuilder
            )
          )

        options =
          %PdPlugsnag.ErrorReport{}
          |> error_report_builder.build_error_report(conn)
          |> Map.from_struct()
          |> Keyword.new()
          |> Keyword.put(:stacktrace, stack)

        apply(reporter(), :report, [exception | [options]])
      end
    end
  end

  def reporter do
    Application.get_env(:pd_plugsnag, :reporter, Bugsnag)
  end
end
