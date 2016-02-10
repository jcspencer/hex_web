defmodule HexWeb.API.OwnerController do
  use HexWeb.Web, :controller

  def index(conn, %{"name" => name}) do
    package = HexWeb.Repo.get_by!(Package, name: name)

    authorized(conn, [], &package_owner?(package, &1), fn _ ->
      owners =  Package.owners(package) |> HexWeb.Repo.all
      conn
      |> api_cache(:private)
      |> render(:index, owners: owners)
    end)
  end

  def show(conn, %{"name" => name, "email" => email}) do
    email = URI.decode_www_form(email)
    package = HexWeb.Repo.get_by!(Package, name: name)
    owner = HexWeb.Repo.get_by!(User, email: email)

    authorized(conn, [], &package_owner?(package, &1), fn _ ->
      if package_owner?(package, owner) do
        conn
        |> api_cache(:private)
        |> send_resp(204, "")
      else
        not_found(conn)
      end
    end)
  end

  def create(conn, %{"name" => name, "email" => email}) do
    email = URI.decode_www_form(email)
    package = HexWeb.Repo.get_by!(Package, name: name)
    user = HexWeb.Repo.get_by!(User, email: email)

    authorized(conn, [], &package_owner?(package, &1), fn _ ->
      Package.create_owner(package, user) |> HexWeb.Repo.insert!

      conn
      |> api_cache(:private)
      |> send_resp(204, "")
    end)
  end

  def delete(conn, %{"name" => name, "email" => email}) do
    email = URI.decode_www_form(email)
    package = HexWeb.Repo.get_by!(Package, name: name)
    owner = HexWeb.Repo.get_by!(User, email: email)

    authorized(conn, [], &package_owner?(package, &1), fn _ ->
      if HexWeb.Repo.one!(Package.is_single_owner(package)) do
        conn
        |> api_cache(:private)
        |> send_resp(403, "")
      else
        Package.owner(package, owner)
        |> HexWeb.Repo.delete_all

        conn
        |> api_cache(:private)
        |> send_resp(204, "")
      end
    end)
  end
end
