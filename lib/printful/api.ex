defmodule Elementary.Printful.Api do
  @moduledoc """
  A simple HTTP client for Printful
  """

  alias Elementary.Printful.ApiError

  def new() do
    config = Application.get_env(:store, __MODULE__)

    middleware = [
      Elementary.Printful.Cache,
      {Tesla.Middleware.JSON,
       [
         engine_opts: [keys: :atoms]
       ]},
      Tesla.Middleware.Telemetry,
      {Tesla.Middleware.BaseUrl, config[:baseUrl]},
      {Tesla.Middleware.Headers,
       [
         {"Authorization", "Basic #{Base.encode64(config[:api_key])}"}
       ]}
    ]

    Tesla.client(middleware, Application.get_env(:tesla, :adapter))
  end

  def get(url, query \\ []) do
    new()
    |> Tesla.get(url, query: query)
    |> parse_result!()
  end

  def post(url, body) do
    new()
    |> Tesla.post(url, Jason.encode!(body))
    |> parse_result!()
  end

  defp parse_result!(res) do
    case res do
      {:ok, %{status: 200, body: %{result: result}}} ->
        result

      {:ok, %{body: %{error: %{message: message}}}} ->
        raise ApiError, message: message

      res ->
        raise ApiError, message: "Unable to communicate with Printful"
    end
  end
end