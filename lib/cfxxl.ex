# Copyright (c) 2017 Ispirata Srl

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

defmodule CFXXL do
  @moduledoc """
  A module containing functions to interact with the CFSSL API.

  For more information on the contents of the results of each call,
  see the relative [cfssl API documentation](https://github.com/cloudflare/cfssl/tree/master/doc/api)
  """

  alias CFXXL.Client

  @authsign_opts [:timestamp, :remote_address, :bundle]
  @bundle_cert_opts [:domain, :private_key, :flavor, :ip]
  @bundle_domain_opts [:ip]
  @info_opts [:profile]
  @init_ca_opts [:CN, :key, :ca]
  @newcert_opts [:label, :profile, :bundle]
  @newkey_opts [:CN, :key]
  @scan_opts [:ip, :timeout, :family, :scanner]
  @sign_opts [:hosts, :subject, :serial_sequence, :label, :profile, :bundle]

  @doc """
  Request to sign a CSR with authentication.

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `token`: the authentication token
    * `csr`: the CSR as a PEM encoded string
    * `opts`: a keyword list of optional parameters

  ## Options
    * `timestamp`: a Unix timestamp
    * `remote_address`: an address used in making the request
    * `bundle`: a boolean specifying whether to include an "optimal"
    certificate bundle along with the certificate
    * all the opts supported in `sign/3`

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def authsign(client, token, csr, opts \\ []) do
    body =
      opts
      |> filter_opts(@authsign_opts)
      |> Enum.into(%{token: token, request: sign_request(csr, opts)})

    post(client, "authsign", body)
  end

  @doc """
  Request a certificate bundle

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `opts`: a keyword list of parameters

  ## Options
  `opts` must contain one of these two keys
    * `certificate`: the PEM-encoded certificate to be bundled
    * `domain`: a domain name indicating a remote host to retrieve a
    certificate for

  If `certificate` is given, the following options are available:
    * `private_key`: the PEM-encoded private key to be included with
    the bundle. This is valid only if the server is not running in
    "keyless" mode
    * `flavor`: one of `:ubiquitous`, `:force`, or `:optimal`, with a
    default value of `:ubiquitous`. A ubiquitous bundle is one that
    has a higher probability of being verified everywhere, even by
    clients using outdated or unusual trust stores. Force will
    cause the endpoint to use the bundle provided in the
    `certificate` parameter, and will only verify that the bundle
    is a valid (verifiable) chain
    * `domain`: the domain name to verify as the hostname of the
    certificate
    * `ip`: the IP address to verify against the certificate IP SANs

  Otherwise, using `domain`, the following options are available:
    * `ip`: the IP address of the remote host; this will fetch the
    certificate from the IP, and verify that it is valid for the
    domain name

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def bundle(client, opts) do
    cond do
      Keyword.has_key?(opts, :certificate) ->
        body =
          opts
          |> filter_opts(@bundle_cert_opts)
          |> Enum.into(%{certificate: opts[:certificate]})

        post(client, "bundle", body)

      Keyword.has_key?(opts, :domain) ->
        body =
          opts
          |> filter_opts(@bundle_domain_opts)
          |> Enum.into(%{domain: opts[:domain]})

        post(client, "bundle", body)

      true ->
        {:error, :no_certificate_or_domain}
    end
  end

  @doc """
  Request information about a certificate

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `opts`: a keyword list of parameters

  ## Options
  `opts` must contain one of these two keys
    * `certificate`: the PEM-encoded certificate to be parsed
    * `domain`: a domain name indicating a remote host to retrieve a
    certificate for

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def certinfo(client, opts) do
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

  @doc """
  Generate a CRL from the database

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `expiry`: an optional string to specify the time after which
    the CRL should expire from the moment of the request

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def crl(client, expiry \\ nil) do
    if expiry do
      get(client, "crl", %{expiry: expiry})
    else
      get(client, "crl")
    end
  end

  @doc """
  Perform a generic GET to the CFSSL API.

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `route`: the part to be appended to the url to make the call, without
    a leading slash
    * `params`: a map with the parameters to be appended to the URL of the GET

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def get(%Client{endpoint: endpoint, options: options}, route, params \\ %{}) do
    HTTPoison.get("#{endpoint}/#{route}", [], [{:params, params} | options])
    |> process_response()
  end

  @doc """
  Get signer information

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `label`: a string specifying the signer
    * `opts`: a keyword list of optional parameters

  ## Options
    * `profile`: a string specifying the signing profile for the signer.
    Signing profile specifies what key usages should be used and
    how long the expiry should be set

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def info(client, label, opts \\ []) do
    body =
      opts
      |> filter_opts(@info_opts)
      |> Enum.into(%{label: label})

    post(client, "info", body)
  end

  @doc """
  Request a new CA key/certificate pair.

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `hosts`: a list of strings representing SAN (subject alternative names)
    for the CA certificate
    * `dname`: a `CFXXL.DName` struct representing the DN for the CA certificate
    * `opts`: a keyword list of optional parameters

  ## Options
    * `CN`: a string representing the CN for the certificate
    * `key`: a `CFXXL.KeyConfig` to configure the key, default to ECDSA-256
    * `ca`: a `CFXXL.CAConfig` to configure the CA

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def init_ca(client, hosts, dname, opts \\ []) do
    body =
      opts
      |> filter_opts(@init_ca_opts)
      |> Enum.into(%{hosts: hosts, names: dname})

    post(client, "init_ca", body)
  end

  @doc """
  Request a new key/signed certificate pair.

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `hosts`: a list of strings representing SAN (subject alternative names)
    for the certificate
    * `dname`: a `CFXXL.DName` struct representing the DN for the certificate
    * `opts`: a keyword list of optional parameters

  ## Options
    * `label`: a string specifying which signer to be appointed to sign
    the CSR, useful when interacting with a remote multi-root CA signer
    * `profile`: a string specifying the signing profile for the signer,
    useful when interacting with a remote multi-root CA signer
    * `bundle`: a boolean specifying whether to include an "optimal"
    certificate bundle along with the certificate
    * all the opts supported in `newkey/4`

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def newcert(client, hosts, dname, opts \\ []) do
    body =
      opts
      |> filter_opts(@newcert_opts)
      |> Enum.into(%{request: newkey_request(hosts, dname, opts)})

    post(client, "newcert", body)
  end

  @doc """
  Request a new key/CSR pair.

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `hosts`: a list of strings representing SAN (subject alternative names)
    for the certificate
    * `dname`: a `CFXXL.DName` struct representing the DN for the certificate
    * `opts`: a keyword list of optional parameters

  ## Options
    * `CN`: a string representing the CN for the certificate
    * `key`: a `CFXXL.KeyConfig` to configure the key, default to ECDSA-256

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def newkey(client, hosts, dname, opts \\ []) do
    body = newkey_request(hosts, dname, opts)

    post(client, "newkey", body)
  end

  @doc """
  Perform a generic POST to the CFSSL API.

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `route`: the part to be appended to the url to make the call, without
    a leading slash
    * `body`: a map that will be serialized to JSON and used as the body of
    the request

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def post(%Client{endpoint: endpoint, options: options}, route, body) do
    HTTPoison.post("#{endpoint}/#{route}", Poison.encode!(body), [], options)
    |> process_response()
  end

  @doc """
  Request to revoke a certificate.

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `serial`: the serial of the certificate to be revoked
    * `aki`: the AuthorityKeyIdentifier of the certificate to be revoked
    * `reason`: a string representing the reason of the revocation,
    see ReasonFlags in Section 4.2.1.13 of RFC5280

  ## Return
    * `:ok` on success
    * `{:error, reason}` if it fails
  """
  def revoke(client, serial, aki, reason) do
    body = %{serial: serial,
             authority_key_id: normalize_aki(aki),
             reason: reason}

    case post(client, "revoke", body) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc """
  Scan an host

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `host`: the hostname (optionally including port) to scan
    * `opts`: a keyword list of optional parameters

  ## Options
    * `ip`: IP Address to override DNS lookup of host
    * `timeout`: The amount of time allotted for the scan to complete (default: 1 minute)
    * `family`:  regular expression specifying scan famil(ies) to run
    * `scanner`: regular expression specifying scanner(s) to run

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def scan(client, host, opts \\ []) do
    params =
      opts
      |> filter_opts(@scan_opts)
      |> Enum.into(%{host: host})

    get(client, "scan", params)
  end

  @doc """
  Get information on scan families

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def scaninfo(client) do
    get(client, "scaninfo")
  end

  @doc """
  Request to sign a CSR.

  ## Arguments
    * `client`: the `CFXXL.Client` to use for the call
    * `csr`: the CSR as a PEM encoded string
    * `opts`: a keyword list of optional parameters

  ## Options
    * `hosts`: a list of strings representing SAN (subject alternative names)
    which overrides the ones in the CSR
    * `subject`: a `CFXXL.Subject` that overrides the ones in the CSR
    * `serial_sequence`: a string specifying the prefix which the generated
    certificate serial should have
    * `label`: a string specifying which signer to be appointed to sign
    the CSR, useful when interacting with a remote multi-root CA signer
    * `profile`: a string specifying the signing profile for the signer,
    useful when interacting with a remote multi-root CA signer
    * `bundle`: a boolean specifying whether to include an "optimal"
    certificate bundle along with the certificate

  ## Return
    * `{:ok, result}` with the contents of the `result` key of the API
    * `{:error, reason}` if it fails
  """
  def sign(client, csr, opts \\ []) do
    body = sign_request(csr, opts)

    post(client, "sign", body)
  end

  defp process_response({:error, _} = response), do: response
  defp process_response({:ok, %HTTPoison.Response{body: body}}), do: extract_result(body)

  defp extract_result(body) do
    case Poison.decode(body) do
      {:error, _} -> {:error, :invalid_response}
      {:ok, %{"success" => false} = decoded} -> {:error, extract_error_message(decoded)}
      {:ok, %{"success" => true, "result" => result}} -> {:ok, result}
    end
  end

  defp extract_error_message(%{"errors" => errors}) do
    case errors do
      [%{"message" => msg} | _] -> msg
      [] -> :generic_error
    end
  end

  defp normalize_aki(aki) do
    aki
    |> String.downcase()
    |> String.replace(":", "")
  end

  defp filter_opts(opts, accepted_opts) do
    opts
    |> Enum.filter(fn {k, _} -> k in accepted_opts end)
  end

  defp newkey_request(hosts, dname, opts) do
    opts
    |> filter_opts(@newkey_opts)
    |> Enum.into(%{hosts: hosts, names: dname})
  end

  defp sign_request(csr, opts) do
    opts
    |> filter_opts(@sign_opts)
    |> Enum.into(%{certificate_request: csr})
  end
end
