defmodule ExpensesWeb.TagController do
  use ExpensesWeb, :controller
  alias Expenses.Data
  alias Expenses.Data.Tag

  plug :must_be_logged_in

  def index(conn, _params) do
    user = conn.assigns.current_user
    tags = Tag.filter(user: user, order_by: :name, preload: :taggings) |> Repo.all()
    render(conn, "index.html", tags: tags)
  end

  def show(conn, %{"id" => id}) do
    tag = load_tag(conn, id) |> Repo.preload(taggings: :expenses)
    render(conn, "show.html", tag: tag)
  end

  def new(conn, _params) do
    changeset = Tag.changeset(%Tag{}, %{}, :owner)
    render(conn, "new.html", changeset: changeset, colors: all_colors(conn))
  end

  def create(conn, %{"tag" => tag_params}) do
    user = conn.assigns.current_user
    case Data.insert_tag(%Tag{user_id: user.id}, tag_params, :owner) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Added tag \"#{tag.name}\".")
        |> redirect(to: Routes.tag_path(conn, :show, tag))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, colors: all_colors(conn))
    end
  end

  def edit(conn, %{"id" => id}) do
    tag = load_tag(conn, id)
    changeset = Tag.changeset(tag, %{}, :owner)
    render(conn, "edit.html", tag: tag, changeset: changeset, colors: all_colors(conn))
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = load_tag(conn, id)
    case Data.update_tag(tag, tag_params, :owner) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Updated tag \"#{tag.name}\".")
        |> redirect(to: Routes.tag_path(conn, :show, tag))

      {:error, changeset} ->
        render(conn, "edit.html", tag: tag, changeset: changeset, colors: all_colors(conn))
    end
  end

  def delete(conn, %{"id" => id}) do
    tag = load_tag(conn, id)
    Data.delete_tag!(tag)

    conn
    |> put_flash(:info, "Deleted tag \"#{tag.name}\".")
    |> redirect(to: Routes.tag_path(conn, :index))
  end

  #
  # Internal
  #

  defp load_tag(conn, id) do
    Tag.filter(user: conn.assigns.current_user, id: id) |> Repo.one!()
  end

  defp all_colors(conn) do
    Tag.filter(user: conn.assigns.current_user)
    |> Repo.all()
    |> Enum.map(& &1.color)
    |> Enum.uniq()
    |> Enum.sort()
  end
end
