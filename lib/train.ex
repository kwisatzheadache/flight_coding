defmodule Train do
  @moduledoc"""
  """

  @doc"""
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
    end
  end
end
