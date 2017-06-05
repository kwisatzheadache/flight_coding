defmodule Interactor do
  @moduledoc"""
  Sensors receive the input from the scape. As such, they ought to be tailored for each scape.
  We'll use a macro to call the module from the Sensor type.
  """

  defstruct id: nil, pid: nil, cx_id: nil, name: nil, scape: nil, vl: nil, fanout_ids: nil, index: nil

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
end

