defmodule Store.Registry.Supervisor do
  use Supervisor

  def start_link(events, opts \\ []) do
    Supervisor.start_link(__MODULE__, events, opts)
  end

  @registry_name Store.Registry
  @bucket_sup_name Store.Bucket.Supervisor

  def init(events) do
    children = [
      supervisor(Store.Bucket.Supervisor, [[name: @bucket_sup_name]]),
      worker(Store.Registry, [events, @bucket_sup_name, [name: @registry_name]])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
