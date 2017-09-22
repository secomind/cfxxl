# CFXXL

CFSSL API client for Elixir

## Installation

Add `cfxxl` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:cfxxl, github: "Ispirata/cfxxl"}]
end
```

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
