defmodule Iuliia.Application do
  @moduledoc """
  Iuliia Application which just preloads schemas at startup
  """

  use Application
  alias Iuliia.Schema

  @impl true
  def start(_type, _args) do
    schemas = Application.get_env(:iuliia, :schemas, [])
    Schema.load_schemas(schemas)

    opts = [strategy: :one_for_one, name: Iuliia.Supervisor]
    Supervisor.start_link([], opts)
  end

  @impl true
  def config_change(changed, new, removed) do
    cond do
      removed[:schemas] ->
        Schema.clear_schemas()

      schemas = changed[:schemas] || new[:schemas] ->
        Schema.load_schemas(schemas)

      true ->
        Schema.reload_schemas()
    end
  end
end
