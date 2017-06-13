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
  def run(genotype, table, generated_input, correct_output) do
    [n, s, a, c] = genotype
    receive do
      {:start, _} -> Transmit.list(:sensors, genotype, {:start, c.pid})
        run(genotype, table, [], [])
      {:sensor_input, input} -> run(genotype, table, input, Scape.get_output(c.scape, input))
      {:actuator_output, output} -> finish(genotype, generated_input, output, correct_output)
                         # Transmit.all(genotype, :terminate)
                         # IO.puts "terminating cortex"
                         # Process.exit(self(), :normal)
    end
  end

  def finish(genotype, input, output, correct_output) do
         IO.inspect genotype, label: "genotype"
         IO.inspect input, label: "generated input"
         IO.inspect output, label: "generated output"
         IO.inspect correct_output, label: "expected output"
  end
end
