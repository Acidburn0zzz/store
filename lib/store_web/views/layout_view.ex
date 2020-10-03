defmodule Elementary.StoreWeb.LayoutView do
  use Elementary.StoreWeb, :view

  def connection(%{conn: conn}), do: conn
  def connection(%{socket: socket}), do: socket

  def page_title(title) do
    cond do
      is_nil(title) ->
        "elementary Store"

      String.contains?(title, "Store") ->
        title

      true ->
        "#{title} ⋅ elementary Store"
    end
  end

  def cart_count(conn) do
    0
  end

  def available_languages() do
    Elementary.StoreWeb.Gettext.known_languages()
  end

  def current_language() do
    Gettext.get_locale()
  end

  def language_path(%{request_path: "/"} = conn, code),
    do: Routes.language_url(conn, :set, code)

  def language_path(conn, code) do
    absolute_path =
      conn.request_path
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(locale: code))
      |> URI.to_string()

    Routes.static_url(Endpoint, absolute_path)
  end

  defp year() do
    Map.get(DateTime.utc_now(), :year)
  end
end
