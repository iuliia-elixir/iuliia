defmodule Iuliia.Schema do
  @moduledoc false
  # Schema provides methods to work with available transliteration schemas.

  @enforce_keys [:filename]
  defstruct [
              mapping: %{},
              prev_mapping: %{},
              next_mapping: %{},
              ending_mapping: %{}
            ] ++ @enforce_keys

  @type name :: String.t()

  @type mapping :: %{binary() => binary()}

  @type t :: %__MODULE__{
          filename: Path.t(),
          mapping: mapping(),
          prev_mapping: mapping(),
          next_mapping: mapping(),
          ending_mapping: mapping()
        }

  @type schemas_to_load :: [{name(), Path.t()} | {name(), t()} | name()]

  @spec load_schemas(schemas_to_load()) :: :ok
  def load_schemas(schemas_to_load) do
    schemas = Map.new(schemas_to_load, &load_schema/1)
    :persistent_term.put(__MODULE__.Cache, schemas)
    :ok
  end

  @spec append_schemas(schemas_to_load()) :: :ok
  def append_schemas(schemas_to_load) do
    schemas = :persistent_term.get(__MODULE__.Cache, %{})
    new = Map.new(schemas_to_load, &load_schema/1)
    :persistent_term.put(__MODULE__.Cache, Map.merge(schemas, new))
    :ok
  end

  @spec clear_schemas() :: :ok
  def clear_schemas do
    :persistent_term.erase(__MODULE__.Cache)
    :ok
  end

  @spec reload_schemas() :: :ok
  def reload_schemas do
    __MODULE__.Cache
    |> :persistent_term.get(%{})
    |> Enum.map(fn {name, %{filename: filename}} -> {name, filename} end)
    |> load_schemas()

    :ok
  end

  @doc """
  Lookup for schema by schema name and returns schema data.
  Raises `ArgumentError` if there is no such schema or schema can not be parsed.

  ## Example

      iex> Iuliia.Schema.lookup("wikipedia")
      %{
        "description" => "Wikipedia transliteration schema",
        "ending_mapping" => %{"ий" => "y", "ый" => "y"},
        ...
      }
  """
  @spec lookup(name(), [{:load, t() | Path.t() | true}]) :: t()
  def lookup(name, opts \\ []) do
    case :persistent_term.get(__MODULE__.Cache, %{}) do
      %{^name => schema} ->
        schema

      _ ->
        if load = opts[:load] do
          append_schemas([{name, load}])
          lookup(name)
        else
          raise ArgumentError, "Schema #{name} is not present"
        end
    end
  end

  @doc """
  Returns all available schemas names

  ## Example

      iex> Iuliia.Schema.available_schemas()
      ["ala_lc", "ala_lc_alt", "bgn_pcgn", "bgn_pcgn_alt", "bs_2979", "bs_2979_alt",
      "gost_16876", "gost_16876_alt", "gost_52290", "gost_52535", "gost_7034",
      "gost_779", "gost_779_alt", "icao_doc_9303", "iso_9_1954", "iso_9_1968",
      "iso_9_1968_alt", "mosmetro", "mvd_310", "mvd_310_fr", "mvd_782", "scientific",
      "telegram", "ungegn_1987", "wikipedia", "yandex_maps", "yandex_money"]
  """
  @spec available_schemas() :: [String.t()]
  def available_schemas() do
    Map.keys(:persistent_term.get({__MODULE__.Cache}, %{}))
  end

  # Loads schema from file
  @spec load_schema(name() | {name(), Path.t() | t() | true}) :: {name(), t()}
  defp load_schema({name, true}) do
    load_schema(name)
  end

  defp load_schema(name) when is_binary(name) do
    load_schema({name, "#{:code.priv_dir(:iuliia)}/schemas/#{name}.json"})
  end

  defp load_schema({name, filename}) when is_binary(filename) do
    with {:ok, file} <- File.read(filename),
         {:ok, data} <- Jason.decode(file) do
      # Note that atoms for the `String.to_existing_atom` are instantiated here
      schema =
        Enum.reduce(data, %__MODULE__{filename: filename}, fn
          {key, value}, schema when key in ~w[mapping prev_mapping next_mapping ending_mapping] ->
            %{schema | String.to_existing_atom(key) => value}

          _, schema ->
            schema
        end)

      {name, schema}
    else
      {:error, error} when is_map(error) ->
        raise ArgumentError, "Can not parse schema #{filename}: #{error}"

      {:error, :enoent} ->
        raise ArgumentError, "Can not find schema #{filename}"
    end
  end

  defp load_schema({name, %__MODULE__{} = schema}), do: {name, schema}
end
