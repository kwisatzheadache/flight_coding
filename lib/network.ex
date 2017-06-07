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
    if is_atom(scape) do
    [cortex] = Cortex.generate(scape, type)
    table = :ets.new(:table, [:set, :private])
    n= Neuron.generate(size)
    s= Interactor.generate(scape, :sensor)
      |> Enum.map(fn x -> Interactor.fanout_neurons(x, n) end)
    a= Interactor.generate(scape, :actuator)
      |> Enum.map(fn x -> Interactor.fanin_neurons(x, n) end)
    n_loaded = Neuron.assign_inputs_and_outputs(n, s, a)
    neurons = Enum.map(n_loaded, fn x -> %{x | cx_id: cortex.id} end)
    sensors = Enum.map(s, fn x -> %{x | cx_id: cortex.id} end)
    actuators = Enum.map(a, fn x -> %{x | cx_id: cortex.id} end)
    genotype = [neurons, sensors, actuators, [cortex]]  
    gen_pids(genotype, table)
    geno_pids = Enum.map(List.flatten(genotype), fn x -> %{x | pid: :ets.lookup_element(table, x.id, 2)} end)
#   Agent.start_link fn -> geno_pids end
    geno_pids
    else
      IO.puts "Error: scape must be an atom, ie :rng"
    end
  end

  @doc"""
  Receives phenotype and "activates" all nodes.
  """
  def gen_pids(genotype, table) do
    [neurons, sensors, actuators, [cortex]] = genotype
    cx_id = cortex.id
    cx_pid = spawn(Cortex, :run, [genotype, table])
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
      {:actuator, id} -> Enum.map(list, fn x -> {x.id, spawn(Interactor, :run, [:actuator, genotype])} end)
      {:sensor, id}   -> Enum.map(list, fn x -> {x.id, spawn(Interactor, :run, [:sensor, genotype])} end)
      {:neuron, id}   -> Enum.map(list, fn x -> {x.id, spawn(Neuron, :run, [x, genotype])} end)
    end
  end
end

