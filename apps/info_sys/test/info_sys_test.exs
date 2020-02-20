defmodule InfoSysTest do
  use ExUnit.Case
  alias InfoSys.Result

  defmodule TestBackend do
    def name() do
      "TestBackend"
    end

    def compute("result", _opts) do
      [%Result{backend: __MODULE__, text: "result"}]
    end

    def compute("none", _opts) do
      []
    end

    def compute("timeout", _opts) do
      Process.sleep(:infinity)
    end

    def compute("crash", _opts) do
      raise ""
    end
  end

  test "compute/2 with backend results" do
    assert [%Result{backend: TestBackend, text: "result"}] =
             InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 with no backend results" do
    assert [] = InfoSys.compute("none", backends: [TestBackend])
  end

  test "compute/2 with timeout" do
    assert [] = InfoSys.compute("timeout", backends: [TestBackend], timeout: 10)
  end

  # Avoid noisy log messages
  @tag :capture_log
  test "compute/2 with backend crash returns empty results" do
    assert [] = InfoSys.compute("crash", backends: [TestBackend])
  end
end
