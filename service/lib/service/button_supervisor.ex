defmodule Service.ButtonSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts(:stderr, :start_link)
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Service.Button, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
