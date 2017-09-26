CFXXL [![hex.pm version](https://img.shields.io/hexpm/v/cfxxl.svg)](https://hex.pm/packages/cfxxl) [![Build Status](https://travis-ci.org/ispirata/cfxxl.svg?branch=master)](https://travis-ci.org/ispirata/cfxxl) [![Coverage Status](https://coveralls.io/repos/github/ispirata/cfxxl/badge.svg)](https://coveralls.io/github/ispirata/cfxxl)
============

An Elixir client for [CFSSL](https://github.com/cloudflare/cfssl).

## Installation

Add `cfxxl` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:cfxxl, "~> 0.1"}]
end
```

## Documentation

The documentation is available on [HexDocs](https://hexdocs.pm/cfxxl/0.1.0/CFXXL.html)

## Usage examples

Create a client pointing to the CFSSL API

```elixir
client = CFXXL.Client.new("http://localhost:8888")
```

Use the client to call the functions in the `CFXXL` module

```elixir
hosts = ["www.example.com", "example.com"]
dname = %CFXXL.DName{O: "Example Ltd"}
key = %CFXXL.KeyConfig{algo: :rsa, size: 4096}
new_key = client |> CFXXL.newkey(hosts, dname, key: key)
```
