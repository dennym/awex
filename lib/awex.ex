defmodule Awex do
  use HTTPoison.Base
  alias Awex.Client
  alias Jason

  @moduledoc """
  Base Module for the API Client.

  The API Documentation for awx can be found under https://docs.ansible.com/ansible-tower/latest/html/towerapi/api_ref.html.

  ## Requirements:

    * Tesla: the api client depends on Tesla. Every API call needs an instance of a `Tesla.Client` to be able to do the rest calls.any()

  """

  @type response ::
          {:ok, term, HTTPoison.Response.t()}
          | {integer, any, HTTPoison.Response.t()}
          | pagination_response

  @type pagination_response :: {response, binary | nil, Client.auth()}

  @spec get(binary, Client.t()) :: response
  def get(path, client, params \\ [], options \\ []) do
    url =
      client
      |> url(path)
      |> add_params_to_url(params)
  end

  def put(path, client, params \\ [], options \\ []) do

  end

  @spec url(client :: Client.t(), path :: binary) :: binary
  defp url(_client = %Client{endpoint: endpoint}, path) do
    endpoint <> path
  end
end
