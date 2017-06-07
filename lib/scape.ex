defmodule Scape do
  @moduledoc"""
  Manage scapes - how input vectors are created and output vectors interpreted
  """
  defmacro scape_to_call(scape, call) do
    ast = quote do
            {{:., [], [{:__aliases__, [alias: false], [:Scape]}, unquote(scape)]}, [], [unquote(call)]}
          end
  end

  @doc"""
  """
  def generate_input(genotype) do
    [scape] = Enum.at(genotype, 1)
         |> Enum.map(fn x -> x.scape end)
    Code.eval_quoted(scape_to_call(scape, :input))
  end

  def cube(call) do
    case call do
      :input -> [1,2,3]
      :output -> IO.puts "NN sending output"
    end
  end

  def rng(call) do
    case call do
      :input -> [:random.uniform(), :random.uniform()]
      :output -> IO.puts "NN sending output"
    end
  end


  def xor(call) do
    case call do
      :input -> IO.puts "xor call working"
    end
  end
end
