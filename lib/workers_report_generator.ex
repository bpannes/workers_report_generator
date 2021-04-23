defmodule WorkersReportGenerator do
  alias WorkersReportGenerator.Parser

  @workers [
    :cleiton,
    :daniele,
    :danilo,
    :diego,
    :giuliano,
    :jakeliny,
    :joseph,
    :mayk,
    :rafael,
    :vinicius
  ]

  @months [
    :janeiro,
    :fevereiro,
    :março,
    :abril,
    :maio,
    :junho,
    :julho,
    :agosto,
    :setembro,
    :outubro,
    :novembro,
    :dezembro
  ]

  @years [
    :"2016",
    :"2017",
    :"2018",
    :"2019",
    :"2020"
  ]

  def build(filename) do
    result =
      filename
      |> Parser.parse_file()
      |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please provide a list of strings"}
  end

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(result, report) end)

    {:ok, result}
  end

  defp sum_values(
         [woker, worked_hours, _day, month, year],
         %{
           all_hours: all_hours,
           hours_per_month: hours_per_month,
           hours_per_year: hours_per_year
         }
       ) do
    all_hours = Map.put(all_hours, woker, all_hours[woker] + worked_hours)

    hours_per_month =
      put_in(hours_per_month, [woker, month], hours_per_month[woker][month] + worked_hours)

    hours_per_year =
      put_in(hours_per_year, [woker, year], hours_per_year[woker][year] + worked_hours)

    %{all_hours: all_hours, hours_per_month: hours_per_month, hours_per_year: hours_per_year}
  end

  defp sum_reports(
         %{
           all_hours: all_hours_1,
           hours_per_month: hours_per_month_1,
           hours_per_year: hours_per_year_1
         },
         %{
           all_hours: all_hours_2,
           hours_per_month: hours_per_month_2,
           hours_per_year: hours_per_year_2
         }
       ) do
    all_hours = merge_maps(all_hours_1, all_hours_2)
    hours_per_month = merge_second_layer_maps(hours_per_month_1, hours_per_month_2)
    hours_per_year = merge_second_layer_maps(hours_per_year_1, hours_per_year_2)

    %{all_hours: all_hours, hours_per_month: hours_per_month, hours_per_year: hours_per_year}
  end

  defp merge_maps(map_1, map_2) do
    Map.merge(map_1, map_2, fn _key, value_1, value_2 -> value_1 + value_2 end)
  end

  defp merge_second_layer_maps(map_1, map_2) do
    Map.merge(map_1, map_2, fn _key, value_1, value_2 -> merge_maps(value_1, value_2) end)
  end

  def report_acc() do
    all_hours = map_creator(0, @workers)

    hours_per_month =
      map_creator(0, @months)
      |> map_creator(@workers)

    hours_per_year =
      map_creator(0, @years)
      |> map_creator(@workers)

    %{all_hours: all_hours, hours_per_month: hours_per_month, hours_per_year: hours_per_year}
  end

  defp map_creator(value, key) do
    Enum.into(key, %{}, &{&1, value})
  end
end
