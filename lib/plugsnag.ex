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
            |> Bugsnag.report(release_stage: Atom.to_string(Mix.env))

            reraise exception, stacktrace
        end
      end
    end
  end
end
