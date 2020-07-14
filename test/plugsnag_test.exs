defmodule PlugsnagTest do
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
    use Plugsnag
    use ErrorRaisingPlug
  end

  defmodule NotFoundPlug do
    use Plugsnag
    use NotFoundRaisingPlug
  end

  defmodule FakePlugsnag do
    def report(exception, options \\ []) do
      send(self(), {:report, {exception, options}})
    end
  end

  setup do
    Application.put_env(:plugsnag, :reporter, FakePlugsnag)
  end

  describe "5xx exception" do
    test "Raising an error on failure" do
      conn = conn(:get, "/")

      assert_raise Plug.Conn.WrapperError, "** (PlugsnagTest.TestException) oops", fn ->
        TestPlug.call(conn, [])
      end

      assert_received {:report, {%TestException{}, _}}
    end

    test "calling Plugsnag.handle_errors explicitly" do
      defmodule ExtendedPlug do
        use Plug.ErrorHandler
        use ErrorRaisingPlug

        defp handle_errors(conn, %{reason: _exception} = assigns) do
          send(self(), :custom_handle)
          Plugsnag.handle_errors(conn, assigns)
        end
      end

      conn = conn(:get, "/")

      assert_raise Plug.Conn.WrapperError, "** (PlugsnagTest.TestException) oops", fn ->
        ExtendedPlug.call(conn, [])
      end

      assert_received :custom_handle
      assert_received {:report, {%TestException{}, _}}
    end

    test "includes connection metadata in the report" do
      conn = conn(:get, "/?hello=computer")

      catch_error(TestPlug.call(conn, []))
      assert_received {:report, {%TestException{}, options}}
      metadata = Keyword.get(options, :metadata)

      assert get_in(metadata, [:request, :query_string]) == "hello=computer"
    end

    test "allows modifying bugsnag report options before it's sent" do
      defmodule TestErrorReportBuilder do
        @behaviour Plugsnag.ErrorReportBuilder

        def build_error_report(error_report, conn) do
          user_info = %{
            id: conn |> get_req_header("x-user-id") |> List.first()
          }

          %{error_report | user: user_info}
        end
      end

      defmodule TestPlugsnagCallbackPlug do
        use Plugsnag, error_report_builder: TestErrorReportBuilder
        use ErrorRaisingPlug
      end

      conn = conn(:get, "/")

      conn =
        conn
        |> put_req_header("x-user-id", "abc123")

      catch_error(TestPlugsnagCallbackPlug.call(conn, []))
      assert_received {:report, {%TestException{}, options}}

      assert Keyword.get(options, :user) == %{
               id: "abc123"
             }
    end
  end

  describe "4xx exception" do
    test "Raising an error on failure" do
      conn = conn(:get, "/")

      assert_raise Plug.Conn.WrapperError, "** (PlugsnagTest.NotFoundException) not found", fn ->
        NotFoundPlug.call(conn, [])
      end

      refute_receive {:report, {%NotFoundException{}, _}}, 100
    end
  end
end
