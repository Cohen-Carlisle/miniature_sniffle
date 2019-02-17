defmodule MiniatureSniffleWeb.OrderController do
  use MiniatureSniffleWeb, :controller
  alias MiniatureSniffle.Requisition

  def new(conn, _params) do
    select_options = Requisition.order_select_options(conn.assigns.user.id)
    render(conn, "new.html", select_options: select_options)
  end

  def create(conn, params) do
    create_order_params = create_order_params(params["order"])

    case Requisition.create_order(create_order_params, conn.assigns.user.id) do
      {:ok, %{id: id}} ->
        conn
        |> put_flash(:info, "Order #{id} successfully created.")
        |> redirect(to: Routes.order_path(conn, :new))

      {:error, errors} ->
        select_options = Requisition.order_select_options(conn.assigns.user.id)

        conn
        |> assign(:errors, errors)
        |> put_flash(:error, "Oops, something went wrong.")
        |> render("new.html", select_options: select_options)
    end
  end

  defp create_order_params(params) do
    %{
      location: location_params(params),
      patient: patient_params(params),
      prescription: prescription_params(params)
    }
  end

  defp location_params(%{"location_id" => id}) when id not in [nil, ""] do
    %{id: id}
  end

  defp location_params(params) do
    atomize_params(params, [:latitude, :longitude])
  end

  defp patient_params(%{"patient_id" => id}) when id not in [nil, ""] do
    %{id: id}
  end

  defp patient_params(params) do
    atomize_params(params, [:first_name, :last_name])
  end

  defp prescription_params(%{"prescription_id" => id}) when id not in [nil, ""] do
    %{id: id}
  end

  defp prescription_params(params) do
    atomize_params(params, [:name])
  end
end
