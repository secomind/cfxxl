defmodule CFXXL do
  @moduledoc """
  Documentation for CFXXL.
  """

  alias CFXXL.Client

  def sign(client, csr, _options \\ []) do
    body = %{certificate_request: csr}

    post(client, "sign", body)
  end

  def post(%Client{endpoint: endpoint}, route, body) do
    HTTPoison.post("#{endpoint}/#{route}", Poison.encode!(body))
    |> process_response()
  end

  defp process_response({:error, _} = response), do: response
  defp process_response({:ok, %HTTPoison.Response{body: body}}), do: extract_result(body)

  defp extract_result(body) do
    case Poison.decode(body) do
      {:error, _} -> {:error, :invalid_response}
      {:ok, %{"success" => false} = decoded} -> {:error, extract_errors(decoded)}
      {:ok, %{"success" => true, "result" => result}} -> {:ok, result}
    end
  end

  defp extract_errors(%{"errors" => errors}), do: {errors}
end
