defmodule Service.Button do
  use GenServer

  import Messages.GetInfo
  import ShorterMaps

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def connect() do
    GenServer.cast(__MODULE__, :connect)
  end

  def handle_cast(:get_info, %{socket: s} = state) do
    :ok = :gen_tcp.send(s, get_info_request())
    {:ok, reply} = :gen_tcp.recv(s, 0)

    msg =
      :binary.list_to_bin(reply)
      |> get_data()
      |> get_info()
      |> inspect()

    IO.puts(:stderr, msg)

    {:noreply, state}
  end

  def handle_cast(:connect, _state) do
    :timer.sleep(6000)

    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 5551, [active: false])

    GenServer.cast(self(), :get_info)

    {:noreply, ~M{socket}}
  end

  defp get_data(<< _ :: bytes-size(3), data :: binary >>), do: data
end
