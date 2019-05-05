defmodule Service.Button do
  use GenServer

  alias Service.Flic.{
    Request,
    Response,
    Client
  }

  import Request

  import Response.{
    GetInfo,
    Connection,
    Button
  }

  import Service.Broadcast
  import ShorterMaps

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    listen_to(:flic_client_started)
    listen_to(:flic_message_received)

    {:ok, %{server: nil}}
  end

  def handle_cast({:flic_client_started, s}, state) do
    Logger.info("Client started")

    :ok = Client.send(s, get_info_request())

    {:noreply, %{state | server: s}}
  end

  def handle_cast({:flic_message_received, msg}, state) do
    {type, data} = get_parts(msg)

    action =
      case type do
        1 ->
          :handle_create_channel_data
        9 ->
          :handle_get_info_data
        n when n in [4, 6] ->
          :handle_button_info_data
        _ ->
          :handle_other_data
      end

    GenServer.cast(self(), {action, data})

    {:noreply, state}
  end

  def handle_cast({:handle_get_info_data, data}, state) do
    info = get_info_response(data)

    Logger.debug("Get Info: #{inspect(info)}")

    GenServer.cast(self(), {:create_button_channels, info})

    {:noreply, state}
  end

  def handle_cast({:handle_create_channel_data, data}, state) do
    info = create_channel_response(data)

    Logger.debug("Create Channel: #{inspect(info)}")

    {:noreply, state}
  end

  def handle_cast({:handle_button_info_data, data}, state) do
    info = button_info_response(data)

    Logger.debug("Button Info: #{inspect(info)}")

    {:noreply, state}
  end

  def handle_cast({:handle_other_data, data}, state) do
    {:noreply, state}
  end

  def handle_cast({:create_button_channels, ~M{button_addresses}}, state) do
    %{server: s} = state

    button_addresses
    |> Enum.with_index()
    |> Enum.each(fn {address, index} ->
      request = create_channel_request(index, address)
      Client.send(s, request)
    end)

    {:noreply, state}
  end

  defp get_parts(msg) do
    <<opcode::size(8), data::binary>> = msg

    {opcode, data}
  end
end
