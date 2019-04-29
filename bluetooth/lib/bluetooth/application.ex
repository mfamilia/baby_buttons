defmodule Bluetooth.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    MuonTrap.cmd(
      "modprobe",
      [
        "hci_uart",
      ],
      into: IO.stream(:stdio, :line)
    )

    :timer.sleep(5000)

    MuonTrap.cmd(
      "hciattach",
      [
        "/dev/ttyAMA0",
        "bcm43xx",
        "115200",
        "noflow",
        "-"
      ],
      into: IO.stream(:stdio, :line)
    )

    children = []

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bluetooth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
