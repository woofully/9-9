defmodule GoGameWeb.PageController do
  use GoGameWeb, :controller

  def home(conn, _params) do
    # Check if user is logged in
    if conn.assigns.current_scope && conn.assigns.current_scope.user do
      redirect(conn, to: "/lobby")
    else
      render(conn, :home)
    end
  end

  def cluster_status(conn, _params) do
    # Try to manually discover and connect to nodes
    query = Application.get_env(:go_game, :dns_cluster_query)

    dns_lookup = if query do
      case :inet_res.lookup(String.to_charlist(query), :in, :aaaa) do
        [] -> []
        ips -> Enum.map(ips, &:inet.ntoa/1)
      end
    else
      []
    end

    status = %{
      node: Node.self(),
      connected_nodes: Node.list(),
      all_nodes: [Node.self() | Node.list()],
      cookie: to_string(Node.get_cookie()),
      dns_cluster_query: query,
      dns_lookup_result: dns_lookup
    }

    json(conn, status)
  end
end
