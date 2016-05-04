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

      defp handle_errors(_conn, %{reason: exception}) do
        Bugsnag.report(exception)
      end
    end
  end
end
