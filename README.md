# NnFlightCoding

What started as an exercise to pass the time while in flight over the Atlantic, has begun the construction,
from scratch, of a functional Neural Net constructor.

`mix test` runs a trainer over a simple ffnn for 30 iterations.

## Currently, 

It is fully functioning as a genotype generator. 

Furthermore, the genotype is automatically started in a process so that it can be accessed quickly, 
rather than passing it in each function call.

6/20
Updating Cortex so that it cycles through the scape_count... In the case of XOR, 100 iterations. Figuring out how to fetch input, run the nn, store input, then rerun the entire thing.
With this update, it is noted that the scape must now provide a count number, corresponding to the size of the training set.

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

## TODO

- ~~Bring Documentation up to date~~
- ~~Change neuron ETS to avoid db overflow~~
- ~~Add bias~~
- ~~Add random weight generation to avoid getting stuck at local maximum~~
- Train over all 3 inputs of XOR
- Add other network types (aside form FFNN)
- Scape to encode output

## License

MIT

