defmodule OP do
  use Bitwise, only_operators: true

  def trim(list), do: Enum.drop_while(list, &(&1 === 0))

  def extend_r(list, n) when length(list) < n, do: extend_r(list ++ [0], n)
  def extend_r(list, _), do: list

  def extend_l(list, n) when length(list) < n, do: extend_l([0 | list], n)
  def extend_l(list, _), do: list

  def begin_xor(a, b) do
    b = extend_r(b, length(a))
    Enum.map(Enum.zip(a, b), fn {a, b} -> a ^^^ b end)
  end

  def end_xor(a, b) do
    b = extend_l(b, length(a))
    Enum.map(Enum.zip(a, b), fn {a, b} -> a ^^^ b end)
  end


  def division(a, b, max_len) when hd(a) == 0 and length(a) > 0,
    do: division(trim(a), b, max_len)
  def division(a, b, max_len) when length(a) > max_len,
    do: division(begin_xor(a, b), b, max_len)
  def division(a, _, max_len),
    do: extend_l(a, max_len)

  def is_null(list), do: Enum.any?(list, &(&1 == 1))

  def bit_count(a, code_len), do: do_bit_count(a, code_len, code_len - 1)
  defp do_bit_count(_, _, -1), do: 0
  defp do_bit_count(a, code_len, i) when ((a >>> i) &&& 1) === 1,
    do: 1 + do_bit_count(a, code_len, i - 1)
  defp do_bit_count(a, code_len, i),
    do: do_bit_count(a, code_len, i - 1)

  def int_xor(a, err), do: begin_xor(a, Integer.digits(err, 2))
end

defmodule Stat do
  defstruct count: 0, right: 0

  def add_value(%Stat{count: count, right: right}, input, err, poly, extra_len) do
    is_left = input
      |> OP.int_xor(err)
      |> OP.division(poly, extra_len)
      |> OP.is_null
    if is_left do
      %Stat{count: count + 1, right: right + 1}
    else
      %Stat{count: count + 1, right: right}
    end
  end

  def generate(list, 0, _, _, _, _), do: list
  def generate(list, range, input, poly, code_len, extra_len) do
    range = range - 1
    list_value = list
      |> Enum.at(OP.bit_count(range, code_len))
      |> add_value(input, range, poly, extra_len)
    list
    |> List.replace_at(OP.bit_count(range, code_len), list_value)
    |> generate(range, input, poly, code_len, extra_len)
  end
end

defmodule Main do
  use Bitwise, only_operators: true
  def run do
    # Set variables
    input = Integer.digits(1011010001)
    poly = Integer.digits(10011)

    code_len = 15
    value_len = length input
    extra_len = code_len - value_len

    # Script
    input = OP.extend_r(input, length(input) + extra_len)
    extra = OP.division(input, poly, extra_len)
    input = OP.end_xor(input, extra)
    IO.puts Integer.undigits(input)

    stat_list = for _ <- 0..code_len, do: %Stat{}
    stat_list = Stat.generate(stat_list, 1 <<< code_len, input, poly, code_len, extra_len)

    IO.puts "Кратность|Всего|Обнаружено|  %"
    Enum.each(Enum.zip(1..length(stat_list), Enum.slice(stat_list, 1..length(stat_list))), fn {i, s} ->
      IO.puts(String.rjust(Integer.to_string(i), 9) <> "|" <>
              String.rjust(Integer.to_string(s.count), 5) <> "|" <>
              String.rjust(Integer.to_string(s.right), 10) <> "|" <>
              String.rjust(Float.to_string(s.right / s.count * 100, [decimals: 2]), 6))
    end)
  end
end

Main.run
