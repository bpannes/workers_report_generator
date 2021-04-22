defmodule WorkersReportGenerator.Parser do
  def parse_file(filename) do
    "reports/#{filename}"
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> List.update_at(0, &String.downcase/1)
    |> List.update_at(1, &String.to_integer/1)
    |> List.update_at(3, &number_to_month/1)
    |> List.update_at(0, &String.to_atom/1)
    |> List.update_at(3, &String.to_atom/1)
    |> List.update_at(4, &String.to_atom/1)
  end

  defp number_to_month(_number = "1"), do: "janeiro"
  defp number_to_month(_number = "2"), do: "fevereiro"
  defp number_to_month(_number = "3"), do: "março"
  defp number_to_month(_number = "4"), do: "abril"
  defp number_to_month(_number = "5"), do: "maio"
  defp number_to_month(_number = "6"), do: "junho"
  defp number_to_month(_number = "7"), do: "julho"
  defp number_to_month(_number = "8"), do: "agosto"
  defp number_to_month(_number = "9"), do: "setembro"
  defp number_to_month(_number = "10"), do: "outubro"
  defp number_to_month(_number = "11"), do: "novembro"
  defp number_to_month(_number = "12"), do: "dezembro"
end
