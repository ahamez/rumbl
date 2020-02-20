defmodule InfoSys.Cache do
  use GenServer

  @cleanup_interval :timer.seconds(60)

  def put(name \\ __MODULE__, key, value) do
    true = :ets.insert(table_name(name), {key, value})
    :ok
  end

  def fetch(name \\ __MODULE__, key) do
    # 2 -> one-based index of the value in {key, value}
    {:ok, :ets.lookup_element(table_name(name), key, 2)}
  rescue
    ArgumentError -> :not_found
  end

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(opts) do
    state = %{
      interval: opts[:cleanup_interval] || @cleanup_interval,
      timer: nil,
      table: new_table(opts[:name])
    }

    {:ok, schedule_cleanup(state)}
  end

  def handle_info(:cleanup, state) do
    :ets.delete_all_objects(state.table)

    {:noreply, schedule_cleanup(state)}
  end

  defp new_table(name) do
    name
    |> table_name()
    |> :ets.new([
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])
  end

  defp table_name(name) do
    :"#{name}_cache"
  end

  defp schedule_cleanup(state) do
    %{state | timer: Process.send_after(self(), :cleanup, state.interval)}
  end
end
