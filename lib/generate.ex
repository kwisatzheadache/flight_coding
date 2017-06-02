defmodule Generate do
  @moduledoc"""
  Generate ids and anything else that I might need to generate later.
  """

  @doc"""
  Generate id in the form of a random number, between 0 and 1
  """
  def id() do
    :random.uniform()
  end
end

