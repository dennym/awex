defmodule AWeX.HTTPClient.Hackney do
  @moduledoc """
  Built-in hackney-based HTTPClient.
  """

  require Logger

  @behaviour AWeX.HTTPClient
  @user_agent {"User-Agent", "awex/#{AWeX.version()}"}

  @impl true
  def init do
    unless Code.ensure_loaded?(:hackney) do
      Logger.error("""
      Could not find hackney dependency.

      Please add :hackney to your dependencies:

          {:hackney, "~> 1.9"}

      Or set your own AWeX.HTTPClient:

          config :awex, :http_client, MyAPIClient
      """)

      raise "missing hackney dependency"
    end

    _ = Application.ensure_all_started(:hackney)
    :ok
  end

  @impl true
  def post(url, headers, body, %AWeX.Email{} = email) do
    :hackney.post(
      url,
      [@user_agent | headers],
      body,
      [:with_body | hackney_options]
    )
  end
end