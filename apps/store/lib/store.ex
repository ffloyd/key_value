defmodule Store do
  use Application

  @supervisor_name Store.Supervisor
  @event_manager_name Store.EventManager
  @registry_sup_name Store.Registry.Supervisor

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(GenEvent, [[name: @event_manager_name]]),
      supervisor(Store.Registry.Supervisor, [@event_manager_name, [name: @registry_sup_name]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: @supervisor_name]
    Supervisor.start_link(children, opts)
  end
end
