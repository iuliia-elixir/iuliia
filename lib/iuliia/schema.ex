defmodule Iuliia.Schema do
  @moduledoc """
  Schema provides methods to work with available transliteration schemas.
  """

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
  @spec lookup(String.t()) :: map()
  def lookup(schema) do
    with {:ok, file} <- File.read("lib/schemas/#{schema}.json"),
         {:ok, data} <- Jason.decode(file) do
      data
    else
      {:error, :enoent} ->
        raise ArgumentError, "Can not find schema #{schema}}"

      {:error, error} when is_map(error) ->
        raise ArgumentError, "Can not parse schema #{schema}: #{error}}"
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
  @spec available_schemas() :: list(map())
  def available_schemas do
    for schema_path <- Path.wildcard("lib/schemas/*.json") do
      schema_path |> File.read!() |> Jason.decode!() |> Map.fetch!("name")
    end
  end
end
