defmodule InfoSys.Wolfram do
  import SweetXml
  alias InfoSys.Result
  require Logger

  @behaviour InfoSys.Backend

  @base "http://api.wolframalpha.com/v2/query"

  @impl true
  def name do
    "wolfram"
  end

  @impl true
  def compute(query, _opts) do
    query
    |> fetch_xml()
    |> xpath(~x"/queryresult/pod[contains(@title, 'Result') or contains(@title, 'Definitions')]
      /subpod/plaintext/text()")
    |> build_results()
  end

  defp build_results(nil) do
    []
  end

  defp build_results(answer) do
    [%Result{backend: __MODULE__, score: 95, text: to_string(answer)}]
  end

  defp fetch_xml(query) do
    Logger.debug("#{url(query)}")
    {:ok, {_, _, body}} = :httpc.request(String.to_charlist(url(query)))

    body
  end

  defp url(input) do
    "#{@base}?" <> URI.encode_query(appid: app_id(), input: input, format: "plaintext")
  end

  defp app_id() do
    Application.fetch_env!(:info_sys, :wolfram)[:app_id]
  end
end
