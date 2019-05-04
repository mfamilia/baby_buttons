defmodule Service.Flic.Response.CreateChannel do
  import ShorterMaps

  @moduledoc """
  Message Utility translating binary messages into data maps.
  """

  @doc """
  Get general information from binary data.

  ## Examples

      iex> data = <<1, 0, 0, 0, 0, 1>>
      iex> Service.Flic.Response.CreateChannel.create_channel_response(data)
      %{
        conn_id: 1,
        error: :no_error,
        conn_status: :connected
      }

  """
  def create_channel_response(data) do
    <<
      conn_id::bytes-size(4),
      error::size(8),
      status::size(8)
    >> = data

    conn_id = :binary.decode_unsigned(conn_id, :little)
    error = error_info(error)
    conn_status = conn_info(status)

    ~M{
      conn_id,
      error,
      conn_status
    }
  end

  defp error_info(error) do
    case error do
      0 ->
        :no_error

      1 ->
        :max_pending_connections_reached
    end
  end

  defp conn_info(status) do
    case status do
      0 ->
        :disconnected

      1 ->
        :connected

      2 ->
        :ready
    end
  end
end
