
defmodule PlugsnagTest do
  use ExUnit.Case
  use Plug.Test

  defmodule Exception do
    defexception plug_status: 403, message: "oops"
  end

  defmodule TestPlug do
    use Plugsnag

    def call(conn, _opts) do
      raise Plug.Conn.WrapperError, conn: conn,
      kind: :error, stack: System.stacktrace,
      reason: Exception.exception([])
    end
  end

  defmodule FakePlugsnag do
    def report(exception, options \\ []) do
      send self, {:report, {exception, options}}
    end
  end

  setup do
    Application.put_env(:plugsnag, :reporter, FakePlugsnag)
  end

  test "Raising an error on failure" do
    conn = conn(:get, "/")

    assert_raise Exception, "oops", fn ->
      TestPlug.call(conn, [])
    end

    assert_received {:report, {%Exception{}, _}}
  end

  test "includes conn info in the report" do
    conn = conn(:get, "/?hello=computer")

    catch_error TestPlug.call(conn, [])

    assert_received {:report, {%Exception{}, options}}

    assert %{conn: %{
                request_path: "/",
                method: "GET",
                port: 80,
                scheme: :http,
                query_string: "hello=computer"
             }
    } = Keyword.get(options, :metadata)
  end


end
