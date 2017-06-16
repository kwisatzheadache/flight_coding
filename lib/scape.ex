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
    {input, []} = scape_to_call(scape, :input)
                               |> Code.eval_quoted
    input
  end

  def test do
    generate_input(:xor)
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

# note - change xor to be random
  def xor(call) do
    value = Enum.random([0, 1, 2, 3])
    xor_data = [{[1, 1], [-1]},
                 {[1, -1], [1]},
                 {[-1, 1], [1]},
                 {[-1, -1], [-1]}]
    {input, correct_output} = Enum.at(xor_data, 1)
    case call do
      :input -> {:xor, input}
      :output -> correct_output
    end
  end

  def xor_output(input) do
    case input do
      [1, 1] -> [-1]
      [-1, 1] -> [1]
      [1, -1] -> [1]
      [-1, -1] -> [-1]
    end
  end

  def get_output(scape, input) do
    xor_output(input)
    # case scape do
    #   :xor -> xor_output(input)
    #   _ -> IO.puts "error message from scape.ex line 51"
    # end
  end
end
