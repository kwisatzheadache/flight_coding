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
  def run(genotype, training_counter, network_pid, in_out_table) do
    [n, s, a, [c]] = genotype
    receive do
      {:start, counter} ->
#       Transmit.list(:sensors, genotype, {:start, self(), counter})
        iterate(genotype, training_counter, network_pid, in_out_table, acc)
      # {:sensor_input, {scape, input}} -> run(genotype, table, [input | generated_input_table], [Scape.get_output(c.scape, input) | correct_output_table], network_pid)
      # {:actuator_output, {actuator_id, actuator_name}, output} -> send network_pid, {:nn_output, generated_input, correct_output, output}
      #   run(genotype, table, generated_input, correct_output, network_pid)
      # {:test, :actuator} -> IO.puts "received from actuator"
      #   run(genotype, table, generated_input, correct_output, network_pid)
      # {:test, _} -> Transmit.list(:sensors, genotype, {:test, 4})
      #   run(genotype, table, generated_input, correct_output, network_pid)
      {:terminate, _} -> Process.exit(self(), :kill)
    end
    if training_counter > 0 do
    Transmit.list(:sensors, genotype, {:start, self(), training_counter})
    end
  end

  # in_out_table looks like a series of these: {counter, input, corr_output, gen_output}, acc holds each tuple until it's full, then adds it as the head.
  def iterate(genotype, counter, network_pid, in_out_table, acc) do
    Transmit.list(:sensors, genotype, {:start, self(), counter})
    receive do
      {:sensor_input, {scape, gen_input}} -> iterate(genotype, in_out_table, {count, gen_input, Scape.get_output(c.scape, gen_input), nil})
      {:actuator_output, {actuator_id, actuator_name}, gen_output} -> {count, input, corr_output, _} = acc
        run(genotype, counter, network_pid, [{count, input, corr_output, gen_output} | in_out_table])
        # send network_pid, {:nn_output, generated_input, correct_output, gen_output}
        run(genotype, [{counter, input, corr_output, gen_output} | in_out_table], )
      {:test, :actuator} -> IO.puts "received from actuator"
        run(genotype, table, generated_input, correct_output, network_pid)
      {:test, _} -> Transmit.list(:sensors, genotype, {:test, 4})
        run(genotype, table, generated_input, correct_output, network_pid)
     
    end
  end

end
