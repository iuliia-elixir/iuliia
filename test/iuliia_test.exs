defmodule IuliiaTest do
  use ExUnit.Case
  doctest Iuliia

  describe ".transliterate" do
    test "transliterates samples" do
      for schema_path <- Path.wildcard("priv/schemas/*.json") do
        schema = schema_path |> File.read!() |> Jason.decode!()
        schema_name = schema["name"]

        for [input, output] <- schema["samples"] do
          assert Iuliia.transliterate(input, schema_name, load: true) == output
        end
      end
    end
  end
end
