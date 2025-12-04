defmodule GoGameWeb.UserSessionController do
  use GoGameWeb, :controller

  alias GoGame.Accounts
  alias GoGameWeb.UserAuth

  def create(conn, %{"_action" => "confirmed"} = params) do
    create(conn, params, "用户确认成功。")
  end

  def create(conn, params) do
    create(conn, params, "欢迎回来！")
  end

  # magic link login
  defp create(conn, %{"user" => %{"token" => token} = user_params}, info) do
    case Accounts.login_user_by_magic_link(token) do
      {:ok, {user, tokens_to_disconnect}} ->
        UserAuth.disconnect_sessions(tokens_to_disconnect)

        conn
        |> put_flash(:info, info)
        |> UserAuth.log_in_user(user, user_params)

      _ ->
        conn
        |> put_flash(:error, "链接无效或已过期。")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  # username + password login
  defp create(conn, %{"user" => user_params}, info) do
    %{"username" => username, "password" => password} = user_params

    if user = Accounts.get_user_by_username_and_password(username, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the username is registered.
      conn
      |> put_flash(:error, "用户名或密码无效")
      |> put_flash(:username, String.slice(username, 0, 160))
      |> redirect(to: ~p"/users/log-in")
    end
  end

  def update_password(conn, %{"current_password" => password, "user" => user_params} = params) do
    user = conn.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)
    {:ok, {_user, expired_tokens}} = Accounts.update_user_password(user, password, user_params)

    # disconnect all existing LiveViews with old sessions
    UserAuth.disconnect_sessions(expired_tokens)

    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "密码更新成功！")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "已成功退出登录。")
    |> UserAuth.log_out_user()
  end
end
