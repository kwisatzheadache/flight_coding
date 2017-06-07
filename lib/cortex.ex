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
  def run(genotype, table) do
    receive do
      {:start, _} -> Transmit.list(:sensors, genotype, :start)
      {:terminate, _} -> Transmit.all(genotype, :terminate)
                         IO.puts "terminating cortex"
                         Process.exit(self(), :normal)
    end
  end
end
