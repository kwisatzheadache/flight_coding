defmodule Genotype do
  @moduledoc """
  Generates, saves, recalls, modifies genotypes
  """
  def update(genotype) do
    [neurons | rest] = genotype
    neurons_updated = Enum.map(neurons, fn x -> Weights.update(x) end)
    [neurons_updated | rest]
  end
end
