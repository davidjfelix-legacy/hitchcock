defmodule Hitchcock.TestHelpers do
  @forbidden_keys [:__meta__, :inserted_at, :updated_at]

  def stringify_keys(record = %{__struct__: struct, __meta__: %{__struct__: Ecto.Schema.Metadata}}) do
    record
    |> Map.from_struct
    |> Map.drop(@forbidden_keys)
    |> Map.drop(struct.__schema__(:associations))
    |> Enum.reduce(%{}, fn ({key, value}, new_map) ->
      Map.put new_map, to_string(key), value
    end)
  end
end
