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
              "query_params" => Map.get(conn, :params) |> redact,
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

      defp redact(params) do
        fields = String.split(redact_config[:fields]) || ~w(password)
        filtered = fields
                    |> Enum.filter(&Map.has_key?(params, &1))
                    |> Enum.flat_map(&redact_field(&1))
                    |> Enum.into(%{})

        Map.merge(params, filtered)
      end

      defp redact_field(field) do
        %{field => redact_config[:string] || ~s([REDACTED])}
      end

      defp redact_config do
        __MODULE__
        |> Application.get_application
        |> Application.get_env(:redact_config)
        |> Enum.into(%{})
      end
    end
  end
end
