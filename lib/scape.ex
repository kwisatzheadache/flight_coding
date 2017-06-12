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
  def generate_input(scape) do
    {[input_1, input_2], []} = scape_to_call(scape, :input)
                               |> Code.eval_quoted
    [input_1, input_2]
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
