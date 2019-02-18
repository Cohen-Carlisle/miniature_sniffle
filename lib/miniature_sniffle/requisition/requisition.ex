defmodule MiniatureSniffle.Requisition do
  @moduledoc """
  The Requisition context.
  """

  import Ecto.Query, warn: false
  alias MiniatureSniffle.Repo
  alias MiniatureSniffle.Requisition.{Location, Order, Patient, Prescription}

  @doc """
  Creates an order, creating associated data structures if necessary.
  Returns {:ok, order} or {:error, errors}.
  May throw an exception from the database adapter.

  ## Examples

      iex> create_order(%{location: %{id: 1}, patient: %{id: 2}, prescription: %{name: "Rx"}}, 4)
      {:ok, %Order{location_id: 1, patient_id: 2, prescription_id: 3}}

      iex> create_order(%{location: %{id: 1}, patient: %{id: 2}, prescription: %{}}, 4)
      {:error, [name: {"can't be blank", [validation: :required]}]}

  """
  def create_order(params, user_id) do
    Repo.transaction(fn ->
      with {:ok, maybe_location} <- maybe_insert_location(params.location, user_id),
           {:ok, maybe_patient} <- maybe_insert_patient(params.patient),
           {:ok, maybe_prescription} <- maybe_insert_prescription(params.prescription),
           {:ok, order} <-
             insert_order(params, maybe_location, maybe_patient, maybe_prescription),
           :ok <- check_user_location_assoc(maybe_location, user_id, order.location_id) do
        order
      else
        {:error, %{errors: errors}} -> Repo.rollback(errors)
      end
    end)
  end

  @doc """
  Creates a list select options for use in views for a given pharmacy (by id).
  Returns map with keys :locations, :patients, :prescriptions with values in a
  format consumed by Phoenix.HTML.select/4, e.g., [{"label1", "value1"}, ...].
  A "prompt" is built in as the first element in each value.

  ## Examples

      iex> order_select_options(1).prescriptions
      [{"Choose an existing prescription...", nil}, {"Allegra", 1}, {"Rolaids", 2}]

      iex> order_select_options(2).locations
      [{"No existing data.", nil}]

  """
  def order_select_options(pharmacy_id) do
    # shouldn't just grab all patients (hipaa lol), but they aren't currently associated to a pharmcy
    %{
      locations: Location |> where(pharmacy_id: ^pharmacy_id) |> Repo.all() |> to_select_opts(),
      patients: Patient |> Repo.all() |> to_select_opts(),
      prescriptions: Prescription |> Repo.all() |> to_select_opts()
    }
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

  defp check_user_location_assoc(maybe_location, pharmacy_id, location_id) do
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
