defmodule HexWeb.Web.RouterTest do
  use HexWebTest.Case
  import Plug.Test
  alias HexWeb.Router
  alias HexWeb.Package
  alias HexWeb.Release

  setup do
    first_date  = Ecto.DateTime.from_erl({{2014, 5, 1}, {10, 11, 12}})
    second_date = Ecto.DateTime.from_erl({{2014, 5, 2}, {10, 11, 12}})
    last_date   = Ecto.DateTime.from_erl({{2014, 5, 3}, {10, 11, 12}})

    foo = HexWeb.Repo.insert(%Package{name: "foo", meta: "{}", created_at: first_date, updated_at: first_date})
    bar = HexWeb.Repo.insert(%Package{name: "bar", meta: "{}", created_at: second_date, updated_at: second_date})
    other = HexWeb.Repo.insert(%Package{name: "other", meta: "{}", created_at: last_date, updated_at: last_date})

    {:ok, _} = Release.create(foo, "0.0.1", "foo", [], "", Ecto.DateTime.from_erl({{2014, 5, 3}, {10, 11, 1}}))
    {:ok, _} = Release.create(foo, "0.0.2", "foo", [], "", Ecto.DateTime.from_erl({{2014, 5, 3}, {10, 11, 2}}))
    {:ok, _} = Release.create(foo, "0.1.0", "foo", [], "", Ecto.DateTime.from_erl({{2014, 5, 3}, {10, 11, 3}}))
    {:ok, _} = Release.create(bar, "0.0.1", "bar", [], "", Ecto.DateTime.from_erl({{2014, 5, 3}, {10, 11, 4}}))
    {:ok, _} = Release.create(bar, "0.0.2", "bar", [], "", Ecto.DateTime.from_erl({{2014, 5, 3}, {10, 11, 5}}))
    {:ok, _} = Release.create(other, "0.0.1", "other", [], "", Ecto.DateTime.from_erl({{2014, 5, 3}, {10, 11, 6}}))
    :ok
  end

  test "front page" do
    path     = Path.join([__DIR__, "..", "..", "fixtures"])
    logfile1 = File.read!(Path.join(path, "s3_logs_1.txt"))
    logfile2 = File.read!(Path.join(path, "s3_logs_2.txt"))
    store    = Application.get_env(:hex_web, :store)

    store.put_logs("hex/2013-11-01-21-32-16-E568B2907131C0C0", logfile1)
    store.put_logs("hex/2013-11-01-21-32-19-E568B2907131C0C0", logfile2)
    HexWeb.Stats.Job.run({2013, 11, 1})

    conn = conn(:get, "/")
    conn = Router.call(conn, [])

    assert conn.status == 200
    assert conn.assigns[:total][:all] == 9
    assert conn.assigns[:total][:week] == 0
    assert conn.assigns[:package_top] == [{"foo", 7}, {"bar", 2}]
    assert conn.assigns[:num_packages] == 3
    assert conn.assigns[:num_releases] == 6
    assert conn.assigns[:releases_new] == [{"0.0.1", "other"}, {"0.0.2", "bar"}, {"0.0.1", "bar"}, {"0.1.0", "foo"}, {"0.0.2", "foo"}, {"0.0.1", "foo"} ]
    assert Enum.count(conn.assigns[:package_new]) == 3
  end
end
