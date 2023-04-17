defmodule Iuliia do
  @moduledoc """
  Public module for translating strings

  ## Using

  Just use `transliterate/3`. If you don't know the schema, you can use

  ## Configuring

  Configuring this project.

  ```elixir
  config :iuliia, :schemas, [
    "one",                         # Will be loaded from priv/schemas/one.json
    {"two", "/path/to/file.json"}  # Will be loaded from path/to/file.json
  ]
  ```

  Project will reload all schemas on any config change
  """

  alias Iuliia.Engine
  alias Iuliia.Schema

  @typedoc """
  * `:load` -- to load schema in runtime
  * `:drop_latin` (default: false) -- to drop latin characters during transliteration
  """
  @type option ::
          {:load, Schema.t() | Path.t() | true}
          | {:drop_latin, boolean()}

  @doc """
  Transliterates string using chosen schema.

  ## Example

      iex> Iuliia.transliterate("Юлия, съешь ещё этих мягких французских булок из Йошкар-Олы, да выпей алтайского чаю", "wikipedia")
      "Yuliya, syesh yeshchyo etikh myagkikh frantsuzskikh bulok iz Yoshkar-Oly, da vypey altayskogo chayu"
  """
  @spec transliterate(String.t(), String.t(), [option()]) :: String.t()
  def transliterate(string, schema_name, opts \\ []) when is_binary(string) do
    schema = Schema.lookup(schema_name, opts)
    Engine.transliterate(string, schema, opts)
  end
end
