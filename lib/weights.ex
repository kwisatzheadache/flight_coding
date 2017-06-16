defmodule Weights do
  @moduledoc"""
  Used to generate, fetch, update, and perturb weights in Neurons
  """

  @doc"""
  Generates weights based on vl
  """
  def generate(vl, acc) do
    if vl == 0 do
      acc
    else
      weight = :random.uniform()
      generate(vl - 1, [weight | acc])
    end
  end

  def assign(neuron) do
    vl = length(neuron.input_neurons) + 1
    %{neuron | weights: generate(vl, [])}
  end

  def update(neuron) do
    %{neuron | weights: Enum.map(neuron.weights, fn x -> perturb(x) end)}
  end

  def perturb(weight) do
    weight + (:random.uniform() / 30)
  end
end
