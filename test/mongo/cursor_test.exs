defmodule Mongo.CursorTest do
  use ExUnit.Case

  defmacro unique_name do
    {function, _arity} = __CALLER__.function
    "#{__CALLER__.module}.#{function}"
  end

  setup_all do
    assert {:ok, pid} = Mongo.TestConnection.connect()
    {:ok, [pid: pid]}
  end

  # issue #94
  test "correctly pass options to kill_cursors", c do
    coll = unique_name()

    docs = Stream.cycle([%{foo: 42}]) |> Enum.take(100)

    assert {:ok, _} = Mongo.insert_many(c.pid, coll, docs)

    assert [%{"foo" => 42}, %{"foo" => 42}] =
             c.pid |> Mongo.find(coll, %{}, limit: 2) |> Enum.to_list()
  end

  test "limit", c do
    coll = unique_name()

    docs = [%{name: "a"}, %{name: "b"}, %{name: "c"}]
    assert {:ok, _} = Mongo.insert_many(c.pid, coll, docs)
    assert [%{"name" => "a"}, %{"name" => "b"}] = Mongo.find(c.pid, coll, %{}, limit: 2) |> Enum.to_list
  end

  test "skip", c do
    coll = unique_name()

    docs = [%{name: "a"}, %{name: "b"}, %{name: "c"}]
    assert {:ok, _} = Mongo.insert_many(c.pid, coll, docs)
    assert [%{"name" => "b"}, %{"name" => "c"}] = Mongo.find(c.pid, coll, %{}, limit: 2, skip: 1) |> Enum.to_list
  end

  test "sort", c do
    coll = unique_name()

    docs = [%{name: "b"}, %{name: "a"}, %{name: "c"}]
    assert {:ok, _} = Mongo.insert_many(c.pid, coll, docs)
    assert [%{"name" => "c"}, %{"name" => "b"}, %{"name" => "a"}] = Mongo.find(c.pid, coll, %{}, [sort: %{name: -1}]) |> Enum.to_list
  end
end
