defmodule Morphology do
  @moduledoc """
  Creates the sensor and actuator. Called by the interactor macro. 
  """

  @doc"""
  Random Number Generator
  """
  def rng(interactor) do
    case interactor do
      :sensor ->
        [%Sensor{id: {:sensor, Generate.id()}, name: :rng_getinput, scape: {:private, :rng_sim}, vl: 2}]
      :actuator ->
         [%Actuator{id: {:actuator, Generate.id()}, name: :rng_sendoutput, scape: {:private, :rng_sim}, vl: 1}]
    end
  end

  @doc"""
  Scape for working with rubix cube
  """
  def cube(interactor) do
    case interactor do
      :sensor ->
        [%Sensor{id: {:sensor, Generate.id()}, name: :cube_getinput, scape: {:private, :cube_sim}, vl: 2}]
      :actuator ->
         [%Actuator{id: {:actuator, Generate.id()}, name: :cube_sendoutput, scape: {:private, :cube_sim}, vl: 1}]
    end
  end

  @doc"""
  XOR logic gate
  """
  def xor(interactor) do
    case interactor do
      :sensor ->
        [%Sensor{id: {:sensor, Generate.id()}, name: :xor_getinput, scape: {:private, :xor_sim}, vl: 2}]
      :actuator ->
         [%Actuator{id: {:actuator, Generate.id()}, name: :xor_sendoutput, scape: {:private, :xor_sim}, vl: 1}]
    end
  end
end

