defmodule ProcManager do
  @callback on_init(init_arg :: term) :: :ok | :error

  defmacro __using__(_opts) do
    quote do
      @behaviour ProcManager

      use Supervisor

      @spec start_link(arg :: any()) :: Supervisor.on_start()
      def start_link(arg) do
        Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
      end

      @impl true
      def init(_) do
        children = [
          {Registry, name: ProcManager.Registry, keys: :unique},
          {ProcManager.DynamicSupervisor, &on_init/1}
        ]

        Supervisor.init(children, strategy: :one_for_one)
      end
    end
  end

  @spec start_child(module :: module(), args :: any()) :: DynamicSupervisor.on_start_child()
  def start_child(module, args) do
    DynamicSupervisor.start_child(ProcManager.DynamicSupervisor, {module, args})
  end

  @spec terminate_child(pid :: pid()) :: :ok | {:error, :not_found}
  def terminate_child(pid) do
    DynamicSupervisor.terminate_child(ProcManager.DynamicSupervisor, pid)
  end
end
