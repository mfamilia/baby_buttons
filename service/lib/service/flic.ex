defmodule Service.Flic do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :timer.sleep(3000)

    send(self(), :start_flic_server)

    {:ok, %{}}
  end

  def handle_info(:start_flic_server, state) do
    MuonTrap.Daemon.start_link(
      "/usr/bin/flicd",
      [
        "-f",
        "/usr/bin/buttons.sqlite3"
      ]
    )

    Service.Button.connect()

    {:noreply, state}
  end
end
