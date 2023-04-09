defmodule Awex.ClientTest do
  use ExUnit.Case
  import Awex.Client

  doctest Awex.Client

  test "default endpoint from config" do
    client = new()
    assert client.endpoint == "http://awx.local.dev/api/v2/"

  end

  test "custom endpoint" do
    expected = "https://ghe.foo.com/api/v3/"

    creds = %{user: "bob", password: "bob"}

    client = new(creds, "https://ghe.foo.com/api/v3/")
    assert client.endpoint == expected

    client = new("https://ghe.foo.com/api/v3/")
    assert client.endpoint == expected

    # when tailing '/' is missing
    client = new(creds, "https://ghe.foo.com/api/v3")
    assert client.endpoint == expected
  end
end