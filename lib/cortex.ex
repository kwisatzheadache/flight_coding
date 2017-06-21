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
  # run/4
  def run(genotype, network_pid, table) do
    receive do
      {:start, counter} -> iterate(genotype, counter, network_pid, [], [], :start)
      {:terminate, _} -> Process.exit(self(), :kill)
    end
  end

  # run/6
  def iterate(genotype, counter, network_pid, table, acc, state) do
    [n, s, a, c] = genotype
    if counter == 0 do
      finish(genotype, network_pid, table)
    else
      case state do
        :start -> Transmit.list(:sensors, genotype, {:start, self(), counter})
        :wait -> :ok
      end
      receive do
        {:sensor_input, {scape, input}} -> 
          iterate(genotype, counter, network_pid, table, {counter, input, Scape.get_output(c.scape, input)}, :wait)
        {:actuator_output, {actuator_id, actuator_name}, output} -> 
          # send network_pid, {:nn_output, generated_input, correct_output, output}
          {counter, acc_input, acc_output} = acc
          iterate(genotype, counter - 1, network_pid, [{counter, acc_input, acc_output, output} | table], [], :start)
        {:terminate, _} -> Process.exit(self(), :kill)
      end
    end
  end

  def finish(genotype, network_pid, table) do
    # table is list of tuples... {count, input, corr_output, output}
    total_wrong = Enum.sum(Enum.map(table, fn {count, input, [corr_out], out} -> case corr_out == out do
                                                                   true -> 0
                                                                   false -> 1
                                                                 end end))
    error = total_wrong / length(table)
    send network_pid, {:nn_error, error, length(table)}
  end
end
