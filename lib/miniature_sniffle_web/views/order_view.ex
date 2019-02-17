defmodule MiniatureSniffleWeb.OrderView do
  use MiniatureSniffleWeb, :view

  def or_create_new(type, [{_, nil}]) do
    "Create a new #{type} below."
  end

  def or_create_new(type, _options) do
    "...or create a new #{type} below."
  end
end
