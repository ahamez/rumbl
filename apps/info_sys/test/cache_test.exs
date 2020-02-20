defmodule InfoSysTest.CacheTest do
  use ExUnit.Case, async: true
  alias InfoSys.Cache
  @moduletag cleanup_interval: 100

  defp assert_shutdown(pid) do
    ref = Process.monitor(pid)
    Process.unlink(pid)
    Process.exit(pid, :kill)

    assert_receive {:DOWN, ^ref, :process, ^pid, :killed}
  end

  defp eventually(func) do
    if func.() do
      true
    else
      Process.sleep(10)
      eventually(func)
    end
  end

  setup %{test: name, cleanup_interval: cleanup_interval} do
    {:ok, pid} = Cache.start_link(name: name, cleanup_interval: cleanup_interval)
    {:ok, name: name, pid: pid}
  end

  test "key value pairs can be put and fetched from cachee", %{name: name} do
    assert :ok = Cache.put(name, :key1, :value1)
    assert :ok = Cache.put(name, :key2, :value2)

    assert Cache.fetch(name, :key1) == {:ok, :value1}
    assert Cache.fetch(name, :key2) == {:ok, :value2}
  end

  test "unfound entry", %{name: name} do
    assert Cache.fetch(name, :does_not_exist) == :not_found
  end

  test "clear all entries after cleanup interval", %{name: name} do
    assert :ok = Cache.put(name, :key1, :value1)
    assert Cache.fetch(name, :key1) == {:ok, :value1}
    assert eventually(fn -> Cache.fetch(name, :key1) == :not_found end)
  end

  @tag cleanup_interval: 60_000
  test "values are cleared on exit", %{name: name, pid: pid} do
    assert :ok = Cache.put(name, :key1, :value1)
    assert_shutdown(pid)
    {:ok, _cache} = Cache.start_link(name: name)
    assert Cache.fetch(name, :key1) == :not_found
  end
end
