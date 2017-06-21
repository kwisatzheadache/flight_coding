# NnFlightCoding

What started as an exercise to pass the time while in flight over the Atlantic, has begun the construction,
from scratch, of a functional Neural Net constructor.

`mix test` runs a trainer over a simple ffnn for 30 iterations.

## Currently, 

It is fully functioning as a genotype generator. 

Furthermore, the genotype is automatically started in a process so that it can be accessed quickly, 
rather than passing it in each function call.

6/20
Trainer is working properly now, cortex updated so that it cycles trhough properly. Problem with geno producing different outputs.... I think it's because the inputs are different each time... i.e. - xor is selected randomly. I need to change that.

Upon closer inspection, it seems that removing the randomness constricts the network, reducting error variance completely. Not sure why. But I'll look into the randomness impact more next time.

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

