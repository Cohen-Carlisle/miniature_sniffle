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

      %{location_id: location.id, patient_id: patient.id, prescription_id: prescription.id}
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
  end
end
