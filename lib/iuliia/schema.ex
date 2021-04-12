defmodule Iuliia.Schema do
  @moduledoc """
  Schema provides methods to work with available transliteration schemas.
  """

  @doc """
  Lookup for schema by schema name and returns schema data.
  Raises `ArgumentError` if there is no such schema.
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
    case File.read("lib/schemas/#{schema}.json") do
      {:ok, body} -> Jason.decode!(body)
      _ -> raise ArgumentError, "Can not find schema #{schema}}"
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
      schema = schema_path |> File.read!() |> Jason.decode!()
      schema["name"]
    end
  end
end
