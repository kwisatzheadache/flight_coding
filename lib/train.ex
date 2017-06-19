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
    [input, correct_output, output] = Network.link_and_process(geno_initial)
      # [generated_input: input, correct_output: correct_output, output: output] = Network.link_and_process(geno_initial)
    fitness_initial = (correct_output - output)
    if iterations !== 0  do
      geno_perturbed = Genotype.update(geno_initial)
      [input_perturbed, correct_output_perturbed, output_perturbed] = Network.link_and_process(geno_perturbed)
      fitness_perturbed = (correct_output_perturbed - output_perturbed)
      delta = fitness_initial - fitness_perturbed
      IO.inspect [{:count, iterations}, {:input, input}, {:output, output}, {:fitness, fitness_initial}]
      case delta >= 0 do
        true -> network(geno_perturbed, iterations - 1)
        false -> network(geno_initial, iterations - 1)
      end
    else
      IO.inspect fitness_initial, label: "Final fitness"
    end
  end
end
