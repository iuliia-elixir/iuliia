defmodule Iuliia do
  @moduledoc """
  Main module.
  """

  @doc false
  @spec translate(any()) :: nil
  def translate(_), do: raise(ArgumentError, message: "Schema required")

  @doc """
  Transliterates string using chosen schema.
  ## Example
      iex> Iuliia.translate("Юлия, съешь ещё этих мягких французских булок из Йошкар-Олы, да выпей алтайского чаю", "mvd_782")

      "Yuliya, syesh' eshche etikh myagkikh frantsuzskikh bulok iz Yoshkar-Oly, da vypey altayskogo chayu"
  """
  @spec translate(String.t(), String.t()) :: String.t()
  def translate(string, schema_name) when is_binary(string) do
    Iuliia.Engine.translate(string, schema_name)
  end

  def translate(non_string, _), do: non_string
end
