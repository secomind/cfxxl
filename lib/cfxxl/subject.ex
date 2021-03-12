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

  @type t() :: %__MODULE__{
          CN: String.t(),
          dname: CFXXL.DName.t()
        }

  defimpl Jason.Encoder, for: CFXXL.Subject do
    def encode(subject, options) do
      # Encode only non-nil values and substitute dname
      # with names
      subject
      |> Map.from_struct()
      |> Map.put(:names, subject.dname)
      |> Map.delete(:dname)
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.into(%{})
      |> Jason.Encoder.encode(options)
    end
  end
end
