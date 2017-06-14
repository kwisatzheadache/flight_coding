defmodule Cortex do
  @moduledoc"""
  """

  defstruct id: nil, pid: nil, scape: nil, type: :ffnn

  @doc"""
  """
  def generate(scape, type) do
    case is_atom(scape) and is_atom(type) do
      true -> [%Cortex{id: {:cortex, Generate.id}, scape: scape, type: type}]
      false -> IO.puts "scape and type must both be atoms"
    end
  end

  @doc"""
  Sends init message to sensors, upon receiving :start message
  """
  def run(genotype, table, generated_input, correct_output, self) do
    [n, s, a, c] = genotype
    receive do
      {:start, self_pid} -> Transmit.list(:sensors, genotype, {:start, self()})
        run(genotype, table, [], [], self_pid)
      {:sensor_input, {scape, input}} -> run(genotype, table, input, Scape.get_output(c.scape, input), self)
      {:nn_output, output} -> finish(genotype, generated_input, [output], correct_output, self)
                           Transmit.all(genotype, :terminate)
                         # IO.puts "terminating cortex"
                         # Process.exit(self(), :normal)
    end
  end

  def finish(genotype, input, actual_output, correct_output, self) do
    output = case actual_output <= 0 do
              true -> -1
              false -> 1
            end
    send self, {:completion_data, [input, output, correct_output]}
  end
end
