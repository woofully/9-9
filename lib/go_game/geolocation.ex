defmodule GoGame.Geolocation do
  @moduledoc """
  Provides IP geolocation services using ipapi.co free API.
  """

  require Logger

  @doc """
  Fetches the city name for a given IP address.
  Returns {:ok, city} or {:error, reason}.

  Examples:
      iex> get_city_from_ip("8.8.8.8")
      {:ok, "Mountain View"}

      iex> get_city_from_ip("127.0.0.1")
      {:ok, "Unknown"}
  """
  def get_city_from_ip(ip) when is_binary(ip) do
    # Skip geolocation for local/private IPs
    if local_ip?(ip) do
      {:ok, "Local"}
    else
      fetch_city_from_api(ip)
    end
  end

  def get_city_from_ip(_), do: {:ok, "Unknown"}

  defp fetch_city_from_api(ip) do
    url = "https://ipapi.co/#{ip}/city/"

    case Req.get(url, receive_timeout: 5000) do
      {:ok, %{status: 200, body: city}} when is_binary(city) and byte_size(city) > 0 ->
        {:ok, String.trim(city)}

      {:ok, %{status: 429}} ->
        Logger.warning("Geolocation rate limit exceeded for IP: #{ip}")
        {:ok, "Unknown"}

      {:ok, %{status: status}} ->
        Logger.warning("Geolocation API returned status #{status} for IP: #{ip}")
        {:ok, "Unknown"}

      {:error, reason} ->
        Logger.warning("Failed to fetch geolocation for IP #{ip}: #{inspect(reason)}")
        {:ok, "Unknown"}
    end
  end

  defp local_ip?(ip) do
    ip in ["127.0.0.1", "::1", "localhost"] or
    String.starts_with?(ip, "192.168.") or
    String.starts_with?(ip, "10.") or
    String.starts_with?(ip, "172.16.") or
    String.starts_with?(ip, "172.17.") or
    String.starts_with?(ip, "172.18.") or
    String.starts_with?(ip, "172.19.") or
    String.starts_with?(ip, "172.20.") or
    String.starts_with?(ip, "172.21.") or
    String.starts_with?(ip, "172.22.") or
    String.starts_with?(ip, "172.23.") or
    String.starts_with?(ip, "172.24.") or
    String.starts_with?(ip, "172.25.") or
    String.starts_with?(ip, "172.26.") or
    String.starts_with?(ip, "172.27.") or
    String.starts_with?(ip, "172.28.") or
    String.starts_with?(ip, "172.29.") or
    String.starts_with?(ip, "172.30.") or
    String.starts_with?(ip, "172.31.")
  end
end
