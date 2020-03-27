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

defmodule CFXXL.KeyConfig do
  @moduledoc """
  Module defining a struct to configure the crypto for a new key/CSR
  pair
  """

  @derive [Jason.Encoder]

  @doc """
  A struct containing an algorithm/size pair to configure key crypto.

  The fields are:
    * `algo`
    * `size`

  The CFSSL API accepts the following values for `algo`:
    * `:ecdsa`
    * `:rsa`

  When `algo` is `:rsa`, `size` can be any value between 2048 and 8192.

  When `algo` is `:ecdsa`, `size` can be one of:
    * 256
    * 384
    * 521
  """
  defstruct algo: :ecdsa, size: 256
end
