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
            metadata = %{"conn" => %{
              "query_params" => Map.get(conn, :params),
              "assigns"      => Map.get(conn, :assigns),
              "path_info"    => Map.get(conn, :path_info),
              "method"       => Map.get(conn, :method),
            }}
            release_stage = System.get_env("DEPLOYMENT_ENV") || System.get_env("MIX_ENV")

            Bugsnag.report(exception, [
              release_stage: release_stage,
              metadata: metadata,
            ])

            reraise exception, System.stacktrace
        end
      end
    end
  end
end
