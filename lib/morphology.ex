defmodule Morphology do
  @moduledoc """
  Creates the sensor and actuator. Called by the interactor macro. 
  """

  @doc"""
  Random Number Generator
  """

  @doc"""
  Called during creation of interactors. Format is
  Morphology.set(:rng, :sensor)
  """
  def set(scape, interactor) do
    get_input = String.to_atom(Enum.join([Atom.to_string(scape), "_get_input"]))
    send_output = String.to_atom(Enum.join([Atom.to_string(scape), "_get_output"]))
    case interactor do
      :sensor ->
        [%Interactor{id: {:sensor, Generate.id()}, name: get_input, scape: {:private, scape}, vl: 2}]
      :actuator ->
        [%Interactor{id: {:actuator, Generate.id()}, name: send_output, scape: {:private, scape}, vl: 1}]
    end
  end

end

