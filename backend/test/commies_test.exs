defmodule CommiesTest do
  use ExUnit.Case
  doctest Commies

  test "greets the world" do
    assert Commies.hello() == :world
  end
end
