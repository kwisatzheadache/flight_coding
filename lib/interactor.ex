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
  def run(interactor, genotype, sensor) do
    [n, s, a, c] = genotype
    scape = (Enum.at(s, 0)).scape
    input = Scape.generate_input(scape)
    receive do
      {:update_pid, sensor} -> run(interactor, genotype, sensor)
      {:start, _} -> Enum.each((Enum.at(sensor, 0)).output_pids, fn x -> send x, {:fire, input} end)
      {:message, message} -> IO.puts message
      {:input_vector, incoming_neuron, input} -> input
        |> IO.inspect(label: 'Output from actuator')
      {:terminate} -> IO.puts "exiting interactor"
                      Process.exit(self(), :normal)
      {:test, _} -> IO.puts "sensor receiving test signal"
                      run(interactor, genotype, sensor)
      {:print_self, _} -> IO.inspect sensor
                      run(interactor, genotype, sensor)
    end
  end
end

