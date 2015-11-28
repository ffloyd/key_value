defmodule Server.Command do
  @doc ~S"""
  Parses giving `line` into a command

  ## Examples

      iex> Server.Command.parse "CREATE shopping\r\n"
      {:ok, {:create, "shopping"}}

      iex> Server.Command.parse "CREATE shopping   \r\n"
      {:ok, {:create, "shopping"}}

      iex> Server.Command.parse "GET shopping milk\r\n"
      {:ok, {:get, "shopping", "milk"}}

      iex> Server.Command.parse "PUT shopping milk 1\r\n"
      {:ok, {:put, "shopping", "milk", "1"}}

      iex> Server.Command.parse "DELETE shopping eggs\r\n"
      {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands or commands with wrong count of arguments return an error:

      iex> Server.Command.parse "KILL all humans\r\n"
      {:error, :unknown_command}

      iex> Server.Command.parse "CREATE all humans\r\n"
      {:error, :unknown_command}
  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket]          -> {:ok, {:create, bucket}}
      ["GET", bucket, key]        -> {:ok, {:get, bucket, key}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["DELETE", bucket, key]     -> {:ok, {:delete, bucket, key}}
      _                           -> {:error, :unknown_command}
    end
  end

  def run({:create, bucket}) do
    Store.Registry.create(Store.Registry, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket, key}) do
    lookup bucket, fn pid ->
      value = Store.Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end
  end

  def run({:put, bucket, key, value}) do
    lookup bucket, fn pid ->
      Store.Bucket.put(pid, key, value)
      {:ok, "OK\r\n"}
    end
  end

  def run({:delete, bucket, key}) do
    lookup bucket, fn pid ->
      Store.Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end
  end

  defp lookup(bucket, callback) do
    case Store.Registry.lookup(Store.Registry, bucket) do
      nil -> {:error, :not_found}
      pid -> callback.(pid)
    end
  end
end
