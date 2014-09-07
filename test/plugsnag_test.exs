defmodule PlugsnagTest do
  use ExUnit.Case

  defmodule BrokenStack do
    use Plug.Builder
    def broken_plug(_conn, _opts), do: 1 + "test"
    plug Plugsnag
    plug :broken_plug
  end

  setup_all do
    Bugsnag.start
    :ok
  end

  def conn(), do: Plug.Test.conn(:get, "/")

  test "it reraises the exceptions" do
    assert_raise ArithmeticError, "bad argument in arithmetic expression", fn ->
      conn = conn |> BrokenStack.call([])
    end
  end
end
