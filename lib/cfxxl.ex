defmodule CFXXL do
  @moduledoc """
  Documentation for CFXXL.
  """

  alias CFXXL.Client

  @info_opts [:profile]
  @sign_opts [:hosts, :subject, :serial_sequence, :label, :profile, :bundle]

  def crl(client, expiry \\ nil) do
    target = if expiry do
        "crl?#{expiry}"
      else
        "crl"
      end

    get(client, target)
  end

  def get(%Client{endpoint: endpoint}, route) do
    HTTPoison.get("#{endpoint}/#{route}")
    |> process_response()
  end

  def info(client, label, opts \\ []) do
    body = opts
      |> Enum.filter(fn {k, _} -> k in @info_opts end)
      |> Enum.into(%{label: label})

    post(client, "info", body)
  end

  def post(%Client{endpoint: endpoint}, route, body) do
    HTTPoison.post("#{endpoint}/#{route}", Poison.encode!(body))
    |> process_response()
  end

  def revoke(client, serial, aki, reason) do
    body = %{serial: serial,
             authority_key_id: normalize_aki(aki),
             reason: reason}

    post(client, "revoke", body)
  end

  def sign(client, csr, opts \\ []) do
    body = opts
      |> Enum.filter(fn {k, _} -> k in @sign_opts end)
      |> Enum.into(%{certificate_request: csr})

    post(client, "sign", body)
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

  defp normalize_aki(aki) do
    aki
    |> String.downcase()
    |> String.replace(":", "")
  end
end
