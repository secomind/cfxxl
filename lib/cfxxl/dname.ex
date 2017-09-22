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

defmodule CFXXL.DName do
  defstruct [:C, :L, :O, :OU, :ST]

  defimpl Poison.Encoder, for: CFXXL.DName do
    def encode(dname, options) do
      # Encode only non-nil values
      filtered_dname =
        dname
        |> Map.from_struct()
        |> Enum.filter(fn {_, v} -> v end)
        |> Enum.into(%{})

      # Wrap it in a list since the API wants it
      # this way
      Poison.Encoder.encode([filtered_dname], options)
    end
  end
end
