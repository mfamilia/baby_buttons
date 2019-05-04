defmodule Service.Flic.Supervisor do
  use Supervisor

  alias Service.Flic.{Server, Client}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Server, []},
      %{
        id: Client,
        start: {Client, :start_link, [[]]}
      }
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
