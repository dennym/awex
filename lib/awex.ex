defmodule Awex do
  @moduledoc """
  Base Module for the API Client.

  The API Documentation for awx can be found under https://docs.ansible.com/ansible-tower/latest/html/towerapi/api_ref.html.

  ## Requirements:

    * Tesla: the api client depends on Tesla. Every API call needs an instance of a `Tesla.Client` to be able to do the rest calls.any()

  """

  alias Awex.Client

  @type response ::
          {:ok, term, HTTPoison.Response.t()}
          | {integer, any, HTTPoison.Response.t()}
          | pagination_response

  @spec get(binary, Client.t()) :: response
  def get(path, client, params \\ [], options \\ []) do

  end

  def put(path, client, params \\ [], options \\ []) do

  end
end
