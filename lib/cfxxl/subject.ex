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

defmodule CFXXL.Subject do
  @moduledoc """
  Module defining a struct to be passed to override the certificate
  subject in a CSR
  """

  @doc """
  A struct representing a certificate Subject.

  It supports the current fields:
    * `CN`: the Common Name
    * `dname`: a `CFXXL.DName` struct representing the DN
  """
  defstruct [:CN, :dname]

  defimpl Poison.Encoder, for: CFXXL.Subject do
    def encode(subject, options) do
      # Encode only non-nil values and substitute dname
      # with names
      subject
      |> Map.from_struct()
      |> Map.put(:names, subject.dname)
      |> Map.delete(:dname)
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.into(%{})
      |> Poison.Encoder.encode(options)
    end
  end
end
