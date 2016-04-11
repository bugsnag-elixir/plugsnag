defmodule Plugsnag do
  defmacro __using__(_env) do
    quote location: :keep do
      use Plug.ErrorHandler

      defp handle_errors(_conn, %{reason: exception, stack: _stack}) do
        Bugsnag.report(exception, release_stage: Atom.to_string(Mix.env))
      end
    end
  end

end
