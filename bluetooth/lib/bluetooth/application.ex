defmodule Bluetooth.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  @seed_database "/usr/bin/buttons.sqlite3"

  use Application

  require Logger

  def start(_type, _args) do
    MuonTrap.cmd(
      "modprobe",
      [
        "hci_uart",
      ]
    ) |> report_status("modprobe")

    :timer.sleep(5000)

    MuonTrap.cmd(
      "hciattach",
      [
        "/dev/ttyAMA0",
        "bcm43xx",
        "115200",
        "noflow",
        "-"
      ]
    ) |> report_status("hciattach")

    children = [
      {NervesNTP, [sync_on_start: true]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bluetooth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def report_status({msg, status}, label) do
    Logger.debug("STATUS[#{label}][#{status}]: [\n#{msg}]")
  end
end
