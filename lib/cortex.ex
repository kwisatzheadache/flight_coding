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
  def run(genotype, table, generated_input, correct_output, network_pid) do
    [n, s, a, c] = genotype
    receive do
      {:start, _} -> Transmit.list(:sensors, genotype, {:start, self()})
        run(genotype, table, [], [], network_pid)
      {:sensor_input, {scape, input}} -> run(genotype, table, input, Scape.get_output(c.scape, input), network_pid)
      {:actuator_output, {actuator_id, actuator_name}, output} -> send network_pid, {:nn_output, generated_input, correct_output, output}
        IO.inspect [generated_input, correct_output, output], label: 'gen_input, correct_input, output'
        run(genotype, table, generated_input, correct_output, network_pid)
      {:test, :actuator} -> IO.puts "received from actuator"
        run(genotype, table, generated_input, correct_output, network_pid)
      {:test, _} -> Transmit.list(:sensors, genotype, {:test, 4})
        run(genotype, table, generated_input, correct_output, network_pid)
      {:terminate, _} -> Process.exit(self(), :kill)
    end
  end
end
