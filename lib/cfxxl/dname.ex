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

defmodule CFXXL.DName do
  @moduledoc """
  Module defining a struct for certificates DN
  """

  @doc """
  A struct representing a Distinguished Name.

  It supports the current fields:
    * `C`: country
    * `L`: locality
    * `O`: organization
    * `OU`: organizational unit
    * `ST`: state or province name
  """
  defstruct [:C, :L, :O, :OU, :ST]

  @type t() :: %__MODULE__{
          C: String.t(),
          L: String.t(),
          O: String.t(),
          OU: String.t(),
          ST: String.t()
        }

  defimpl Jason.Encoder, for: CFXXL.DName do
    def encode(dname, options) do
      # Encode only non-nil values
      filtered_dname =
        dname
        |> Map.from_struct()
        |> Enum.filter(fn {_, v} -> v end)
        |> Enum.into(%{})

      # Wrap it in a list since the API wants it
      # this way
      Jason.Encoder.encode([filtered_dname], options)
    end
  end
end
