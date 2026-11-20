defmodule FarmFleetLiveWeb.PageController do
  use FarmFleetLiveWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
