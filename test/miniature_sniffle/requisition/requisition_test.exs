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

      %{
        pharmacy_id: pharmacy.id,
        location_id: location.id,
        patient_id: patient.id,
        prescription_id: prescription.id
      }
    end

    test "create_order/1 with valid data creates a order", context do
      valid_params = Map.take(context, [:location_id, :patient_id, :prescription_id])

      assert {:ok, %Order{} = order} = Requisition.create_order(valid_params)
    end

    test "create_order/1 with invalid data returns error changeset", context do
      valid_params = Map.take(context, [:location_id, :patient_id, :prescription_id])
      invalid_params = Enum.into(valid_params, %{}, fn {col, id} -> {col, id + 1} end)

      assert {:error, %Ecto.Changeset{}} = Requisition.create_order(invalid_params)
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

    test "check_user_location_assoc/2 returns :ok if user and location associated", context do
      assert :ok ==
               Requisition.check_user_location_assoc(context.pharmacy_id, context.location_id)
    end

    test "check_user_location_assoc/2 errors if user and location not associated", context do
      assert {:error, :user_and_location_not_associated} ==
               Requisition.check_user_location_assoc(context.pharmacy_id, context.location_id + 1)
    end
  end
end
