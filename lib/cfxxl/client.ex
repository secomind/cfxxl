defmodule CFXXL.Client do
  defstruct endpoint: "http://localhost:8888/"

  def new(), do: %__MODULE__{}

  def new(endpoint) do
    slashed_endpoint = if String.ends_with?(endpoint, "/") do
        endpoint
      else
        endpoint <> "/"
      end
    %__MODULE__{endpoint: slashed_endpoint}
  end

end
