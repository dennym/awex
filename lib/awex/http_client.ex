defmodule AWeX.HTTPClient do
  @moduledoc """
  Specification for a AWeX API client.

  It can be set to your own client with:

      config :awex, :http_client, MyHTTPClient

  AWeX comes with `AWeX.HTTPClient.Hackney` and `AWeX.HTTPClient.Finch`.
  """

  @type url :: binary()
  @type headers :: [{binary(), binary()}]
  @type body :: binary()
  @type status :: pos_integer()

  @doc """
  Callback to initializes the given api client.
  """
  @callback init() :: :ok

  @doc """
  Callback invoked when posting to a given URL.
  """
  @callback get(url, headers, body, Client.auth()) ::
              {:ok, status, headers, body} | {:error, term()}

  @doc """
  Callback invoked when posting to a given URL.
  """
  @callback post(url, headers, body, Client.auth()) ::
              {:ok, status, headers, body} | {:error, term()}

  @optional_callbacks init: 0


  @doc """
  API used by adapters to get to a given URL with headers, body, and auth.
  """
  def get(url, headers, body, auth) do
    http_client().post(url, headers, body, auth)
  end

  @doc """
  API used by adapters to post to a given URL with headers, body, and auth.
  """
  def post(url, headers, body, auth) do
    http_client().post(url, headers, body, auth)
  end


  ....

  @doc false
  def init do
    client = http_client()

    if Code.ensure_loaded?(client) and function_exported?(client, :init, 0) do
      :ok = client.init()
    end

    :ok
  end

  defp http_client do
    Application.fetch_env!(:awex, :http_client)
  end
end