defmodule Iuliia.Engine do
  @moduledoc """
  Engine provides main transliteration logic.
  """
  @ending_length 2

  @doc """
  Transliterates string using chosen schema.
  ## Example
      iex> Iuliia.translate("Юлия, съешь ещё этих мягких французских булок из Йошкар-Олы, да выпей алтайского чаю", "mvd_782")

      "Yuliya, syesh' eshche etikh myagkikh frantsuzskikh bulok iz Yoshkar-Oly, da vypey altayskogo chayu"
  """
  @spec translate(String.t(), String.t()) :: String.t()
  def translate(string, schema_name) do
    schema = Iuliia.Schema.lookup(schema_name)

    translated_chunks =
      for word <- String.split(string, ~r/\b/u, trim: true), do: translit_chunk(schema, word)

    Enum.join(translated_chunks)
  end

  defp translit_chunk(schema, chunk) do
    with true <- String.match?(chunk, ~r/\p{L}+/u),
         {stem, ending} when ending not in [""] <- split_word(chunk),
         te when not is_nil(te) <- schema["ending_mapping"][ending] do
      [translit_stem(schema, stem), te] |> Enum.join()
    else
      false ->
        chunk

      _ ->
        translit_stem(schema, chunk)
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

  defp translit_stem(schema, stem) do
    translited_stem =
      for {char, index} <- stem |> String.codepoints() |> Enum.with_index() do
        translit_char(schema, stem |> String.codepoints(), char, index)
      end

    translited_stem |> Enum.join() |> camelcase(stem)
  end

  def translit_char(schema, chars, char, index) do
    with nil <- translit_prev(schema, chars, index),
         nil <- translit_next(schema, chars, index) do
      schema["mapping"][char |> String.downcase()] |> camelcase(char)
    else
      translited_char -> translited_char
    end
  end

  defp translit_prev(schema, chars, 0),
    do: chars |> Enum.at(0) |> String.downcase() |> translit_prev(schema)

  defp translit_prev(schema, chars, index),
    do:
      chars
      |> Enum.slice((index - 1)..index)
      |> Enum.join()
      |> String.downcase()
      |> translit_prev(schema)

  defp translit_prev(char, schema),
    do: schema["prev_mapping"][char]

  defp translit_next(schema, chars, index) do
    next_char = chars |> Enum.slice(index..(index + 1)) |> Enum.join() |> String.downcase()

    schema["next_mapping"][next_char]
  end

  defp camelcase(string, source) do
    if String.match?(source, ~r/[[:upper:]]/u) do
      downcased_string = String.downcase(string)
      first_sym = downcased_string |> String.at(0) |> String.upcase()
      ending = downcased_string |> String.slice(1..String.length(downcased_string))

      first_sym <> ending
    else
      string
    end
  end
end
