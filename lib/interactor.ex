defmodule Interactor do
  @moduledoc"""
  Sensors receive the input from the scape. As such, they ought to be tailored for each scape.
  We'll use a macro to call the module from the Sensor type.
  """

  defstruct id: nil, pid: nil, cx_id: nil, name: nil, scape: nil, vl: nil, fanout_ids: nil

  defmacro type(name, interactor) do
    quote do
      {{:., [], [{:__aliases__, [alias: false], [:Morphology]}, unquote(name)]}, [], [interactor]}
    end
  end
  @doc"""
  """
  def generate(morph, interactor) do
    type(morph, interactor)
  end
end

