# Prowlex

Prowlex implements the API for sending notifications with Prowl App. 

For more information see https://www.prowlapp.com/

This provides the simplest implementation with no testing. Work in progress

## Code samples

```elixir
> Prowlex.verify "35bcc1ac83a76c8796b1fef4121b5e033c0a412a"
{:ok, {971, 1466978693}}
> api_keys = ~w(35bcc1ac83a76c8796b1fef4121b5e033c0a412a)
> Prowlex.add api_keys, "My App", "Info event", "Test message"
{:ok, {969, 1466978693}}
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `prowlex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:prowlex, "~> 0.1.0"}]
    end
    ```

  2. Ensure `prowlex` is started before your application:

    ```elixir
    def application do
      [applications: [:prowlex]]
    end
    ```

