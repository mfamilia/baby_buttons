defmodule Service.Flic.Response.Connection do
  import ShorterMaps

  @moduledoc """
  Message Utility translating binary messages into data maps.
  """

  @doc """
  Get general information from binary data.

  ## Examples

      iex> data = <<1, 0, 0, 0, 0, 1>>
      iex> Service.Flic.Response.Connection.create_channel_response(data)
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

  @doc """
  Get connection changed information from binary data.

  ## Examples

      iex> data = <<0, 0, 0, 0, 0, 0>>
      iex> Service.Flic.Response.Connection.connection_changed_response(data)
      %{
        conn_id: 0,
        reason: :unspecified,
        conn_status: :disconnected
      }

      iex> data = <<0, 0, 0, 0, 1, 0>>
      iex> Service.Flic.Response.Connection.connection_changed_response(data)
      %{
        conn_id: 0,
        reason: :unspecified,
        conn_status: :connected
      }

      iex> data = <<0, 0, 0, 0, 2, 0>>
      iex> Service.Flic.Response.Connection.connection_changed_response(data)
      %{
        conn_id: 0,
        reason: :unspecified,
        conn_status: :ready
      }

  """
  def connection_changed_response(data) do
    <<
      conn_id::bytes-size(4),
      status::size(8),
      info::size(8)
    >> = data

    conn_id = :binary.decode_unsigned(conn_id, :little)
    reason = reason_info(info)
    conn_status = conn_info(status)

    ~M{
      conn_id,
      reason,
      conn_status
    }
  end

  defp reason_info(error) do
    case error do
      0 ->
        :unspecified
      1 ->
        :establishment_failed
      2 ->
        :timeout
      3 ->
        :keys_mismatch
    end
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
