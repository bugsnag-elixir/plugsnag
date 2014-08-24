defmodule PlugsnagTest do
  use ExUnit.Case

  setup_all do
    Bugsnag.start
    :ok
  end

  def conn(), do: Plug.Test.conn(:get, "/")

  test "it reraises the exceptions" do
    assert_raise ArithmeticError, "bad argument in arithmetic expression", fn ->
      Plugsnag.wrap(conn, nil, fn(_conn) ->
        1 + "test"
      end)
    end
  end
end
