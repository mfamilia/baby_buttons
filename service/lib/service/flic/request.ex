defmodule Service.Flic.Request do
  @get_info 0
  @create_connection_channel 3
  @low_latency 1
  @auto_disconnect_time 512

  @doc """
  Get general Info request binary.

  ## Examples

      iex> Service.Flic.Request.get_info_request()
      <<1, 0, 0>>

  """
  def get_info_request(), do: with_size(<<@get_info>>)

  @doc """
  Create Channel request request binary.

  ## Examples

      iex> conn_id = 1
      iex> address = <<95, 32, 117, 218, 228, 128>>
      iex> Service.Flic.Request.create_channel_request(conn_id, address)
      <<14, 0, 3, 1, 0, 0, 0, 95, 32, 117, 218, 228, 128, 1, 0, 2>>

  """
  def create_channel_request(conn_id, address) do
    <<
      @create_connection_channel::size(8),
      conn_id::32-little,
      address::binary,
      @low_latency::size(8),
      @auto_disconnect_time::16-little
    >>
    |> with_size()
  end

  defp with_size(binary) do
    size = byte_size(binary)

    <<size::16-little, binary::binary>>
  end
end
