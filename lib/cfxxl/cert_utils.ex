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

defmodule CFXXL.CertUtils do
  @moduledoc """
  A module containing utility functions to extract informations from PEM certificates
  """

  @aki_oid {2, 5, 29, 35}
  @common_name_oid {2, 5, 4, 3}

  require Record

  Record.defrecordp :certificate, :Certificate, Record.extract(:Certificate, from_lib: "public_key/include/public_key.hrl")
  Record.defrecordp :tbs_certificate, :TBSCertificate, Record.extract(:TBSCertificate, from_lib: "public_key/include/public_key.hrl")
  Record.defrecordp :extension, :Extension, Record.extract(:Extension, from_lib: "public_key/include/public_key.hrl")
  Record.defrecordp :authority_key_identifier, :AuthorityKeyIdentifier, Record.extract(:AuthorityKeyIdentifier, from_lib: "public_key/include/public_key.hrl")
  Record.defrecordp :attribute_type_and_value, :AttributeTypeAndValue, Record.extract(:AttributeTypeAndValue, from_lib: "public_key/include/public_key.hrl")

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

  @doc """
  Extracts the authority key identifier of a certificate.

  `cert` must be a string containing a PEM encoded certificate.

  Returns the authority key identifier as string or raises if
  it doesn't find one or there's an error.
  """
  def authority_key_identifier!(cert) do
    extensions = cert
      |> tbs()
      |> tbs_certificate(:extensions)
      |> Enum.map(fn(x) -> extension(x) end)

    case Enum.find(extensions, fn(ext) -> ext[:extnID] == @aki_oid end) do
      nil ->
        raise "no AuthorityKeyIdentifier in certificate"

      aki_extension ->
        :public_key.der_decode(:AuthorityKeyIdentifier, aki_extension[:extnValue])
        |> authority_key_identifier(:keyIdentifier)
        |> Base.encode16(case: :lower)
    end
  end

  @doc """
  Extracts the Common Name of a certificate.

  `cert` must be a string containing a PEM encoded certificate.

  Returns the Common Name as string or nil if it doesn't find one, raises if there's an error.
  """
  def common_name!(cert) do
    {:rdnSequence, subject_attributes} =
      cert
      |> tbs()
      |> tbs_certificate(:subject)

    common_name =
      subject_attributes
      |> Enum.map(fn([list_wrapped_attr]) -> attribute_type_and_value(list_wrapped_attr) end)
      |> Enum.find(fn(attr) -> attr[:type] == @common_name_oid end)

    if common_name do
      case :public_key.der_decode(:X520CommonName, common_name[:value]) do
        {:printableString, cn} ->
          to_string(cn)

        {:utf8String, cn} ->
          to_string(cn)
      end
    else
      nil
    end
  end

  defp tbs(cert) do
    cert
    |> :public_key.pem_decode()
    |> hd()
    |> :public_key.pem_entry_decode()
    |> certificate(:tbsCertificate)
  end
end
