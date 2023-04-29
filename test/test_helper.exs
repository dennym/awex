if Application.fetch_env!(:awex, :http_client) == AWeX.HTTPClient.Finch do
  Application.put_env(:awex, :finch_name, AWeX.Test.Finch)
  Finch.start_link(name: AWeX.Test.Finch)
end

ExUnit.configure(exclude: [skip: true])
ExUnit.start()

# Application.ensure_all_started(:bypass)
