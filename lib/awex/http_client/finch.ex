defmodule AWeX.HTTPClient.Finch do
  @moduledoc """
  Finch-based HTTPClient for AWeX.

      config :awex, :http_client, AWeX.HTTPClient.Finch

  In order to use `Finch` HTTP client, you must start `Finch` and provide a :name.
  Often in your supervision tree:

      children = [
        {Finch, name: AWeX.Finch}
      ]

  Or, in rare cases, dynamically:

      Finch.start_link(name: AWeX.Finch)

  If a name different from `AWeX.Finch` is used, or you want to use an existing Finch instance,
  you can provide the name via the config.

      config :awex,
        http_client: AWeX.HTTPClient.Finch,
        finch_name: My.Custom.Name
  """

  require Logger

  @behaviour AWeX.HTTPClient
  @user_agent {"User-Agent", "awex/#{AWeX.version()}"}

  @impl true
  def init do
    unless Code.ensure_loaded?(Finch) do
      Logger.error("""
      Could not find finch dependency.

      Please add :finch to your dependencies:

          {:finch, "~> 0.16"}

      Or set your own AWeX.HTTPClient:

          config :awex, :http_client, MyAPIClient
      """)

      raise "missing finch dependency"
    end

    _ = Application.ensure_all_started(:finch)
    :ok
  end

  @impl true
  def post(url, headers, body, auth) do
    url = IO.iodata_to_binary(url)
    request = Finch.build(:post, url, [@user_agent | headers], body)

    case Finch.request(request, finch_name(), options) do
      {:ok, response} ->
        {:ok, response.status, response.headers, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp finch_name do
    Application.get_env(:awex, :finch_name, AWeX.Finch)
  end
end
