defmodule MiniatureSniffle.Requisition do
  @moduledoc """
  The Requisition context.
  """

  import Ecto.Query, warn: false
  alias MiniatureSniffle.Repo
  alias MiniatureSniffle.Requisition.{Location, Order, Patient, Prescription}

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  def create_order2(params, user_id) do
    Repo.transaction(fn ->
      with {:ok, maybe_location} <- maybe_insert_location(params.location, user_id),
           {:ok, maybe_patient} <- maybe_insert_patient(params.patient),
           {:ok, maybe_prescription} <- maybe_insert_prescription(params.prescription),
           {:ok, order} <-
             insert_order(params, maybe_location, maybe_patient, maybe_prescription),
           :ok <- check_user_location_assoc2(maybe_location, user_id, order.location_id) do
        order
      else
        {:error, %{errors: errors}} -> Repo.rollback(errors)
      end
    end)
  end

  def order_select_options(pharmacy_id) do
    # shouldn't just grab all patients (hipaa lol), but they aren't currently associated to a pharmcy
    %{
      locations: Location |> where(pharmacy_id: ^pharmacy_id) |> Repo.all() |> to_select_opts(),
      patients: Patient |> Repo.all() |> to_select_opts(),
      prescriptions: Prescription |> Repo.all() |> to_select_opts()
    }
  end

  def check_user_location_assoc(pharmacy_id, location_id) do
    check =
      Location
      |> where(pharmacy_id: ^pharmacy_id, id: ^location_id)
      |> Repo.exists?()

    (check && :ok) || {:error, :user_and_location_not_associated}
  end

  defp maybe_insert_location(%{id: _id}, _user_id) do
    {:ok, :noop}
  end

  defp maybe_insert_location(params, pharmacy_id) do
    %Location{}
    |> Location.changeset(Map.merge(params, %{pharmacy_id: pharmacy_id}))
    |> Repo.insert()
  end

  defp maybe_insert_patient(%{id: _id}) do
    {:ok, :noop}
  end

  defp maybe_insert_patient(params) do
    %Patient{}
    |> Patient.changeset(params)
    |> Repo.insert()
  end

  defp maybe_insert_prescription(%{id: _id}) do
    {:ok, :noop}
  end

  defp maybe_insert_prescription(params) do
    %Prescription{}
    |> Prescription.changeset(params)
    |> Repo.insert()
  end

  defp insert_order(params, maybe_location, maybe_patient, maybe_prescription) do
    %Order{}
    |> Order.changeset(%{
      location_id: location_id(params.location, maybe_location),
      patient_id: patient_id(params.patient, maybe_patient),
      prescription_id: prescription_id(params.prescription, maybe_prescription)
    })
    |> Repo.insert()
  end

  defp location_id(%{id: id}, :noop), do: id
  defp location_id(_params, %{id: id}), do: id

  defp patient_id(%{id: id}, :noop), do: id
  defp patient_id(_params, %{id: id}), do: id

  defp prescription_id(%{id: id}, :noop), do: id
  defp prescription_id(_params, %{id: id}), do: id

  defp check_user_location_assoc2(maybe_location, pharmacy_id, location_id) do
    # only need to check if we didn't just create the location
    if maybe_location == :noop do
      check =
        Location
        |> where(pharmacy_id: ^pharmacy_id, id: ^location_id)
        |> Repo.exists?()

      if check do
        :ok
      else
        # format 2nd tuple element like changeset errors
        {:error, %{errors: [location: {"not associated to pharmacy", []}]}}
      end
    else
      :ok
    end
  end

  defp to_select_opts([]) do
    [{"No existing data.", nil}]
  end

  defp to_select_opts([%Location{} | _] = list) do
    list
    |> Enum.map(&{"#{&1.latitude}, #{&1.longitude}", &1.id})
    |> List.insert_at(0, {"Choose an existing location...", nil})
  end

  defp to_select_opts([%Patient{} | _] = list) do
    list
    |> Enum.map(&{"#{&1.last_name}, #{&1.first_name}", &1.id})
    |> List.insert_at(0, {"Choose an existing patient...", nil})
  end

  defp to_select_opts([%Prescription{} | _] = list) do
    list
    |> Enum.map(&{&1.name, &1.id})
    |> List.insert_at(0, {"Choose an existing prescription...", nil})
  end
end
