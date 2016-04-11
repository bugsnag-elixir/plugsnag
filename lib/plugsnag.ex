defmodule Plugsnag do
  defmacro __using__(_env) do
    quote location: :keep do
      use Plug.ErrorHandler

      defp handle_errors(_conn, %{reason: exception, stack: stack}) do
        Bugsnag.report(exception, stack)
      end
    end
  end

end
