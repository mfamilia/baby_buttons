defmodule Service.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    setup_database()

    children = [
      {Registry, keys: :duplicate, name: :messages},
      {Service.Flic.Supervisor, []},
      {Service.ButtonSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Service.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp setup_database do
    file = Application.get_env(:service, :flic_database_file)
      |> to_string()

    case File.exists?(file) do
      false ->
        File.cp!(@seed_database, file)
      _ ->
        nil
    end
  end
end
