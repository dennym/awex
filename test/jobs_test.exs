defmodule AWeX.JobsTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import AWeX.Jobs

  doctest AWeX.Jobs

  @client AWeX.Client.new(%{user: "admin", password: "1234"}, "http://192.168.49.2:31350/api/v2/")

  test "find/2" do
    use_cassette "jobs#find" do
      {_, %{"name" => name}, _} = find(@client, "1")
      assert name == "Demo Job Template"
    end
  end

  test "list/1" do
    use_cassette "jobs#list", match_requests_on: [:query] do
      assert elem(list(@client), 1) == []
    end
  end
end
