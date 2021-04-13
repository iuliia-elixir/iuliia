# Iuliia

Small elixir lib to properly transliterate cyrillic to latin. Uses https://github.com/nalgeon/iuliia for transliteration schemas.

## Installation

```elixir
def deps do
  [
    {:iuliia, "~> 0.1.2"}
  ]
end
```

## Documentation

Available at [https://hexdocs.pm/iuliia](https://hexdocs.pm/iuliia)

## Usage

Get available schemas (dynamically generated from JSON definitions in lib/schemas)

```elixir
Iuliia.Schema.available_schemas

["ala_lc", "ala_lc_alt", "bgn_pcgn", "bgn_pcgn_alt", "bs_2979", "bs_2979_alt",
  "gost_16876", "gost_16876_alt", "gost_52290", "gost_52535", "gost_7034",
  "gost_779", "gost_779_alt", "icao_doc_9303", "iso_9_1954", "iso_9_1968",
  "iso_9_1968_alt", "mosmetro", "mvd_310", "mvd_310_fr", "mvd_782", "scientific",
  "telegram", "ungegn_1987", "wikipedia", "yandex_maps", "yandex_money"]
```

Get one schema data

```elixir
Iuliia.Schema.lookup("wikipedia")

%{
  "description" => "Wikipedia transliteration schema",
  "ending_mapping" => %{"ий" => "y", "ый" => "y"},
  ...
}
```

Pick one and transliterate

```elixir
Iuliia.translate("Юлия, съешь ещё этих мягких французских булок из Йошкар-Олы, да выпей алтайского чаю", "mvd_782")

"Yuliya, syesh' eshche etikh myagkikh frantsuzskikh bulok iz Yoshkar-Oly, da vypey altayskogo chayu"
```

## Development
Check out repo:
```
git clone git@github.com:adnikiforov/iuliia-rb.git
```

Setup dependencies:
```
mix deps.get
```

Run specs:

```
mix test
```

Or open console to try it:

```
iex -S mix
```

Before PR please run

```
mix format
mix credo
mix test
```

## Support

<p>
  <a href="https://evrone.com/?utm_source=github&utm_campaign=iuliia-rb">
    <img src="https://evrone.com/logo/evrone-sponsored-logo.png"
      alt="Sponsored by Evrone" width="210">
  </a>
</p>

## License

The lib is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
