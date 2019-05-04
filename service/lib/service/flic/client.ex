defmodule Service.Flic.Client do
  use Connection

  import ShorterMaps
  import Service.Broadcast

  require Logger

  def start_link(opts) do
    Connection.start_link(__MODULE__, :ok, opts)
  end

  def send(conn, data), do: Connection.call(conn, {:send, data})

  def close(conn), do: Connection.call(conn, :close)

  def init(:ok) do
    listen_to(:flic_server_started)

    host = Application.get_env(:service, :flic_host)
    port = Application.get_env(:service, :flic_port)

    {:ok, ~M{host, port, sock: nil}}
  end

  def connect(_, ~M{host, port} = s) do
    case :gen_tcp.connect(host, port, [active: true]) do
      {:ok, sock} ->
        broadcast_to(:flic_client_started, self())

        {:ok, %{s | sock: sock}}

      {:error, _} ->
        {:backoff, 1000, s}
    end
  end

  def disconnect(info, %{sock: sock} = s) do
    :ok = :gen_tcp.close(sock)

    case info do
      {:close, from} ->
        Connection.reply(from, :ok)

      {:error, :closed} ->
        :error_logger.format("Connection closed~n", [])

      {:error, reason} ->
        reason = :inet.format_error(reason)
        :error_logger.format("Connection error: ~s~n", [reason])
    end

    {:connect, :reconnect, %{s | sock: nil}}
  end

  def handle_call(_, _, %{sock: nil} = s) do
    {:reply, {:error, :closed}, s}
  end

  def handle_call({:send, data}, _, ~M{sock} = s) do
    case :gen_tcp.send(sock, data) do
      :ok ->
        {:reply, :ok, s}

      {:error, _} = error ->
        {:disconnect, error, error, s}
    end
  end

  def handle_call(:close, from, s) do
    {:disconnect, {:close, from}, s}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.debug("TCP_CLOSED")

    {:noreply, %{state | sock: nil}}
  end

  def handle_info({:tcp, socket, msg}, state) when is_list(msg) do
    handle_info({:tcp, socket, :binary.list_to_bin(msg)}, state)
  end

  def handle_info({:tcp, socket, msg}, state) do
    <<size::16-little, msg::binary>> = msg

    case byte_size(msg) do
      ^size ->
        broadcast_to(:flic_message_received, msg)

      _ ->
        <<msg::bytes-size(size), next_msg::binary>> = msg

        broadcast_to(:flic_message_received, msg)
        Kernel.send(self(), {:tcp, socket, next_msg})
    end

    {:noreply, state}
  end

  def handle_cast({:flic_server_started, _server}, state) do
    {:connect, :init, state}
  end
end
