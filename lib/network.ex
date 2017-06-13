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
    create(:ffnn, :rng, :medium)
  end

  def create(type, scape, size) do
    if is_atom(scape) do
    [c] = Cortex.generate(scape, type)
    table = :ets.new(:table, [:set, :private])
    n= Neuron.generate(size) #Empty neurons
    s= Interactor.generate(scape, :sensor)
      |> Enum.map(fn x -> Interactor.fanout_neurons(x, n) end)
    a= Interactor.generate(scape, :actuator)
      |> Enum.map(fn x -> Interactor.fanin_neurons(x, n) end)
    n1 = Neuron.assign_inputs_outputs_and_weights(n, s, a) # Neurons assigned input_neurons, output_neurons, and weights
    n2 = Enum.map(n1, fn x -> %{x | cx_id: c.id} end) # Neurons given cx_id
    s2 = Enum.map(s, fn x -> %{x | cx_id: c.id} end) # Sensors given cx_id
    a2 = Enum.map(a, fn x -> %{x | cx_id: c.id} end) # Actuators given cx_id
    genotype = [n2, s2, a2, [c]]  
    gen_pids(genotype, table) # Neurons, sensors, actuators spawned, pids send to :ets table. Fetched in the next line
    [n3, s3, actuators] = for x <- [n2, s2, a2], do: Enum.map(x, fn y -> %{y | pid: :ets.lookup_element(table, y.id, 2)} end) 
    neurons = Enum.map(n3, fn x -> assign_output_pids(x, table) end)
    sensors = Enum.map(s3, fn x -> assign_output_pids(x, table) end)
    Enum.each(neurons, fn x -> send x.pid, {:update_pid, x.output_pids} end)
    Enum.each(sensors, fn x -> send x.pid, {:update_pid, sensors} end)
    cortex = %{c | pid: spawn(Cortex, :run, [[neurons, sensors, actuators, c], table, [], []])}
    [neurons, sensors, actuators, [cortex]]
    input = Scape.generate_input(scape)
    IO.inspect input, label: "input from network module"
    send cortex.pid, {:start, input}
    else
      IO.puts "Error: scape must be an atom, ie :rng"
    end
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
    cx_id = cortex.id
    cx_pid = spawn(Cortex, :run, [genotype, table, [], []])
    cx_tuple = {cx_id, cx_pid}
    n_list = set_pids(neurons, genotype)
    s_list = set_pids(sensors, genotype)
    a_list = set_pids(actuators, genotype)
    full_list = List.flatten([n_list, s_list, a_list, cx_tuple])
    Enum.each(full_list, fn x -> :ets.insert(table, x) end)
  end

  @doc"""
  Creates a list of tuples - {node_id, pid}
  """
  def set_pids(list, genotype) do
    [head | tail] = list
    case head.id do
      {:actuator, id} -> Enum.map(list, fn x -> {x.id, spawn(Interactor, :run, [:actuator, genotype, [], []])} end)
      {:sensor, id}   -> Enum.map(list, fn x -> {x.id, spawn(Interactor, :run, [:sensor, genotype, [], []])} end)
      {:neuron, id}   -> Enum.map(list, fn x -> {x.id, spawn(Neuron, :run, [x, []])} end)
    end
  end
end

