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

defmodule CFXXL.Client do
  @moduledoc """
  Handle the client to be passed as parameter when using `CFXXL` functions.
  """

  @api_prefix "api/v1/cfssl"
  @accepted_opts [:timeout, :recv_timeout, :proxy, :proxy_auth, :ssl]

  @doc """
  The struct representing a Client, it contains the endpoint and options
  to be passed when making a request.
  """
  defstruct endpoint: "http://localhost:8888/#{@api_prefix}", options: []

  @doc """
  Returns a default client

  ## Examples

  ```
  iex> CFXXL.Client.new()
  %CFXXL.Client{endpoint: "http://localhost:8888/api/v1/cfssl", options: []}
  ```
  """
  def new(), do: %__MODULE__{}

  @doc """
  Creates a client with the given parameters.

  ## Arguments
    * `base_url`: the base URL to reach CFSSL, without the API prefix.
    * `options`: a keyword list with options passed to HTTPoison when making
  a request.

  ## Options
    * `:timeout`
    * `:recv_timeout`
    * `:proxy`
    * `:proxy_auth`
    * `:ssl`

  For the documentation of the options see `HTTPoison.request/5`

  ## Examples

  ```
  iex> CFXXL.Client.new("https://ca.example.com:10000", recv_timeout: 15000)
  %CFXXL.Client{endpoint: "https://ca.example.com:10000/api/v1/cfssl", options: [recv_timeout: 15000]}
  ```
  """
  def new(base_url, options \\ []) do
    endpoint =
      if String.ends_with?(base_url, "/") do
        "#{base_url}#{@api_prefix}"
      else
        "#{base_url}/#{@api_prefix}"
      end

    filtered_opts =
      options
      |> Enum.filter(fn {k, _} -> k in @accepted_opts end)

    %__MODULE__{endpoint: endpoint, options: filtered_opts}
  end
end
