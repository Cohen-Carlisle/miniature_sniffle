defmodule MiniatureSniffle.AccountTest do
  use MiniatureSniffle.DataCase
  alias MiniatureSniffle.Account
  alias MiniatureSniffle.Account.Pharmacy

  describe "pharmacies" do
    @valid_attrs %{name: "Valid Pharmacy"}

    def pharmacy_fixture(attrs) do
      %Pharmacy{}
      |> Pharmacy.changeset(attrs)
      |> Repo.insert!()
    end

    test "get_pharmacy/1 returns the pharmacy with given name" do
      pharmacy = pharmacy_fixture(@valid_attrs)
      assert Account.get_pharmacy(@valid_attrs.name) == pharmacy
    end

    test "get_pharmacy/1 returns nil if no pharmacy found" do
      assert Account.get_pharmacy("nope") == nil
    end
  end
end
