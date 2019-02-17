defmodule MiniatureSniffleWeb.OrderViewTest do
  use MiniatureSniffleWeb.ConnCase, async: true
  alias MiniatureSniffleWeb.OrderView

  describe "or_create_new/2" do
    test "returns appropriate copy when there are no existing options" do
      assert OrderView.or_create_new(:test, [{"We got nothin'.", nil}]) ==
               "Create a new test below."
    end

    test "returns appropriate copy when there are existing options" do
      assert OrderView.or_create_new(:test, [{"test1", 1}, {"test2", 2}]) ==
               "...or create a new test below."
    end
  end
end
