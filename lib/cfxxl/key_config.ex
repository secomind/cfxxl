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

defmodule CFXXL.KeyConfig do
  @moduledoc """
  Module defining a struct to configure the crypto for a new key/CSR
  pair
  """

  @derive [Poison.Encoder]

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
