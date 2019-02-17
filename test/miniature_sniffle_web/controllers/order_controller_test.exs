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

    test "creates an order and new associated valid data", %{conn: conn} do
      assert Repo.aggregate(Requisition.Order, :count, :id) == 0
      assert Repo.get_by(Requisition.Location, latitude: "3") == nil
      assert Repo.get_by(Requisition.Patient, first_name: "Stephanie") == nil
      assert Repo.get_by(Requisition.Prescription, name: "Melange") == nil

      resp_conn = post(conn, "/user/create_order", valid_new_params())
      assert html_response(resp_conn, 302)
      assert get_resp_header(resp_conn, "location") == ["/user/create_order"]

      assert Repo.aggregate(Requisition.Order, :count, :id) == 1
      assert %Requisition.Location{} = Repo.get_by(Requisition.Location, latitude: "3")
      assert %Requisition.Patient{} = Repo.get_by(Requisition.Patient, first_name: "Stephanie")
      assert %Requisition.Prescription{} = Repo.get_by(Requisition.Prescription, name: "Melange")
    end

    test "does not create an order nor associated data if any data is invalid", %{conn: conn} do
      location_precount = Repo.aggregate(Requisition.Location, :count, :id)
      patient_precount = Repo.aggregate(Requisition.Patient, :count, :id)
      prescription_precount = Repo.aggregate(Requisition.Prescription, :count, :id)

      resp_conn = post(conn, "/user/create_order", invalid_new_params())
      assert html_response(resp_conn, 200) =~ "something went wrong"

      assert Repo.aggregate(Requisition.Order, :count, :id) == 0
      assert Repo.aggregate(Requisition.Location, :count, :id) == location_precount
      assert Repo.aggregate(Requisition.Patient, :count, :id) == patient_precount
      assert Repo.aggregate(Requisition.Prescription, :count, :id) == prescription_precount
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

    defp valid_new_params do
      # as you can see, its all bundled up together without namespacing
      # but we get error_tag in the templates for free this way
      %{
        "order" => %{
          "latitude" => "3",
          "longitude" => "3",
          "first_name" => "Stephanie",
          "last_name" => "Carlisle",
          "name" => "Melange"
        }
      }
    end

    defp invalid_new_params do
      put_in(valid_new_params(), ["order", "name"], "")
    end
  end
end
