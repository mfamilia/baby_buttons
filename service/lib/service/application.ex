defmodule Service.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Service.FlicSupervisor, []},
      {Service.ButtonSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Service.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
