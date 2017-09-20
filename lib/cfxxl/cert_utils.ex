defmodule CFXXL.CertUtils do
  @moduledoc """
  A module containing utility functions to extract informations from PEM certificates
  """

  require Record

  Record.defrecordp :certificate, :Certificate, Record.extract(:Certificate, from_lib: "public_key/include/public_key.hrl")
  Record.defrecordp :tbs_certificate, :TBSCertificate, Record.extract(:TBSCertificate, from_lib: "public_key/include/public_key.hrl")

  @doc """
  Extracts the serial number of a certificate.

  `cert` must be a string containing a PEM encoded certificate.

  Returns the serial number as string or raises if there's an error.
  """
  def serial_number!(cert) do
    cert
    |> tbs()
    |> tbs_certificate(:serialNumber)
    |> to_string()
  end

  defp tbs(cert) do
    cert
    |> :public_key.pem_decode()
    |> hd()
    |> :public_key.pem_entry_decode()
    |> certificate(:tbsCertificate)
  end
end
