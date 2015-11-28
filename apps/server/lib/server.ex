defmodule Server do
  use Application

  def accept_port(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                    [:binary, packet: :line, active: false, reuseaddr: true])
    IO.puts "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: Server.TaskSupervisor]]),
      worker(Task, [Server, :accept_port, [7000]])
    ]

    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    task = fn -> serve(client) end
    {:ok, pid} = Task.Supervisor.start_child(Server.TaskSupervisor, task)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    import Pipe

    msg = pipe_matching x, {:ok, x},
          read_line(socket)
          |> Server.Command.parse()
          |> Server.Command.run

    write_line(socket, msg)

    serve(socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, msg) do
    :gen_tcp.send(socket, format_msg(msg))
  end

  defp format_msg({:ok, text}), do: text
  defp format_msg({:error, :unknown_command}), do: "UNKNOWN COMMAND\r\n"
  defp format_msg({:error, :not_found}), do: "NOT FOUND\r\n"
  defp format_msg({:error, _}), do: "ERROR\r\n"
end
