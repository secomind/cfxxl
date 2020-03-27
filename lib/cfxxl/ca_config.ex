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
