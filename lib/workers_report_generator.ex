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
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
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
