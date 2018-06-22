defmodule Commies.RouteHelper do
  @base :commies |> Application.fetch_env!(__MODULE__) |> Keyword.fetch!(:base)

  @compile {:inline, append_base: 1}

  def append_base(path), do: @base <> path
end
