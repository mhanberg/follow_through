defmodule ProcManager.DynamicSupervisor do
  use DynamicSupervisor

  @spec start_link(on_init :: (any() -> any())) :: Supervisor.on_start()
  def start_link(on_init) do
    pid = DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
    Task.start_link(fn -> on_init.(nil) end)
    pid
  end

  @impl true
  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)
end
