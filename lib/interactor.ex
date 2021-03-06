defmodule Interactor do
  @moduledoc"""
  Sensors receive the input from the scape. As such, they ought to be tailored for each scape.
  We'll use a macro to call the module from the Sensor type.
  """

  defstruct id: nil, pid: nil, cortex_id: nil, cortex_pid: nil, name: nil, scape: nil, vl: nil, fanout_ids: "no fanouts for actuator", output_pids: nil, fanin_ids: "no fanins for sensor", index: nil

  defmacro type(morph, interactor) do
    ast = quote do
            {{:., [], [{:__aliases__, [alias: false], [:Morphology]}, :set]}, [], [unquote(morph), unquote(interactor)]}
          end
  end

  @doc"""
  Called in the genotype stage
  """
  def generate(morph, interactor) do
    {ast_eval, []} = Code.eval_quoted(type(morph, interactor))
    ast_eval
  end

  @doc"""
  Neuron ids that send info to current neuron
  """
  def fanin_neurons(actuator, neurons) do
    max = Enum.map(neurons, fn x -> x.index end)
    |> Enum.max
    fanins = Enum.filter(neurons, fn x -> x.index == max end)
    fanin_ids = Enum.map(fanins, fn x -> x.id end)
    %{actuator | fanin_ids: fanin_ids}
  end

  @doc"""
  Neuron or sensor sends output to these neurons
  """
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
  def run(interactor, genotype, acc) do
    [n, s, a, [c]] = genotype
    scape = c.scape
    receive do
      {:update_pids_sensor, output_pids, cortex_pid} -> run(interactor, [n, Enum.map(s, fn x -> %{x | output_pids: output_pids, cortex_pid: cortex_pid} end), a, [c]], acc)
      {:update_pids_actuator, cortex_pid} -> run(interactor, [n, s, Enum.map(a, fn x -> %{x | output_pids: cortex_pid, cortex_pid: cortex_pid} end), [%{c | pid: cortex_pid}]], acc)
      {:start, cortex_pid, training_counter} -> input = Scape.generate_input(scape, training_counter)
        {_, actual_input} = input
        Enum.each((Enum.at(s, 0)).output_pids, fn x -> send x, {:fire, actual_input} end)
        send cortex_pid, {:sensor_input, {scape, actual_input}} 
        run(interactor, genotype, acc)
      {:input_vector, incoming_neuron, input} -> case length([input | acc]) == length(Enum.at(a, 0).fanin_ids) do
                                                   true -> Enum.each(a, fn x -> send x.output_pids, {:actuator_output, {x.id, x.name}, Scape.process_output((Enum.sum([input | acc])) / (length([input | acc])))} end)
                                                      run(interactor, genotype, [])
                                                      # Not sure if I should run() with the input or an empty acc 
                                                   false -> run(interactor, genotype, [input | acc])
                                                 end
      {:terminate} -> IO.puts "exiting interactor"
        Process.exit(self(), :normal)
    end
  end
end

