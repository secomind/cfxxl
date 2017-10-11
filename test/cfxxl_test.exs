defmodule CFXXLTest do
  use ExUnit.Case
  doctest CFXXL

  require Record

  alias CFXXL.CertUtils

  @fixture_dname %CFXXL.DName{O: "Example Ltd"}
  @fixture_hosts ["example.com", "www.example.com"]

  @fixture_crt """
  -----BEGIN CERTIFICATE-----
  MIIDkzCCAnugAwIBAgIJAPvrwmDUKC0EMA0GCSqGSIb3DQEBCwUAMGAxCzAJBgNV
  BAYTAklUMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
  aWRnaXRzIFB0eSBMdGQxGTAXBgNVBAMMEHRlc3QtY29tbW9uLW5hbWUwHhcNMTcx
  MDExMTU1NDA4WhcNMTgxMDExMTU1NDA4WjBgMQswCQYDVQQGEwJJVDETMBEGA1UE
  CAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRk
  MRkwFwYDVQQDDBB0ZXN0LWNvbW1vbi1uYW1lMIIBIjANBgkqhkiG9w0BAQEFAAOC
  AQ8AMIIBCgKCAQEA3GDSP6lBQFNqEzz08yG6xanZFJ54Ikmxxp8g8lXnBkd1XkFa
  oLV53tjQiEgJWZHM7J1SUODx0aDI0eY/LWjI2RZStUl2Qbta4SBfmg6ytgIOD2AB
  65Qhv7qSWQWzmHn2ewz8yknyC4bMMmFxJu7NPbcFAYWkOaVtu5YyIZjKqqXX2Yty
  U7YpqMzkENFmsRG942jFFMGePso5jCp6KUPth/5AlJjjgtLuKW5uu8B2tAO52JBW
  1WC6K9GXyJzCeWTOJzIKYe6iJvuapkbq2L+uR44xSdSkhlIGUe6x95iP3/GJNtQu
  Xn0o+xqk6AUgtS3TLJrtmMhqLsGDFNkNGcafuQIDAQABo1AwTjAdBgNVHQ4EFgQU
  wfK/4fIgZldpWOz0hRSpHNtLzfkwHwYDVR0jBBgwFoAUwfK/4fIgZldpWOz0hRSp
  HNtLzfkwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAJRBG782QTDHp
  eE5Df5I4srR92mBzhJi17VdmTFI5yjcgld1DUh90HWgVS5J4o4I+N3iB+t7GTb1w
  RPw3x6wFtubToR845DWZJr9r/b4+yOdVGlc1DUebXpDFlk9OUmnLkaC4gDFKMGER
  Q98W205ZmLRH7566ft7P6kK04Pa3w1tjc2nZSE7E2K1CxrJRqurt5XdGFP4Fhc8g
  tyLv2oQvgjxsgmD0q94Xc43MtN2JVbBGGK3olXeRVPK2A8pgomxnaSzgnsribmBI
  FUAoPs9udC2ex6WQOUUZhAKQ7PpK1UbASwhnXdgbC0pnOiZUwzwYb9UG4nlgHmY+
  Z/HHzzaRYA==
  -----END CERTIFICATE-----
  """

  import CFXXL

  setup do
    base_url = Application.get_env(:cfxxl, :test_endpoint)[:base_url] || "http://localhost:8888"
    options = Application.get_env(:cfxxl, :test_endpoint)[:options] || []
    %{client: CFXXL.Client.new(base_url, options)}
  end

  test "new key generation", %{client: client} do
    assert {:ok, res} = newkey(client, @fixture_hosts, @fixture_dname)
    assert Map.has_key?(res, "private_key")
    assert Map.has_key?(res, "certificate_request")
    assert Map.has_key?(res, "sums")
  end

  test "new key generation and signing", %{client: client} do
    assert {:ok, genres} = newkey(client, @fixture_hosts, @fixture_dname)
    assert Map.has_key?(genres, "private_key")
    assert Map.has_key?(genres, "sums")
    assert {:ok, csr} = Map.fetch(genres, "certificate_request")

    assert {:ok, signres} = sign(client, csr)
    assert Map.has_key?(signres, "certificate")
  end

  test "invalid key signing", %{client: client} do
    assert {:error, _} = sign(client, "dudududucantsignthis")
  end

  test "crl generation", %{client: client} do
    assert {:ok, crl} = crl(client)

    assert Record.is_record(:public_key.der_decode(:CertificateList, :base64.decode(crl)))
  end

  test "new certificate generation with custom key", %{client: client} do
    key = %CFXXL.KeyConfig{algo: :rsa, size: 2048}
    assert {:ok, genres} = newcert(client, @fixture_hosts, @fixture_dname, key: key)
    assert Map.has_key?(genres, "private_key")
    assert Map.has_key?(genres, "certificate")
    assert Map.has_key?(genres, "certificate_request")
    assert Map.has_key?(genres, "sums")
  end

  test "new certificate generation with invalid key", %{client: client} do
    key = %CFXXL.KeyConfig{algo: :my_secret_crypto, size: 2048}
    assert {:error, _} = newcert(client, @fixture_hosts, @fixture_dname, key: key)
  end

  test "new certificate generation and revoke", %{client: client} do
    assert {:ok, genres} = newcert(client, @fixture_hosts, @fixture_dname)
    assert Map.has_key?(genres, "private_key")
    assert Map.has_key?(genres, "certificate_request")
    assert Map.has_key?(genres, "sums")
    assert {:ok, cert} = Map.fetch(genres, "certificate")

    serial = CertUtils.serial_number!(cert)
    aki = CertUtils.authority_key_identifier!(cert)

    assert :ok = revoke(client, serial, aki, "superseded")
  end

  test "non-existing revoke", %{client: client} do
    assert {:error, _} = revoke(client, "1234567", "1234567", "superseded")
  end

  test "ca initialization with custom config", %{client: client} do
    caconf = %CFXXL.CAConfig{expiry: "8760h"}
    assert {:ok, res} = init_ca(client, @fixture_hosts, @fixture_dname, ca: caconf)
    assert Map.has_key?(res, "private_key")
    assert Map.has_key?(res, "certificate")
  end

  test "certinfo call with domain", %{client: client} do
    assert {:ok, res} = certinfo(client, domain: "google.it")
    assert Map.has_key?(res, "authority_key_id")
    assert Map.has_key?(res, "issuer")
    assert Map.has_key?(res, "not_after")
    assert Map.has_key?(res, "not_before")
    assert Map.has_key?(res, "pem")
    assert Map.has_key?(res, "sans")
    assert Map.has_key?(res, "serial_number")
    assert Map.has_key?(res, "sigalg")
    assert Map.has_key?(res, "subject")
    assert Map.has_key?(res, "subject_key_id")
  end

  test "certinfo call with cert", %{client: client} do
    assert {:ok, res} = certinfo(client, certificate: @fixture_crt)
    assert Map.has_key?(res, "issuer")
    assert Map.has_key?(res, "not_after")
    assert Map.has_key?(res, "not_before")
    assert Map.has_key?(res, "pem")
    assert Map.has_key?(res, "subject_key_id")

    assert CertUtils.serial_number!(@fixture_crt) == Map.get(res, "serial_number")

    %{"common_name" => cn} = Map.get(res, "subject")

    assert CertUtils.common_name!(@fixture_crt) == cn

    aki =
      Map.get(res, "authority_key_id")
      |> String.downcase()
      |> String.replace(":", "")

    assert aki == CertUtils.authority_key_identifier!(@fixture_crt)
  end
end
