defmodule CFXXLTest do
  use ExUnit.Case
  doctest CFXXL

  require Record

  @fixture_dname %CFXXL.DName{O: "Example Ltd"}
  @fixture_hosts ["example.com", "www.example.com"]

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

    serial = CFXXL.CertUtils.serial_number!(cert)
    aki = CFXXL.CertUtils.authority_key_identifier!(cert)

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
end
