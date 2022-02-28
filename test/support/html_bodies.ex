defmodule SMWCBot.HTMLBodies do
  @moduledoc """
  HTML page bodies.
  """

  def smwc_results(amount) do
    "./html/#{amount}-results.html"
    |> Path.expand(__DIR__)
    |> File.read!()
  end
end
