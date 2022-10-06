defmodule PdPlugsnagTest do
  use ExUnit.Case
  use Plug.Test

  defmodule TestException do
    defexception plug_status: 503, message: "oops"
  end

  defmodule NotFoundException do
    defexception plug_status: 404, message: "not found"
  end

  defmodule ErrorRaisingPlug do
    defmacro __using__(_env) do
      quote do
        def call(conn, _opts) do
          {:current_stacktrace, [_ | stacktrace]} = Process.info(self(), :current_stacktrace)

          raise Plug.Conn.WrapperError,
            conn: conn,
            kind: :error,
            stack: stacktrace,
            reason: TestException.exception([])
        end
      end
    end
  end

  defmodule NotFoundRaisingPlug do
    defmacro __using__(_env) do
      quote do
        def call(conn, _opts) do
          {:current_stacktrace, [_ | stacktrace]} = Process.info(self(), :current_stacktrace)

          raise Plug.Conn.WrapperError,
            conn: conn,
            kind: :error,
            stack: stacktrace,
            reason: NotFoundException.exception([])
        end
      end
    end
  end

  defmodule TestPlug do
    use PdPlugsnag
    use ErrorRaisingPlug
  end

  defmodule NotFoundPlug do
    use PdPlugsnag
    use NotFoundRaisingPlug
  end

  defmodule FakePdPlugsnag do
    def report(exception, options \\ []) do
      send self(), {:report, {exception, options}}
    end
  end

  setup do
    Application.put_env(:pd_plugsnag, :reporter, FakePdPlugsnag)
  end

  test "Raising an error on failure" do
    conn = conn(:get, "/")

    assert_raise Plug.Conn.WrapperError, "** (PdPlugsnagTest.TestException) oops", fn ->
      TestPlug.call(conn, [])
    end

    assert_received {:report, {%TestException{}, _}}
  end

  test "includes connection metadata in the report" do
    conn = conn(:get, "/?hello=computer")

    catch_error TestPlug.call(conn, [])
    assert_received {:report, {%TestException{}, options}}
    metadata = Keyword.get(options, :metadata)

    assert get_in(metadata, [:request,:query_string]) == "hello=computer"
  end

  test "allows modifying bugsnag report options before it's sent" do
    defmodule TestErrorReportBuilder do
      @behaviour PdPlugsnag.ErrorReportBuilder

      def build_error_report(error_report, conn) do
        user_info =  %{
          id: conn |> get_req_header("x-user-id") |> List.first
        }

        %{error_report | user: user_info}
      end
    end

    defmodule TestPdPlugsnagCallbackPlug do
      use PdPlugsnag, error_report_builder: TestErrorReportBuilder
      use ErrorRaisingPlug
    end

    conn = conn(:get, "/")

    conn =
      conn
      |> put_req_header("x-user-id", "abc123")

    catch_error TestPdPlugsnagCallbackPlug.call(conn, [])
    assert_received {:report, {%TestException{}, options}}

    assert Keyword.get(options, :user) == %{
     id: "abc123"
    }
  end

  describe "4xx exception" do
    test "Raising an error on failure" do
      conn = conn(:get, "/")

      assert_raise Plug.Conn.WrapperError, "** (PdPlugsnagTest.NotFoundException) not found", fn ->
        NotFoundPlug.call(conn, [])
      end

      refute_receive {:report, {%NotFoundException{}, _}}, 100
    end
  end

end
