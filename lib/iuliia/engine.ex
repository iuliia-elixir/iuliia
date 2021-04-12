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
    if String.match?(chunk, ~r/\p{L}+/u) do
      {stem, ending} = split_word(chunk)

      if ending == "" do
        translit_stem(schema, chunk)
      else
        translited_ending = schema["ending_mapping"][ending]

        if translited_ending == nil do
          translit_stem(schema, chunk)
        else
          [translit_stem(schema, stem), translited_ending] |> Enum.join()
        end
      end
    else
      chunk
    end
  end

  defp split_word(word) do
    if String.length(word) <= @ending_length do
      {word, ""}
    else
      ending =
        if String.length(word) > @ending_length,
          do: String.slice(word, -@ending_length..-1),
          else: ""

      stem =
        case String.slice(word, 0..(String.length(word) - @ending_length - 1)) do
          "" -> word
          string -> string
        end

      {stem, ending}
    end
  end

  defp translit_stem(schema, stem) do
    translited_stem =
      for {char, index} <- stem |> String.codepoints() |> Enum.with_index() do
        translit_char(schema, stem |> String.codepoints(), char, index)
      end

    translited_stem |> Enum.join() |> camelcase(stem)
  end

  defp translit_char(schema, chars, char, index) do
    translited_char = translit_prev(schema, chars, index)

    if translited_char == nil do
      translited_char = translit_next(schema, chars, index)

      if translited_char == nil do
        translited_char = schema["mapping"][char |> String.downcase()]
        if upcase?(char), do: translited_char |> String.upcase(), else: translited_char
      else
        translited_char
      end
    else
      translited_char
    end
  end

  defp translit_prev(schema, chars, index) when index > 0,
    do:
      chars
      |> Enum.slice((index - 1)..index)
      |> Enum.join()
      |> String.downcase()
      |> translit_prev(schema)

  defp translit_prev(schema, chars, index),
    do: chars |> Enum.at(index) |> String.downcase() |> translit_prev(schema)

  defp translit_prev(char, schema),
    do: schema["prev_mapping"][char]

  defp translit_next(schema, chars, index) do
    next_char = chars |> Enum.slice(index..(index + 1)) |> Enum.join() |> String.downcase()

    schema["next_mapping"][next_char]
  end

  defp camelcase(string, source) do
    if upcase?(source) do
      downcased_string = String.downcase(string)
      first_sym = downcased_string |> String.at(0) |> String.upcase()
      ending = downcased_string |> String.slice(1..String.length(downcased_string))

      first_sym <> ending
    else
      string
    end
  end

  defp upcase?(string), do: String.match?(string, ~r/[[:upper:]]/u)
end
