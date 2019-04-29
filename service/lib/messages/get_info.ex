defmodule Messages.GetInfo do
  import ShorterMaps

  @moduledoc """
  Message Utility translating binary messages into data maps.
  """

  @doc """
  Get general information request binary.

  ## Examples

      iex> Messages.GetInfo.get_info_request()
      <<1, 0, 0>>

  """
  def get_info_request(), do: <<1, 0, 0>>

  @doc """
  Get general information from binary data.

  ## Examples

      iex> data = <<2, 48, 50, 137, 235, 39, 184, 0, 128, 255, 255, 0, 0, 4, 0, 93, 15, 117, 218, 228, 128, 78, 32, 117, 218, 228, 128, 80, 32, 117, 218, 228, 128, 95, 32, 117, 218, 228, 128>>
      iex> Messages.GetInfo.get_info(data)
      %{
        controller_state: :attached,
        server_address: <<48, 50, 137, 235, 39, 184>>,
        server_address_type: :public,
        max_pending_connections: 128,
        max_concurrent_connected_buttons: -1,
        current_pending_connections: 0,
        new_connections_allowed: true,
        button_addresses: [
          <<95, 32, 117, 218, 228, 128>>,
          <<80, 32, 117, 218, 228, 128>>,
          <<78, 32, 117, 218, 228, 128>>,
          <<93, 15, 117, 218, 228, 128>>,
        ]
      }

  """
  def get_info(data) do
    <<
      status :: size(8),
      server :: bytes-size(7),
      connection :: bytes-size(5),
      _button_count :: size(16),
      addresses :: binary,
    >> = data

    controller_state = controller_info(status)
    {server_address, server_address_type} = server_info(server)

    {
      max_pending_connections,
      max_concurrent_connected_buttons,
      current_pending_connections,
      new_connections_allowed,
    } = connection_info(connection)

    button_addresses = buttons_info(addresses, [])

    ~M{
      controller_state,
      server_address,
      server_address_type,
      max_pending_connections,
      max_concurrent_connected_buttons,
      current_pending_connections,
      new_connections_allowed,
      button_addresses
    }
  end

  defp controller_info(status) do
    case status do
      0 ->
        :detached
      1 ->
        :resetting
      2 ->
        :attached
    end
  end

  defp server_info(server) do
    << address :: bytes-size(6), type :: size(8) >> = server

    address_type =
      case type do
        0 ->
          :public
        _ ->
          :random
      end

    {address, address_type}
  end

  defp connection_info(connection) do
    <<
      max_pending :: size(8),
      max_concurrent :: signed-size(16),
      pending_connetions :: size(8),
      new_allowed :: size(8)
    >> = connection

    new_allowed = new_allowed == 0

    {
      max_pending,
      max_concurrent,
      pending_connetions,
      new_allowed
    }
  end

  defp buttons_info(<<>>, acc), do: acc

  defp buttons_info(addresses, acc) do
    << address :: bytes-size(6), addresses :: binary >> = addresses

    buttons_info(addresses, [address | acc])
  end
end
