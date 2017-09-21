defmodule CFXXL.Client do
  @api_prefix "api/v1/cfssl"

  defstruct endpoint: "http://localhost:8888/#{@api_prefix}", options: []

  def new(), do: %__MODULE__{}

  def new(base_url, options \\ []) do
    endpoint = if String.ends_with?(base_url, "/") do
        "#{base_url}#{@api_prefix}"
      else
        "#{base_url}/#{@api_prefix}"
      end
    %__MODULE__{endpoint: endpoint, options: options}
  end

end
