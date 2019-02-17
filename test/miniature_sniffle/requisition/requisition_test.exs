defmodule MiniatureSniffle.RequisitionTest do
  use MiniatureSniffle.DataCase
  alias MiniatureSniffle.{Account, Requisition}

  describe "orders" do
    alias MiniatureSniffle.Requisition.Order

    setup do
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
        pharmacy_id: pharmacy.id,
        location_id: location.id,
        patient_id: patient.id,
        prescription_id: prescription.id,
        other_location_id: other_location.id
      }
    end

    test "create_order/2 persists an order from valid pre-existing data", context do
      assert Repo.aggregate(Requisition.Order, :count, :id) == 0

      assert {:ok, order} =
               Requisition.create_order(
                 %{
                   location: %{id: context.location_id},
                   patient: %{id: context.patient_id},
                   prescription: %{id: context.prescription_id}
                 },
                 context.pharmacy_id
               )

      assert %Order{} = Repo.get(Order, order.id)
    end

    test "create_order/2 errors on an invalid foreign key", context do
      assert Repo.aggregate(Requisition.Order, :count, :id) == 0

      assert {:error, [location: {"does not exist", _}]} =
               Requisition.create_order(
                 %{
                   location: %{id: context.location_id + 9000},
                   patient: %{id: context.patient_id},
                   prescription: %{id: context.prescription_id}
                 },
                 context.pharmacy_id
               )

      assert Repo.aggregate(Requisition.Order, :count, :id) == 0
    end

    test "create_order/2 errors if the user not associated to the location", context do
      assert {:error, [location: {"not associated to pharmacy", _}]} =
               Requisition.create_order(
                 %{
                   location: %{id: context.other_location_id},
                   patient: %{id: context.patient_id},
                   prescription: %{id: context.prescription_id}
                 },
                 context.pharmacy_id
               )

      assert Repo.aggregate(Requisition.Order, :count, :id) == 0
    end

    test "create_order/2 persists an order and new associated valid data", context do
      assert Repo.aggregate(Requisition.Order, :count, :id) == 0
      assert Repo.get_by(Requisition.Location, latitude: "3") == nil
      assert Repo.get_by(Requisition.Patient, first_name: "Stephanie") == nil
      assert Repo.get_by(Requisition.Prescription, name: "Melange") == nil

      assert {:ok, order} =
               Requisition.create_order(
                 %{
                   location: %{latitude: "3", longitude: "3"},
                   patient: %{first_name: "Stephanie", last_name: "Carlisle"},
                   prescription: %{name: "Melange"}
                 },
                 context.pharmacy_id
               )

      assert %Order{} = Repo.get(Order, order.id)
      assert Repo.get(Requisition.Location, order.location_id).latitude == "3"
      assert Repo.get(Requisition.Patient, order.patient_id).first_name == "Stephanie"
      assert Repo.get(Requisition.Prescription, order.prescription_id).name == "Melange"
    end

    test "create_order/2 does not create any records if any data is invalid", context do
      assert {:error, [name: {"can't be blank", _}]} =
               Requisition.create_order(
                 %{
                   location: %{latitude: "3", longitude: "3"},
                   patient: %{first_name: "Stephanie", last_name: "Carlisle"},
                   prescription: %{name: ""}
                 },
                 context.pharmacy_id
               )

      assert Repo.aggregate(Requisition.Order, :count, :id) == 0
      assert Repo.get_by(Requisition.Location, latitude: "3") == nil
      assert Repo.get_by(Requisition.Patient, first_name: "Stephanie") == nil
      assert Repo.get_by(Requisition.Prescription, name: "") == nil
    end

    test "order_select_options/1 returns a map of select options for use in views", context do
      assert %{
               locations: [
                 {"Choose an existing location...", nil},
                 {"1, 1", context.location_id}
               ],
               patients: [
                 {"Choose an existing patient...", nil},
                 {"Carlisle, Cohen", context.patient_id}
               ],
               prescriptions: [
                 {"Choose an existing prescription...", nil},
                 {"Soma", context.prescription_id}
               ]
             } == Requisition.order_select_options(context.pharmacy_id)
    end

    test "order_select_options/1 handles if no options exist", context do
      Repo.delete!(Repo.get(Requisition.Patient, context.patient_id))

      assert [{"No existing data.", nil}] ==
               Requisition.order_select_options(context.pharmacy_id).patients
    end
  end
end
