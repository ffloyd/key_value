defmodule Store.Registry do
  use GenServer, async: true

  ## Client API

  def start_link(events, bucket_sup, opts \\ []) do
    GenServer.start_link(__MODULE__, {events, bucket_sup}, opts)
  end

  def lookup(registry, name) do
    GenServer.call(registry, {:lookup, name})
  end

  def create(registry, name) do
    GenServer.call(registry, {:create, name})
  end

  ## Server API

  def init({events, bucket_sup}) do
    buckets = HashDict.new
    refs    = HashDict.new
    {:ok, %{events: events, bucket_sup: bucket_sup, buckets: buckets, refs: refs}}
  end

  def handle_call({:lookup, name}, _from, state) do
    {:reply, HashDict.get(state.buckets, name), state}
  end

  def handle_call({:create, name}, _from, state) do
    if HashDict.has_key?(state.buckets, name) do
      {:reply, :error, state}
    else
      {:ok, bucket} = Store.Bucket.Supervisor.start_bucket(state.bucket_sup)
      ref = Process.monitor(bucket)

      GenEvent.sync_notify(state.events, {:create, name, bucket})

      buckets = HashDict.put(state.buckets, name, bucket)
      refs    = HashDict.put(state.refs, ref, name)
      {:reply, {:ok, bucket}, %{state | buckets: buckets, refs: refs}}
    end
  end

  def handle_info({:DOWN, ref, _, _, _}, state) do
    {name, refs}      = HashDict.pop(state.refs, ref)
    {bucket, buckets} = HashDict.pop(state.buckets, name)

    GenEvent.sync_notify(state.events, {:exit, name, bucket})
    {:noreply, %{state | buckets: buckets, refs: refs}}
  end
end
