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

defmodule CFXXL.CAConfig do
  @moduledoc """
  Module defining a struct to configure the CA when initializing it
  """

  @doc """
  A struct containing the configuration of the CA

  The fields are:
    * `pathlength`: the maximum pathlength of the CA
    * `pathlenzero`: a bool representing wether or not the CA has
    a pathlength of zero
    * `expiry`: a string representing the expiry date of the CA
  """
  defstruct [:pathlength, :pathlenzero, :expiry]

  defimpl Jason.Encoder, for: CFXXL.CAConfig do
    def encode(ca_config, options) do
      # Encode only non-nil values
      ca_config
      |> Map.from_struct()
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.into(%{})
      |> Jason.Encoder.encode(options)
    end
  end
end
