defmodule PlugsnagTest.TestException do
  defexception plug_status: 503, message: "oops"
end

defmodule PlugsnagTest.NotFoundException do
  defexception plug_status: 404, message: "not found"
end

defmodule PlugsnagTest.ErrorRaisingPlug do
  defmacro __using__(_env) do
    quote do
      def call(conn, _opts) do
        {:current_stacktrace, [_ | stacktrace]} = Process.info(self(), :current_stacktrace)

        raise Plug.Conn.WrapperError,
          conn: conn,
          kind: :error,
          stack: stacktrace,
          reason: PlugsnagTest.TestException.exception([])
      end
    end
  end
end

defmodule PlugsnagTest.NotFoundRaisingPlug do
  defmacro __using__(_env) do
    quote do
      def call(conn, _opts) do
        {:current_stacktrace, [_ | stacktrace]} = Process.info(self(), :current_stacktrace)

        raise Plug.Conn.WrapperError,
          conn: conn,
          kind: :error,
          stack: stacktrace,
          reason: PlugsnagTest.NotFoundException.exception([])
      end
    end
  end
end

defmodule PlugsnagTest.TestPlug do
  use Plugsnag
  use PlugsnagTest.ErrorRaisingPlug
end

defmodule PlugsnagTest.NotFoundPlug do
  use Plugsnag
  use PlugsnagTest.NotFoundRaisingPlug
end
