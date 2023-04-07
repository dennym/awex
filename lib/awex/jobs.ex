defmodule Awex.Jobs do
  import Awex

  alias Awex.Client

  @doc """
  Get a single `job`.

  ## Example

      Awex.Jobs.find client, "edgurgel"
      Awex.Jobs.find client, "iurifq"

  More info at: https://docs.ansible.com/ansible-tower/latest/html/towerapi/api_ref.html#/Jobs/Jobs_jobs_read_0
  """
  @spec find(Client.t(), binary) :: Awex.response()
  def find(client \\ %Client{}, job) do
    get("jobs/#{job}", client)
  end

  @doc """
  Get all users.
  ## Example
      Tentacat.Users.list
      Tentacat.Users.list client
  More info at: http://developer.github.com/v3/users/#get-all-users
  """
  @spec list(Client.t(), any) :: Tentacat.response()
  def list(client \\ %Client{}, options \\ []) do
    get("jobs", client, [], Keyword.merge([pagination: :none], options))
  end
end
