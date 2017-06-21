defmodule Cortex do
  @moduledoc"""
  Cortex begins the network - it sends initiatory signals to sensors, receives output - which is relayed to the network - then terminates all nodes.
  """

  defstruct id: nil, pid: nil, scape: nil, type: :ffnn

  @doc"""
  Used to in the genotyping stage. I guess, it's somewhat unimportant, except that the scape is set here, as well as the type. 
  """
  def generate(scape, type) do
    case is_atom(scape) and is_atom(type) do
      true -> [%Cortex{id: {:cortex, Generate.id}, scape: scape, type: type}]
      false -> IO.puts "scape and type must both be atoms"
    end
  end

  @doc"""
  Sends init message to sensors, upon receiving :start message
  run/5
  """
  # Perhaps run each iteration of input/output in a case clause? 
end
  def run(genotype, table, generated_input_table, correct_output_table, network_pid, training_counter) do
    [n, s, a, [c]] = genotype
    receive do
      {:start, counter} ->
        Transmit.list(:sensors, genotype, {:start, self(), counter})
        run(genotype, table, [], [], network_pid, counter - 1)
      {:sensor_input, {scape, input}} -> run(genotype, table, [input | generated_input_table], [Scape.get_output(c.scape, input) | correct_output_table], network_pid)
      {:actuator_output, {actuator_id, actuator_name}, output} -> send network_pid, {:nn_output, generated_input, correct_output, output}
        run(genotype, table, generated_input, correct_output, network_pid)
      {:test, :actuator} -> IO.puts "received from actuator"
        run(genotype, table, generated_input, correct_output, network_pid)
      {:test, _} -> Transmit.list(:sensors, genotype, {:test, 4})
        run(genotype, table, generated_input, correct_output, network_pid)
      {:terminate, _} -> Process.exit(self(), :kill)
    end
    if training_counter > 0 do
    Transmit.list(:sensors, genotype, {:start, self(), training_counter})
    end
  end
end
