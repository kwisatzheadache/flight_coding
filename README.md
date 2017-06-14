# NnFlightCoding

What started as an exercise to pass the time while in flight over the Atlantic, has begun the construction,
from scratch, of a functional Neural Net constructor.

I will endeavor to ensure that the simple command ``` Network.create ``` will show off the extent of this 
project's capacities. Please, feel free to fork and pick up wherever I leave off.

## Currently, 

It is fully functioning as a genotype generator. 

Furthermore, the genotype is automatically started in a process so that it can be accessed quickly, 
rather than passing it in each function call.

6/13
Ran into a very strange issue with the Scape.generate_input(scape) function.
It seems to have resolved, not entirely sure how or what I did.

At any rate, it all seems to work better now. `Network.create` generates a NN,
runs the `:xor` scape and outputs a number. Now to begin the training process.

6/14
It looks like I need to rewrite a bunch of this... The nn tranmission is just too sloppy. 
I'll probably revert back to yesterdays commit, then rebuild the constructor, separating the 
genotyper and the PID assignment, so that the processes don't have to be updated. Then
I'll have to redo some of the `send x.pid` bits to reflect the update.
The good news is, I understand it all better now. The bad news is I have to rewrite a bunch of code.
It's good practice though and afterward, it will all be cleaner this way.

```elixir
Network.create
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

