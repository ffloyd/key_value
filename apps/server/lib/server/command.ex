defmodule Server.Command do
  @doc ~S"""
  Parses giving `line` into a command

  ## Examples

      iex> Server.Command.parse "CREATE shopping\r\n"
      {:ok, {:create, "shopping"}}

      iex> Server.Command.parse "CREATE shopping   \r\n"
      {:ok, {:create, "shopping"}}

      iex> Server.Command.parse "PUT shopping milk 1\r\n"
      {:ok, {:put, "shopping", "milk", "1"}}

      iex> Server.Command.parse "GET shopping milk\r\n"
      {:ok, {:get, "shopping", "milk"}}

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
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["GET", bucket, key]        -> {:ok, {:get, bucket, key}}
      ["DELETE", bucket, key]     -> {:ok, {:delete, bucket, key}}
      _                           -> {:error, :unknown_command}
    end
  end
end
