defmodule CFXXL.Client do
  defstruct endpoint: "http://localhost:8888"

  def new(), do: %__MODULE__{}
  def new(endpoint), do: %__MODULE__{endpoint: endpoint}

end
