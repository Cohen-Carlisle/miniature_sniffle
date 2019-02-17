defmodule MiniatureSniffleWeb.OrderControllerTest do
  use MiniatureSniffleWeb.ConnCase
  alias MiniatureSniffle.{Account, Repo, Requisition}

  test "GET /user/create_order", %{conn: conn} do
    resp_conn =
      conn
      |> assign(:user, %{id: 1, name: "test user"})
      |> get("/user/create_order")

    assert html_response(resp_conn, 200) =~ "Create Order"
  end

  describe "POST /user/create_order" do
    setup %{conn: conn} do
      pharmacy =
        %Account.Pharmacy{}
        |> Account.Pharmacy.changeset(%{name: "Valid Pharmacy"})
        |> Repo.insert!()

      location =
        %Requisition.Location{}
        |> Requisition.Location.changeset(%{
          latitude: "1",
          longitude: "1",
          pharmacy_id: pharmacy.id
        })
        |> Repo.insert!()

      patient =
        %Requisition.Patient{}
        |> Requisition.Patient.changeset(%{first_name: "Cohen", last_name: "Carlisle"})
        |> Repo.insert!()

      prescription =
        %Requisition.Prescription{}
        |> Requisition.Prescription.changeset(%{name: "Soma"})
        |> Repo.insert!()

      other_pharmacy =
        %Account.Pharmacy{}
        |> Account.Pharmacy.changeset(%{name: "Other Pharmacy"})
        |> Repo.insert!()

      other_location =
        %Requisition.Location{}
        |> Requisition.Location.changeset(%{
          latitude: "2",
          longitude: "2",
          pharmacy_id: other_pharmacy.id
        })
        |> Repo.insert!()

      %{
        location_id: location.id,
        patient_id: patient.id,
        prescription_id: prescription.id,
        other_location_id: other_location.id,
        conn: assign(conn, :user, %{id: pharmacy.id, name: "test user"})
      }
    end

    test "with valid existing data, creates an order", %{conn: conn} = context do
      assert Repo.aggregate(Requisition.Order, :count, :id) == 0
      resp_conn = post(conn, "/user/create_order", valid_existing_params(context))
      assert html_response(resp_conn, 302)
      assert get_resp_header(resp_conn, "location") == ["/user/create_order"]
      assert Repo.aggregate(Requisition.Order, :count, :id) == 1
    end

    test "errors if the user is not associated to the location", %{conn: conn} = context do
      resp_conn = post(conn, "/user/create_order", user_location_mismatch_params(context))
      assert html_response(resp_conn, 200) =~ "something went wrong"
      assert Repo.aggregate(Requisition.Order, :count, :id) == 0
    end

    test "errors if the data is invalid", %{conn: conn} = context do
      resp_conn = post(conn, "/user/create_order", invalid_existing_params(context))
      assert html_response(resp_conn, 200) =~ "something went wrong"
      assert Repo.aggregate(Requisition.Order, :count, :id) == 0
    end
  end

  defp valid_existing_params(context) do
    %{
      "order" => %{
        "location_id" => context.location_id,
        "patient_id" => context.patient_id,
        "prescription_id" => context.prescription_id
      }
    }
  end

  defp user_location_mismatch_params(context) do
    context
    |> valid_existing_params()
    |> put_in(["order", "location_id"], context.other_location_id)
  end

  defp invalid_existing_params(context) do
    context
    |> valid_existing_params()
    |> update_in(["order", "prescription_id"], &(&1 + 9000))
  end
end
