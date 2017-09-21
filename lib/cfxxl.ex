defmodule CFXXL do
  @moduledoc """
  Documentation for CFXXL.
  """

  alias CFXXL.Client

  @info_opts [:profile]
  @init_ca_opts [:CN, :key, :ca]
  @newkey_opts [:CN, :key]
  @sign_opts [:hosts, :subject, :serial_sequence, :label, :profile, :bundle]

  def certinfo(client, opts \\ []) do
    cond do
      Keyword.has_key?(opts, :certificate) ->
        cert = opts[:certificate]
        post(client, "certinfo", %{certificate: cert})

      Keyword.has_key?(opts, :domain) ->
        domain = opts[:domain]
        post(client, "certinfo", %{domain: domain})

      true ->
        {:error, :no_certificate_or_domain}
    end
  end

  def crl(client, expiry \\ nil) do
    if expiry do
      get(client, "crl", %{expiry: expiry})
    else
      get(client, "crl")
    end
  end

  def get(%Client{endpoint: endpoint}, route, params \\ %{}) do
    HTTPoison.get("#{endpoint}/#{route}", [], params: params)
    |> process_response()
  end

  def info(client, label, opts \\ []) do
    body = opts
      |> Enum.filter(fn {k, _} -> k in @info_opts end)
      |> Enum.into(%{label: label})

    post(client, "info", body)
  end

  def init_ca(client, hosts, names, opts \\ []) do
    body = opts
      |> Enum.filter(fn {k, _} -> k in @init_ca_opts end)
      |> Enum.into(%{hosts: hosts, names: names})

    post(client, "init_ca", body)
  end

  def newkey(client, hosts, names, opts \\ []) do
    body = opts
      |> Enum.filter(fn {k, _} -> k in @newkey_opts end)
      |> Enum.into(%{hosts: hosts, names: names})

    post(client, "newkey", body)
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

  def scaninfo(client) do
    get(client, "scaninfo")
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
