defmodule Plugsnag do
  defmacro __using__(options \\ []) do
    quote location: :keep do
      use Plug.ErrorHandler
      import Plugsnag

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

      defp handle_errors(conn, %{reason: exception}) do
        error_report_builder = unquote(
          Keyword.get(
            options,
            :error_report_builder,
            Plugsnag.BasicErrorReportBuilder
          )
        )

        options = build_options(error_report_builder, conn, exception)
        apply(reporter(), :report, [exception | [options]])
      end

      defp build_options(error_report_builder, conn, _exception) do
          %Plugsnag.ErrorReport{}
          |> error_report_builder.build_error_report(conn)
          |> Map.delete(:__struct__)
          |> Keyword.new
      end
      defoverridable [build_options: 3]
    end
  end

  def reporter do
    Application.get_env(:plugsnag, :reporter, Bugsnag)
  end
end
