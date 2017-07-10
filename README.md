# NnFlightCoding

What started as an exercise to pass the time while in flight over the Atlantic, has begun the construction,
from scratch, of a functional Neural Net constructor.

`mix test` runs a trainer over a simple ffnn for 30 iterations.

To train an XOR gate, run the following code.
```elixir
Train.genotype(30)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nn_flight_coding` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:nn_flight_coding, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/nn_flight_coding](https://hexdocs.pm/nn_flight_coding).

## License

MIT

