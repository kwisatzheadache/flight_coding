defmodule Interactor do
  @moduledoc"""
  Sensors receive the input from the scape. As such, they ought to be tailored for each scape.
  We'll use a macro to call the module from the Sensor type.
  """

  defstruct id: nil, pid: nil, cx_id: nil, name: nil, scape: nil, vl: nil, fanout_ids: "no fanouts for actuator", output_pids: nil, fanin_ids: "no fanins for sensor", index: nil

  defmacro type(morph, interactor) do
    ast = quote do
            {{:., [], [{:__aliases__, [alias: false], [:Morphology]}, :set]}, [], [unquote(morph), unquote(interactor)]}
          end
  end
  @doc"""
  """
  def generate(morph, interactor) do
    {ast_eval, []} = Code.eval_quoted(type(morph, interactor))
    ast_eval
  end

  def fanin_neurons(actuator, neurons) do
    max = Enum.map(neurons, fn x -> x.index end)
    |> Enum.max
    fanins = Enum.filter(neurons, fn x -> x.index == max end)
    fanin_ids = Enum.map(fanins, fn x -> x.id end)
    %{actuator | fanin_ids: fanin_ids}
  end

  def fanout_neurons(sensor, neurons) do
    fanouts = Enum.filter(neurons, fn x -> x.index == 1 end)
    fanout_ids = Enum.map(fanouts, fn x -> x.id end)
    %{sensor | fanout_ids: fanout_ids}
  end

  @doc"""
  When Interractors are running, they are waiting for the :start / :terminate signals (:sensors)
  Actuators are waiting for the :act / :terminate signal.

  :start initiates transmission to the first layer neurons. The Sensors send the following message
  {:fire, input_vector}

  In the case of scape :rng, that message looks approx like this: {:fire, [0.49349, 0.492352]}
  """
  def run(interactor, genotype, sensor, acc) do
    [n, s, a, [c]] = genotype
    scape = c.scape
    IO.inspect scape
    input = Scape.generate_input(scape)
    # {_, input} = Scape.generate_input(scape)
    IO.inspect input, label: 'input from interactor module'
    receive do
      {:update_pid, update_sensor} -> run(interactor, genotype, update_sensor, [])
      {:start, cortex_pid} -> Enum.each((Enum.at(sensor, 0)).output_pids, fn x -> send x, {:fire, input} end)
                    send cortex_pid, {:sensor_input, {scape, input}} 
                          # I really should have updated the cx_pid in a better manner. I just sent it in the :update_pid message and assigned it to the acc variable temporarily.
      # {:input_vector, incoming_neuron, input} -> case length([input | acc]) == length(Enum.at(a, 0).fanin_ids) do
      #                                              true -> Enum.sum([input | acc])
      #                                                      |> IO.inspect(label: 'output from nn')
      #                                              false -> run(interactor, genotype, sensor, [input | acc])
      #                                            end
      {:terminate} -> IO.puts "exiting interactor"
                      Process.exit(self(), :normal)
    end
  end
end

