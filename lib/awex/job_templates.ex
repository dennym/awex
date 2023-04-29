defmodule AWeX.JobTemplates do
  import AWeX

  alias AWeX.Client

  @doc """
  Get a single `job template`.

  ## Example

      AWeX.JobTemplate.find client, "1234"
      AWeX.JobTemplate.find client, "4321"

  More info at: https://docs.ansible.com/ansible-tower/latest/html/towerapi/api_ref.html#/Job_Templates/Job_Templates_job_templates_read
  """
  @spec find(Client.t(), binary) :: AWeX.response()
  def find(client \\ %Client{}, job_template_id) do
    get("job_template/#{job_template_id}/", client)
  end

  @doc """
  Get all job templates.
  ## Example
      AWeX.JobTemplate.list
      AWeX.JobTemplate.list client
  More info at: https://docs.ansible.com/ansible-tower/latest/html/towerapi/api_ref.html#/Job_Templates/Job_Templates_job_templates_list
  """
  @spec list(Client.t(), any) :: AWeX.response()
  def list(client \\ %Client{}, options \\ []) do
    get("job_templates/", client, [], Keyword.merge([pagination: :none], options))
  end
end
