defmodule AWeX do
  alias AWeX.Client
  alias Jason

  @user_agent [{"User-agent", "awex"}]
  @content_type [{"Content-Type", "application/json"}]

  @type response ::
          {:ok, term, HTTPoison.Response.t()}
          | {integer, any, HTTPoison.Response.t()}
          | pagination_response

  @type pagination_response :: {response, binary | nil, Client.auth()}


  defimpl Jason.Encoder, for: Tuple do
    def encode(tuple, opts) when is_tuple(tuple) do
      [tuple]
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  @spec process_response_body(binary) :: term
  def process_response_body(""), do: nil
  def process_response_body(body) do
    Jason.decode!(body, deserialization_options())
  end

  @spec process_response(HTTPoison.Response.t() | {integer, any, HTTPoison.Response.t()}) ::
          response
  def process_response(%HTTPoison.Response{status_code: status_code, body: body} = resp),
    do: {status_code, body, resp}

  def process_response({_status_code, _, %HTTPoison.Response{} = resp}),
    do: process_response(resp)

  @spec delete(binary, Client.t(), any) :: response
  def get(path, client, body \\ "") do
    _request(:get, url(client, path), client.auth, body)
  end

  @spec delete(binary, Client.t(), any) :: response
  def delete(path, client, body \\ "") do
    _request(:delete, url(client, path), client.auth, body)
  end

  @spec post(binary, Client.t(), any) :: response
  def post(path, client, body \\ "") do
    _request(:post, url(client, path), client.auth, body)
  end

  @spec patch(binary, Client.t(), any) :: response
  def patch(path, client, body \\ "") do
    _request(:patch, url(client, path), client.auth, body)
  end

  @spec put(binary, Client.t(), any) :: response
  def put(path, client, body \\ "") do
    _request(:put, url(client, path), client.auth, body)
  end




  # build headers
  @spec _request(atom, binary, Client.auth(), any) :: response
  def _request(method, url, auth, body \\ "") do
    json_request(method, url, body, authorization_header(auth, @user_agent ++ @content_type))
  end

  # encode
  @spec json_request(atom, binary, any, keyword, keyword) :: response
  def json_request(method, url, body \\ "", headers \\ [], options \\ []) do
    case method do
      :get -> raw_request(method, url, body, headers, options)
      _ -> raw_request(method, url, Jason.encode!(body), headers, options)
    end
  end

  def raw_request(method, url, body \\ "", headers \\ [], options \\ []) do
    method
    |> request!(url, body, extra_headers() ++ headers, extra_options() ++ options)
    |> process_response
  end


  defp extra_options do
    Application.get_env(:awex, :request_options, [])
  end

  defp extra_headers do
    Application.get_env(:awex, :extra_headers, [])
  end

  defp deserialization_options do
    Application.get_env(:awex, :deserialization_options, labels: :binary)
  end

  def raw_request(method, url, body \\ "", headers \\ [], options \\ []) do
    method
    |> request!(url, body, extra_headers() ++ headers, extra_options() ++ options)
    |> process_response
  end

  @spec request_stream(atom, binary, Client.auth(), any, :one_page | nil | :stream) ::
          Enumerable.t() | response
  def request_stream(method, url, auth, body \\ "", override \\ nil) do
    request_with_pagination(method, url, auth, Jason.encode!(body))
    |> stream_if_needed(override)
  end

  @spec stream_if_needed(pagination_response, :one_page | nil) :: response
  @spec stream_if_needed({response, binary | nil, Client.auth()}, :stream) :: Enumerable.t()
  defp stream_if_needed({response, _, _}, :one_page), do: response
  defp stream_if_needed({response, nil, _}, _), do: response

  defp stream_if_needed(initial_results = {response, _, _}, nil) do
    {elem(response, 0),
     Enum.to_list(Stream.resource(fn -> initial_results end, &process_stream/1, fn _ -> nil end)),
     elem(response, 2)}
  end

  defp stream_if_needed(initial_results, :stream) do
    Stream.resource(fn -> initial_results end, &process_stream/1, fn _ -> nil end)
  end

  defp process_stream({[], nil, _}), do: {:halt, nil}

  defp process_stream({[], next, auth}) do
    request_with_pagination(:get, next, auth, "")
    |> process_stream
  end

  defp process_stream({{_, items, _}, next, auth}) when is_list(items) do
    {items, {[], next, auth}}
  end

  defp process_stream({item, next, auth}) do
    {[item], {[], next, auth}}
  end

  @spec request_with_pagination(atom, binary, Client.auth(), any) :: pagination_response
  def request_with_pagination(method, url, auth, body \\ "") do
    resp =
      request!(
        method,
        url,
        Jason.encode!(body),
        authorization_header(auth, extra_headers() ++ @user_agent ++ @content_type),
        extra_options()
      )

    case process_response(resp) do
      {status, _, _} when status in [301, 302, 307] ->
        request_with_pagination(method, location_header(resp), auth)

      _ ->
        build_pagination_response(resp, auth)
    end
  end

  @spec build_pagination_response(
          HTTPoison.Response.t() | {integer, any, HTTPoison.Response.t()},
          Client.auth()
        ) :: pagination_response
  defp build_pagination_response(%HTTPoison.Response{:headers => headers} = resp, auth) do
    {process_response(resp), next_link(headers), auth}
  end

  defp build_pagination_response({_, _, %HTTPoison.Response{} = resp}, auth) do
    build_pagination_response(resp, auth)
  end

  defp location_header({_, _, resp}),
    do: location_header(resp)

  defp location_header(resp) do
    [{"Location", url}] = Enum.filter(resp.headers, &match?({"Location", _}, &1))
    url
  end

  @spec next_link(list) :: binary | nil
  defp next_link(headers) do
    for {"Link", link_header} <- headers,
        links <- String.split(link_header, ",") do
      Regex.named_captures(~r/<(?<link>.*)>;\s*rel=\"(?<rel>.*)\"/, links)
      |> case do
        %{"link" => link, "rel" => "next"} -> link
        _ -> nil
      end
    end
    |> Enum.filter(&(not is_nil(&1)))
    |> List.first()
  end

  @spec url(client :: Client.t(), path :: binary) :: binary
  defp url(_client = %Client{endpoint: endpoint}, path) do
    endpoint <> path
  end

  @doc """
  Take an existing URI and add additional params, appending and replacing as necessary.

  ## Examples

      iex> add_params_to_url("http://example.com/wat", [])
      "http://example.com/wat"

      iex> add_params_to_url("http://example.com/wat", [q: 1])
      "http://example.com/wat?q=1"

      iex> add_params_to_url("http://example.com/wat", [q: 1, t: 2])
      "http://example.com/wat?q=1&t=2"

      iex> add_params_to_url("http://example.com/wat", %{q: 1, t: 2})
      "http://example.com/wat?q=1&t=2"

      iex> add_params_to_url("http://example.com/wat?q=1&t=2", [])
      "http://example.com/wat?q=1&t=2"

      iex> add_params_to_url("http://example.com/wat?q=1", [t: 2])
      "http://example.com/wat?q=1&t=2"

      iex> add_params_to_url("http://example.com/wat?q=1", [q: 3, t: 2])
      "http://example.com/wat?q=3&t=2"

      iex> add_params_to_url("http://example.com/wat?q=1&s=4", [q: 3, t: 2])
      "http://example.com/wat?q=3&s=4&t=2"

      iex> add_params_to_url("http://example.com/wat?q=1&s=4", %{q: 3, t: 2})
      "http://example.com/wat?q=3&s=4&t=2"

  """
  @spec add_params_to_url(binary, list) :: binary
  def add_params_to_url(url, params) do
    url
    |> URI.parse()
    |> merge_uri_params(params)
    |> String.Chars.to_string()
  end

  @spec merge_uri_params(URI.t(), list) :: URI.t()
  defp merge_uri_params(uri, []), do: uri

  defp merge_uri_params(%URI{query: nil} = uri, params) when is_list(params) or is_map(params) do
    uri
    |> Map.put(:query, URI.encode_query(params))
  end

  defp merge_uri_params(%URI{} = uri, params) when is_list(params) or is_map(params) do
    uri
    |> Map.update!(:query, fn q ->
      q
      |> URI.decode_query()
      |> Map.merge(param_list_to_map_with_string_keys(params))
      |> URI.encode_query()
    end)
  end

  @spec param_list_to_map_with_string_keys(list) :: map
  defp param_list_to_map_with_string_keys(list) when is_list(list) or is_map(list) do
    for {key, value} <- list, into: Map.new() do
      {"#{key}", value}
    end
  end

  @doc """
  There are two ways to authenticate through AWX API v2:

    * Basic authentication
    * OAuth2 Token

  This function accepts both.

  ## Examples

      iex> AWeX.authorization_header(%{user: "user", password: "password"}, [])
      [{"Authorization", "Basic dXNlcjpwYXNzd29yZA=="}]

      iex> AWeX.authorization_header(%{access_token: "92873971893"}, [])
      [{"Authorization", "token 92873971893"}]

  More info at: http://developer.github.com/v3/#authentication
  """
  @spec authorization_header(Client.auth(), list) :: list
  def authorization_header(%{user: user, password: password}, headers) do
    userpass = "#{user}:#{password}"
    headers ++ [{"Authorization", "Basic #{:base64.encode(userpass)}"}]
  end

  def authorization_header(%{access_token: token}, headers) do
    headers ++ [{"Authorization", "token #{token}"}]
  end

  def authorization_header(_, headers), do: headers

  @doc """
  Same as `authorization_header/2` but defaults initial headers to include `@user_agent` and @content_type.
  """
  def authorization_header(options), do: authorization_header(options, @user_agent ++ @content_type)
end
