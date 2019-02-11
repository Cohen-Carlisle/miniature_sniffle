# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MiniatureSniffle.Repo.insert!(%MiniatureSniffle.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MiniatureSniffle.Repo
alias MiniatureSniffle.{Account, Requisition}

pharmacy1 =
  %Account.Pharmacy{}
  |> Account.Pharmacy.changeset(%{name: "Alfa Pharmacy"})
  |> Repo.insert!()

pharmacy2 =
  %Account.Pharmacy{}
  |> Account.Pharmacy.changeset(%{name: "Bravo Pharmacy"})
  |> Repo.insert!()

%Requisition.Location{}
|> Requisition.Location.changeset(%{latitude: "39.9612", longitude: "82.9988", pharmacy_id: pharmacy1.id})
|> Repo.insert!()

%Requisition.Location{}
|> Requisition.Location.changeset(%{latitude: "40.9612", longitude: "72.9988", pharmacy_id: pharmacy2.id})
|> Repo.insert!()

%Requisition.Patient{}
|> Requisition.Patient.changeset(%{first_name: "First", last_name: "User"})
|> Repo.insert!()

%Requisition.Patient{}
|> Requisition.Patient.changeset(%{first_name: "Second", last_name: "User"})
|> Repo.insert!()

%Requisition.Prescription{}
|> Requisition.Prescription.changeset(%{name: "Allegra"})
|> Repo.insert!()

%Requisition.Prescription{}
|> Requisition.Prescription.changeset(%{name: "Rolaids"})
|> Repo.insert!()
