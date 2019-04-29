defmodule BluetoothTest do
  use ExUnit.Case
  doctest Bluetooth

  test "greets the world" do
    assert Bluetooth.hello() == :world
  end
end
