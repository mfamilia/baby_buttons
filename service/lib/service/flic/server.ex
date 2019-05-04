defmodule Service.Flic.Server do
  use GenServer

  import Service.Broadcast
  import Process, only: [send_after: 3]

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    send_after(self(), :start_flic_server, 3000)

    {:ok, %{}}
  end

  def handle_info(:start_flic_server, state) do
    send_after(self(), :report_started, 6000)

    host =
      Application.get_env(:service, :flic_host)
      |> to_string()

    port =
      Application.get_env(:service, :flic_port)
      |> to_string()

    file = Application.get_env(:service, :flic_database_file)
      |> to_string()

    Logger.info("Starting Flicd...")

    {_, 0} = MuonTrap.cmd(
      "/usr/bin/flicd",
      [
        "-s",
        host,
        "-p",
        port,
        "-f",
        file,
        "-d"
      ]
    )

    {:noreply, state}
  end

  def handle_info(:report_started, state) do
    broadcast_to(:flic_server_started, self())

    {:noreply, state}
  end
end
