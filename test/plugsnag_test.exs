defmodule PlugsnagTest do
  use ExUnit.Case

  setup_all do
    Bugsnag.start
    :ok
  end

  test "it reraises the exceptions" do
    assert_raise ArithmeticError, "bad argument in arithmetic expression", fn ->
      Plugsnag.wrap(nil, nil, fn(_conn) ->
        1 + "test"
      end)
    end
  end
end
