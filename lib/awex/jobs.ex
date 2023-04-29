defmodule AWeX.Jobs do
  import AWeX

  alias AWeX.Client

  @doc """
  Get a single `job`.

  ## Example

      AWeX.Jobs.find client, "1234"
      AWeX.Jobs.find client, "4321"

  More info at: https://docs.ansible.com/ansible-tower/latest/html/towerapi/api_ref.html#/Jobs/Jobs_jobs_read_0
  """
  @spec find(Client.t(), binary) :: AWeX.response()
  def find(client \\ %Client{}, job_id) do
    get("jobs/#{job_id}", client)
  end

  @doc """
  Get all jobs.
  ## Example
      AWeX.Jobs.list
      AWeX.Jobs.list client
  More info at: http://developer.github.com/v3/users/#get-all-users
  """
  @spec list(Client.t(), any) :: AWeX.response()
  def list(client \\ %Client{}, options \\ []) do
    get("jobs", client, [], Keyword.merge([pagination: :none], options))
  end
end
