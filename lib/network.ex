defmodule Network do
  @moduledoc"""
  Create a simple neural network to train across relatively simple tasks.
  """

  @doc"""
  The primary function of a neural net is to learn to produce the right output from
  a given input (learning). The train call receives the scape and size and creates
  accordingly.

  ex: Network.train(:rubix, :small)
  """
  def train(scape, size) do
    Network.create(:ffnn, scape, size)
  end

  @doc"""
  default creation - calls Network.create(:ffnn, :xor, :medium)
  """
  def create do
    create(:ffnn, :xor, :medium)
  end

  def create(type, scape, size) do
    [c] = Cortex.generate(scape, type)
    neurons = Neuron.generate(size) #Empty neurons
    sensors = Interactor.generate(scape, :sensor)
      |> Enum.map(fn x -> Interactor.fanout_neurons(x, neurons) end)
    actuators = Interactor.generate(scape, :actuator)
      |> Enum.map(fn x -> Interactor.fanin_neurons(x, neurons) end)
    neurons_plus = Neuron.assign_inputs_outputs_and_weights(neurons, sensors, actuators) # Neurons assigned input_neurons, output_neurons, and weights
                  |> Enum.map(fn x -> %{x | cortex_id: c.id} end) # Neurons given cx_id
    sensors_plus = Enum.map(sensors, fn x -> %{x | cortex_id: c.id} end) # Sensors given cx_id
    actuators_plus = Enum.map(actuators, fn x -> %{x | cortex_id: c.id, output_pids: c.id} end) # Actuators given cx_id
    genotype = [neurons_plus, sensors_plus, actuators_plus, [c]]  
    genotype
  end

  def link_and_update(genotype) do
    [neurons, sensors, actuators, [cortex]] = genotype
    table = :ets.new(:table, [:set, :private])
    gen_pids(genotype, table) # Neurons, sensors, actuators spawned, pids send to :ets table. Fetched in the next line
    [neurons_plus_pids, sensors_plus_pids, actuators_plus_pids] = for x <- [neurons, sensors, actuators], do: Enum.map(x, fn y -> %{y | pid: :ets.lookup_element(table, y.id, 2)} end) 
    cortex_running = %{cortex | pid: spawn(Cortex, :run, [[neurons_plus_pids, sensors_plus_pids, actuators_plus_pids, cortex], table, [], [], self()])}
    neurons_plus_outs = Enum.map(neurons_plus_pids, fn x -> assign_output_pids(x, table) end)
    sensors_plus_outs = Enum.map(sensors_plus_pids, fn x -> assign_output_pids(x, table) end)
    actuators_plus_outs = Enum.map(actuators_plus_pids, fn x -> %{x | output_pids: cortex_running.pid} end)
    Enum.each(neurons_plus_outs, fn x -> send x.pid, {:update_pids, x.output_pids, cortex_running.pid} end)
    Enum.each(sensors_plus_outs, fn x -> send x.pid, {:update_pids_sensor, x.output_pids, cortex_running.pid} end)
    Enum.each(actuators_plus_outs, fn x -> send x.pid, {:update_pids_actuator, cortex_running.pid} end)
    [neurons_plus_outs, sensors_plus_outs, actuators_plus_outs, [cortex_running]]
  end

  def assign_output_pids(unit, table) do
    case unit.id do
      {:neuron, _} -> %{unit | output_pids: Enum.map(unit.output_neurons, fn x -> :ets.lookup_element(table, x, 2) end)}
      {:sensor, _} -> %{unit | output_pids: Enum.map(unit.fanout_ids, fn x -> :ets.lookup_element(table, x, 2) end)}
    end
  end

  @doc"""
  Receives phenotype and "activates" all nodes.
  """
  def gen_pids(genotype, table) do
    [neurons, sensors, actuators, [cortex]] = genotype
    n_list = set_pids(neurons, genotype)
    s_list = set_pids(sensors, genotype)
    a_list = set_pids(actuators, genotype)
    full_list = List.flatten([n_list, s_list, a_list])
    Enum.each(full_list, fn x -> :ets.insert(table, x) end)
  end

  @doc"""
  Creates a list of tuples - {node_id, pid}
  """
  def set_pids(list, genotype) do
    [head | tail] = list
    case head.id do
      {:actuator, id} -> Enum.map(list, fn x -> {x.id, spawn(Interactor, :run, [:actuator, genotype, []])} end)
      {:sensor, id}   -> Enum.map(list, fn x -> {x.id, spawn(Interactor, :run, [:sensor, genotype, []])} end)
      {:neuron, id}   -> Enum.map(list, fn x -> {x.id, spawn(Neuron, :run, [x, []])} end)
    end
  end
end

