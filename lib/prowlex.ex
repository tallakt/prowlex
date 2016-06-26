defmodule Prowlex do
  @base "https://api.prowlapp.com/publicapi"
  @priorities %{very_low: -2, moderate: -1, normal: 0, high: 1, emergency: 2}
  @errors %{
    400 => :bad_request,
    401 => :not_authorized,
    406 => :limit_exceeded,
    409 => :not_user_approved,
    500 => :server_error
  }
  @error_codes Map.keys(@errors)


  @doc """
  Send a notification to a number of recipients.
  
  The parameters are:

  * `api_keys`: a list of strings containing API keys for all the recipients
  * `application_name`: the name of the application
  * `description`: the message to send

  The `opts` parameter may contain:
  
  * `:provider_key`: an optional provider key
  * `:priority`: a priority with the value in `:very_low`, `:moderate`,
    `:normal`, `:high` or `:emergency`
  * `:url`: an url that is added to the notifocation

  Possible return values are:

  * `{:ok, {remaining, resetdate}}`: any of the recipients' API keys are valid
  * `{:error, {:bad_request, "..."}}`
  * `{:error, {:not_authorized, "..."}}`
  * `{:error, {:linit_exceeded, "..."}}`
  * `{:error, {:not_user_approved, "..."}}`
  * `{:error, {:server error, "..."}}`

  The returned string is a descriptive error message returned from the server.

  For more details please refer to https://www.prowlapp.com/api.php

  """
  def add(api_keys, application_name, event, description, opts \\ []) do
    url = @base <> "/add"
    keys = Enum.join api_keys, ","

    params0 =
      [ apikey: keys,
        application: String.slice(application_name, 0..255),
        event: String.slice(event, 0..1023),
        description: String.slice(description, 0..9999)]
    
    provider_key =
      if Dict.has_key?(opts, :provider_key) do
        [providerkey: String.slice(Dict.get(opts, :provider_key), 0..39)]
      else
        []
      end

    url_param =
      if Dict.has_key?(opts, :url) do
        [url: String.slice(Dict.get(opts, :url), 0..511)]
      else
        []
      end

    priority =
      if Dict.has_key?(opts, :priority) do
        [priority: Dict.get(@priorities, Dict.get(opts, :priority))]
      else
        []
      end
      data = params0 ++ provider_key ++ url_param ++ priority

      with {:ok, %{status_code: code, body: body}} <- HTTPoison.post(url, {:form, data}),
        do: handle_generic_result(code, body)

  end



  @doc """
  Check whether an api key is valid

  The `opts` parameter may contain:
  
  * The optional `:provider_key`

  Possible return values are:

  * `{:ok, {remaining, resetdate}}`
  * `{:error, {:not_authorized, "..."}}`

  The returned string is a descriptive error message returned from the server.


  """
  def verify(api_key, opts \\ []) do
    provider_key = Dict.get opts, :provider_key
    url = @base <> "/verify"
    params = [apikey: api_key, providerkey: provider_key]
    with {:ok, %{status_code: code, body: body}} <- HTTPoison.get(url, [], params: params),
      do: handle_generic_result(code, body)
  end


  defp handle_generic_result(status_code, xml) do
    [{_, attributes, inner}] = Floki.find xml, "prowl *"
    case status_code do
      200 ->
        attr = Enum.into(attributes, %{})
        {remaining, _} = Integer.parse(Dict.get(attr, "remaining"))
        {reset_date, _} = Integer.parse(Dict.get(attr, "resetdate"))
        {:ok, {remaining, reset_date}}

      c when c in @error_codes ->
        [message] = inner
        {:error, {Map.get(@errors, c), message}}
    end
  end



end
