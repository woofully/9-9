defmodule GoGameWeb.AdminLive.Users do
  use GoGameWeb, :live_view

  alias GoGame.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_users(socket)}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply, load_users(socket)}
  end

  defp load_users(socket) do
    users = Accounts.list_users_with_location()
    assign(socket, :users, users)
  end
end
