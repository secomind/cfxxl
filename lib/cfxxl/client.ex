defmodule CFXXL.Client do
  @api_prefix "api/v1/cfssl"
  @accepted_opts [:timeout, :recv_timeout, :proxy, :proxy_auth, :ssl]

  defstruct endpoint: "http://localhost:8888/#{@api_prefix}", options: []

  def new(), do: %__MODULE__{}

  def new(base_url, options \\ []) do
    endpoint = if String.ends_with?(base_url, "/") do
        "#{base_url}#{@api_prefix}"
      else
        "#{base_url}/#{@api_prefix}"
      end

    filtered_opts =
      options
      |> Enum.filter(fn {k, _} -> k in @accepted_opts end)

    %__MODULE__{endpoint: endpoint, options: filtered_opts}
  end

end
