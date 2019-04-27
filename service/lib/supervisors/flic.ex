defmodule Supervisors.Flic do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end


  def init(:ok) do
    children = [
      {
        MuonTrap.Daemon,
        [
          "/usr/bin/flicd",
          ["-f", "/usr/bin/flicd/buttons.sqlite3"]
        ]
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
