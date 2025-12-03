defmodule ProfileWeb.PageController do
  use ProfileWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
