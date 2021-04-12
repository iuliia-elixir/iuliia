defmodule IuliiaTest do
  use ExUnit.Case
  doctest Iuliia

  describe ".translate" do
    test "translates samples" do
      for schema_path <- Path.wildcard("lib/schemas/*.json") do
        schema = schema_path |> File.read!() |> Jason.decode!()

        schema_name = schema["name"]
        IO.puts(schema_name)

        for sample <- schema["samples"] do
          assert Iuliia.Engine.translate(Enum.at(sample, 0), schema_name) == Enum.at(sample, 1)
        end
      end
    end
  end

  describe ".lookup" do
    setup do
      schemas =
        for schema_path <- Path.wildcard("lib/schemas/*.json") do
          schema = schema_path |> File.read!() |> Jason.decode!()
          schema["name"]
        end

      {:ok, schema: schemas |> Enum.random()}
    end

    test "with existing schema name returns schema", %{schema: schema} do
      assert Iuliia.Schema.lookup(schema)["name"] == schema
    end

    test "with non-existing schema name raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        Iuliia.Schema.lookup(
          "vZ7GkWocXQZCXJkKsCT3h2vTddTxxJ9PvDapgM9B7J38oMowMn9yM38cCFMgdptPj7mUpUpDnWDnT2KQdUeVVcHNenfMAB7PoHsc"
        )
      end
    end
  end
end
