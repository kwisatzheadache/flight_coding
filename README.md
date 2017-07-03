# NnFlightCoding

What started as an exercise to pass the time while in flight over the Atlantic, has begun the construction,
from scratch, of a functional Neural Net constructor.

`mix test` runs a trainer over a simple ffnn for 30 iterations.

## Currently, 

It is fully functioning as a genotype generator. 

Furthermore, the genotype is automatically started in a process so that it can be accessed quickly, 
rather than passing it in each function call.

7/3
The network is training on XOR gates. I can't seem to get it to perform better than 80% correct. Which is strange, because
the network never starts at lower than 43% correct. 

The network trains though. I've added a new Training module - Train.network_average in response to the fact that since
the XOR is randomly generated, each nn performs differently within it's own iterations... It's somewhat difficult to explain.
Basically, one can see when training it that the best fitness is apparently not always kept in the next iteration. This is
not actually the case - what happens is it takes the genotype with the best fitness for that iteration and passes it on; 
however, the nn performs differently in the next stage because the input is random.
Train.network_average seeks to address this by running the Network.link_and_process/1 module a number of times, then 
passing the average score to the training module for the fitness score. It is an improvement over the previous model, 
however, I'm not completely happy with it.

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

