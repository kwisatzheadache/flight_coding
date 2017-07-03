defmodule Train do
  @moduledoc"""
  Train a network to respond to the given scape. 
  """

  @doc"""
  Default training on XOR scape. Generates genotype, then trains it x number of iterations.
  """
  def genotype(iterations) do
    geno = Genotype.create
    network(geno, iterations)
  end

  def network(geno_initial, iterations) do
    [{:error, error_initial}, {:training_size, training_size}] = Network.link_and_process(geno_initial)
    if iterations !== 0  do
      geno_perturbed = Genotype.update(geno_initial)
      [{:error, error_perturbed}, {:training_size, _}] = Network.link_and_process(geno_perturbed)
      IO.inspect [error_initial, error_perturbed], label: 'both errors'
      best = case error_initial > error_perturbed do
               true -> geno_perturbed
               false -> geno_initial
             end
      network(best, iterations - 1)
    else
      IO.inspect error_initial, label: "Final error"
      geno_initial
    end
  end

  def network_average(geno_initial, iterations) do
    initial_fitness = average_fitness(geno_initial)
    if iterations !== 0 do
      perturbed_geno = Genotype.update(geno_initial)
      perturbed_fitness = average_fitness(perturbed_geno)
      IO.inspect [initial_fitness, perturbed_fitness], label: 'both fitnesses'
      best = case perturbed_fitness < initial_fitness do
               true -> perturbed_geno
               false -> geno_initial
             end
      network_average(best, iterations - 1)
    else
      IO.inspect initial_fitness, label: 'Final fitness'
    end
  end
  @doc"""
  Because the network/2 module often yields a fitness that is not better than the previous iteration, average_fitness/3
  seeks to produce the most reliably fit genotype. 
  """
  def average_fitness(genotype) do
    iterated_fitness = iterate(genotype, 5, [])
    Enum.sum(iterated_fitness) / length(iterated_fitness)
  end

  def iterate(genotype, count, acc) do
    case count == 0 do
      false -> [{:error, error}, {:training_size, training_size}] = Network.link_and_process(genotype)
        iterate(genotype, count - 1, [error | acc])
      true -> acc
    end
  end
end
