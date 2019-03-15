defmodule FollowThrough.Http do
  @callback post(url :: String.t(), body :: map()) ::
              {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
              | {:error, HTTPoison.Error.t()}
  @callback post(url :: String.t(), body :: map(), headers :: HTTPoison.headers()) ::
              {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
              | {:error, HTTPoison.Error.t()}
  @callback post(
              url :: String.t(),
              body :: any(),
              headers :: HTTPoison.headers(),
              options :: keyword()
            ) ::
              {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
              | {:error, HTTPoison.Error.t()}
end
