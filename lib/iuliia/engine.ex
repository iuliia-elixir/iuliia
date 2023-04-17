defmodule Iuliia.Engine do
  @moduledoc false
  # Engine provides main transliteration logic.

  @ending_length 2

  alias Iuliia.Schema

  @doc """
  Transliterates string using chosen schema.

  ## Example

      iex> Iuliia.transliterate("Юлия, съешь ещё этих мягких французских булок из Йошкар-Олы, да выпей алтайского чаю", "mvd_782")
      "Yuliya, syesh' eshche etikh myagkikh frantsuzskikh bulok iz Yoshkar-Oly, da vypey altayskogo chayu"
  """
  @spec transliterate(String.t(), Schema.t(), Keyword.t()) :: String.t()
  def transliterate(string, %Schema{} = schema, opts) do
    opts = Map.new(opts)

    string
    |> String.split(~r/\b/u, trim: true)
    |> Enum.map_join(&translit_chunk(schema, &1, opts))
  end

  defp translit_chunk(schema, chunk, opts) do
    with true <- String.match?(chunk, ~r/\p{L}+/u),
         {stem, ending} when ending not in [""] <- split_word(chunk),
         te when not is_nil(te) <- map(schema, :ending_mapping, ending) do
      translit_stem(schema, stem, opts) <> te
    else
      false ->
        chunk

      _ ->
        translit_stem(schema, chunk, opts)
    end
  end

  defp split_word(word), do: split_word(word, String.length(word))

  defp split_word(word, len) when len <= @ending_length, do: {word, ""}

  defp split_word(word, len) do
    stem =
      case String.slice(word, 0..(len - @ending_length - 1)) do
        "" -> word
        string -> string
      end

    {stem, String.slice(word, -@ending_length..-1)}
  end

  defp translit_stem(schema, stem, opts) do
    stem
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.map_join(fn {char, index} ->
      translit_char(schema, String.codepoints(stem), char, index, opts)
    end)
    |> camelcase(stem)
  end

  def translit_char(schema, chars, char, index, opts) do
    with nil <- translit_prev(schema, chars, index),
         nil <- translit_next(schema, chars, index) do
      map(schema, :mapping, String.downcase(char), opts) |> camelcase(char)
    else
      translited_char -> translited_char
    end
  end

  defp translit_prev(schema, [char | _], 0) do
    map(schema, :prev_mapping, String.downcase(char))
  end

  defp translit_prev(schema, chars, index) do
    char =
      chars
      |> Enum.slice((index - 1)..index)
      |> Enum.join()
      |> String.downcase()

    map(schema, :prev_mapping, char)
  end

  defp translit_next(schema, chars, index) do
    next_char =
      chars
      |> Enum.slice(index..(index + 1))
      |> Enum.join()
      |> String.downcase()

    map(schema, :next_mapping, next_char)
  end

  defp camelcase(nil, _), do: nil

  defp camelcase(string, source) do
    if String.match?(source, ~r/[[:upper:]]/u) do
      downcased_string = String.downcase(string)

      first_sym =
        downcased_string
        |> String.at(0)
        |> String.upcase()

      ending =
        downcased_string
        |> String.slice(1..String.length(downcased_string))

      first_sym <> ending
    else
      string
    end
  end

  # Helper for mapping characters
  defp map(schema, mapping_key, char) do
    case schema do
      %{^mapping_key => %{^char => replacement}} ->
        replacement

      _ ->
        nil
    end
  end

  defp map(schema, mapping_key, char, opts) do
    case {schema, opts} do
      {%{^mapping_key => %{^char => replacement}}, _} ->
        replacement

      {_, %{drop_latin: true}} ->
        nil

      {_, _} ->
        char
    end
  end
end
