defmodule MiniatureSniffleWeb.ControllerHelper do
  def atomize_params(params, keys) do
    Enum.into(keys, %{}, fn
      key when is_atom(key) -> {key, params[Atom.to_string(key)]}
      key when is_binary(key) -> {String.to_atom(key), params[key]}
    end)
  end
end
