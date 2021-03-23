#
# This file is part of CFXXL.
#
# Copyright 2017-2020 Ispirata Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule CFXXL.CertUtils do
  @moduledoc """
  A module containing utility functions to extract informations from PEM certificates
  """

  @aki_oid {2, 5, 29, 35}
  @common_name_oid {2, 5, 4, 3}
  @z_char 90

  require Record

  Record.defrecordp(
    :certificate,
    :Certificate,
    Record.extract(:Certificate, from_lib: "public_key/include/public_key.hrl")
  )

  Record.defrecordp(
    :tbs_certificate,
    :TBSCertificate,
    Record.extract(:TBSCertificate, from_lib: "public_key/include/public_key.hrl")
  )

  Record.defrecordp(
    :extension,
    :Extension,
    Record.extract(:Extension, from_lib: "public_key/include/public_key.hrl")
  )

  Record.defrecordp(
    :authority_key_identifier,
    :AuthorityKeyIdentifier,
    Record.extract(:AuthorityKeyIdentifier, from_lib: "public_key/include/public_key.hrl")
  )

  Record.defrecordp(
    :attribute_type_and_value,
    :AttributeTypeAndValue,
    Record.extract(:AttributeTypeAndValue, from_lib: "public_key/include/public_key.hrl")
  )

  Record.defrecordp(
    :validity,
    :Validity,
    Record.extract(:Validity, from_lib: "public_key/include/public_key.hrl")
  )

  @spec serial_number!(String.t()) :: String.t()
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

  @spec authority_key_identifier!(String.t()) :: String.t()
  @doc """
  Extracts the authority key identifier of a certificate.

  `cert` must be a string containing a PEM encoded certificate.

  Returns the authority key identifier as string or raises if
  it doesn't find one or there's an error.
  """
  def authority_key_identifier!(cert) do
    extensions =
      cert
      |> tbs()
      |> tbs_certificate(:extensions)
      |> Enum.map(fn x -> extension(x) end)

    case Enum.find(extensions, fn ext -> ext[:extnID] == @aki_oid end) do
      nil ->
        raise "no AuthorityKeyIdentifier in certificate"

      aki_extension ->
        :public_key.der_decode(:AuthorityKeyIdentifier, aki_extension[:extnValue])
        |> authority_key_identifier(:keyIdentifier)
        |> Base.encode16(case: :lower)
    end
  end

  @spec common_name!(String.t()) :: String.t() | nil
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
      |> Enum.map(fn [list_wrapped_attr] -> attribute_type_and_value(list_wrapped_attr) end)
      |> Enum.find(fn attr -> attr[:type] == @common_name_oid end)

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

  @spec not_after!(String.t()) :: DateTime.t()
  @doc """
  Extracts the not_after field (expiration) of a certificate.

  `cert` must be a string containing a PEM encoded certificate.

  Returns not_after as `DateTime` or raises if there's an error.
  """
  def not_after!(cert) do
    cert
    |> tbs()
    |> tbs_certificate(:validity)
    |> validity(:notAfter)
    |> cert_time_tuple_to_datetime()
  end

  @spec not_before!(String.t()) :: DateTime.t()
  @doc """
  Extracts the not_before field of a certificate.

  `cert` must be a string containing a PEM encoded certificate.

  Returns not_before as `DateTime` or raises if there's an error.
  """
  def not_before!(cert) do
    cert
    |> tbs()
    |> tbs_certificate(:validity)
    |> validity(:notBefore)
    |> cert_time_tuple_to_datetime()
  end

  @spec cert_time_tuple_to_datetime({:utcTime | :generalTime, iolist()}) ::
          DateTime.t()
  defp cert_time_tuple_to_datetime({:utcTime, [y0, y1 | _rest] = time_charlist}) do
    short_year = parse_charlist_int([y0, y1])

    prefix =
      if short_year >= 50 do
        '19'
      else
        '20'
      end

    cert_time_tuple_to_datetime({:generalTime, prefix ++ time_charlist})
  end

  defp cert_time_tuple_to_datetime(
         {_, [y0, y1, y2, y3, m0, m1, d0, d1, h0, h1, mn0, mn1, s0, s1, @z_char]}
       ) do
    year = parse_charlist_int([y0, y1, y2, y3])
    month = parse_charlist_int([m0, m1])
    day = parse_charlist_int([d0, d1])
    hour = parse_charlist_int([h0, h1])
    minute = parse_charlist_int([mn0, mn1])
    second = parse_charlist_int([s0, s1])

    {:ok, naive} = NaiveDateTime.new(year, month, day, hour, minute, second)

    DateTime.from_naive!(naive, "Etc/UTC")
  end

  @spec parse_charlist_int(iolist()) :: integer()
  defp parse_charlist_int(charlist) do
    {parsed, ""} =
      charlist
      |> to_string()
      |> Integer.parse()

    parsed
  end

  @spec tbs(binary) :: any
  defp tbs(cert) do
    cert
    |> :public_key.pem_decode()
    |> hd()
    |> :public_key.pem_entry_decode()
    |> certificate(:tbsCertificate)
  end
end
