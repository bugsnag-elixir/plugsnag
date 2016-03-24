defmodule Plugsnag do
  defmacro __using__(_env) do
    quote location: :keep do
      @before_compile Plugsnag
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable [call: 2]

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          exception ->
            stacktrace = System.stacktrace

            exception
            |> Bugsnag.report(release_stage: System.get_env("DEPLOYMENT_ENV") || System.get_env("MIX_ENV"))

            reraise exception, stacktrace
        end
      end
    end
  end
end
