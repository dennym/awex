defmodule AwexTest do
  use ExUnit.Case
  import Awex
  alias Jason

  doctest Awex

  setup_all do
    :meck.new(Jason, [:no_link])

    on_exit(fn ->
      :meck.unload(Jason)
    end)
  end

  setup do
    on_exit(fn ->
      Application.delete_env(:awex, :deserialization_options)
    end)
  end

  test "authorization_header using user and password" do
    assert authorization_header(%{user: "user", password: "password"}, []) == [
             {"Authorization", "Basic dXNlcjpwYXNzd29yZA=="}
           ]
  end

  test "authorization_header using access token" do
    assert authorization_header(%{access_token: "9820103"}, []) == [
             {"Authorization", "token 9820103"}
           ]
  end

  test "process response on a 200 response" do
    assert {200, "json", _} =
             process_response(%HTTPoison.Response{status_code: 200, headers: %{}, body: "json"})

    assert :meck.validate(Jason)
  end

  test "process response on a non-200 response" do
    assert {404, "json", _} =
             process_response(%HTTPoison.Response{status_code: 404, headers: %{}, body: "json"})

    assert :meck.validate(Jason)
  end

  test "process_response_body with an empty body" do
    assert process_response_body("") == nil
  end

  test "process_response_body with content" do
    :meck.expect(Jason, :decode!, 2, :decoded_json)

    assert process_response_body("json") == :decoded_json
  end

  test "process_response_body with serialization options" do
    Application.put_env(:awex, :deserialization_options, keys: :atoms)

    :meck.expect(Jason, :decode!, fn _, [keys: :atoms] -> :decoded_json end)

    assert process_response_body("json") == :decoded_json
  end

  test "process response on a non-200 response and empty body" do
    assert {404, nil, _} =
             process_response(%HTTPoison.Response{status_code: 404, headers: %{}, body: nil})
  end
end
