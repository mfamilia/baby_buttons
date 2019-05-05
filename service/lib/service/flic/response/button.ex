defmodule Service.Flic.Response.Button do
  import ShorterMaps

  @moduledoc """
  Message Utility translating binary messages into data maps.
  """

  @doc """
  Get general information from binary data.

  ## Examples

      iex> data = <<0, 0, 0, 0, 1, 1, 212, 18, 0, 0>>
      iex> Service.Flic.Response.Button.button_info_response(data)
      %{
        conn_id: 0,
        interaction_type: :button_up,
        was_queued: true,
        time_diff: 4820
      }

      iex> data = <<0, 0, 0, 0, 0, 1, 212, 18, 0, 0>>
      iex> Service.Flic.Response.Button.button_info_response(data)
      %{
        conn_id: 0,
        interaction_type: :button_down,
        was_queued: true,
        time_diff: 4820
      }

      iex> data = <<0, 0, 0, 0, 2, 1, 212, 18, 0, 0>>
      iex> Service.Flic.Response.Button.button_info_response(data)
      %{
        conn_id: 0,
        interaction_type: :button_press,
        was_queued: true,
        time_diff: 4820
      }

      iex> data = <<0, 0, 0, 0, 3, 1, 225, 18, 0, 0>>
      iex> Service.Flic.Response.Button.button_info_response(data)
      %{
        conn_id: 0,
        interaction_type: :button_single_press,
        was_queued: true,
        time_diff: 4833
      }

  """
  def button_info_response(data) do
    <<
      conn_id::bytes-size(4),
      info::size(8),
      queued::size(8),
      time::bytes-size(4)
    >> = data

    conn_id = :binary.decode_unsigned(conn_id, :little)
    interaction_type = interaction_type(info)
    was_queued = queued != 0
    time_diff = :binary.decode_unsigned(time, :little)

    ~M{
      conn_id,
      interaction_type,
      was_queued,
      time_diff
    }
  end

  defp interaction_type(info) do
    case info do
      0 ->
        :button_down
      1 ->
        :button_up
      2 ->
        :button_press
      3 ->
        :button_single_press
      4 ->
        :button_double_press
      5 ->
        :button_hold
    end
  end
end
