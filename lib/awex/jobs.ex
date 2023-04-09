defmodule Awex.Jobs do
  import Awex

  alias Awex.Client

  @doc """
  Get a single `job`.

  ## Example

      Awex.Jobs.find client, "1234"
      Awex.Jobs.find client, "4321"

  More info at: https://docs.ansible.com/ansible-tower/latest/html/towerapi/api_ref.html#/Jobs/Jobs_jobs_read_0
  """
  @spec find(Client.t(), binary) :: Awex.response()
  def find(client \\ %Client{}, job_id) do
    get("jobs/#{job_id}", client)
  end

  @doc """
  Get all users.
  ## Example
      Awex.Jobs.list
      Awex.Jobs.list client
  More info at: http://developer.github.com/v3/users/#get-all-users
  """
  @spec list(Client.t(), any) :: Awex.response()
  def list(client \\ %Client{}, options \\ []) do
    get("jobs", client, [], Keyword.merge([pagination: :none], options))
  end
end
