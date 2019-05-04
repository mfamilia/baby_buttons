defmodule Service.Broadcast do
  @name :messages

  def broadcast_to(topic, payload) do
    Registry.dispatch(@name, topic, fn entries ->
      for {pid, _} <- entries do
        GenServer.cast(pid, {
          topic,
          payload
        })
      end
    end)
  end

  def listen_to(topic) do
    Registry.register(@name, topic, [])
  end

  def stop_listening_to(topic) do
    Registry.unregister(@name, topic)
  end
end
