import adglent.{First, Second}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import gleam/yielder

pub fn part1(input: String) {
  let assert Ok(secrets) =
    input |> string.split("\n") |> list.try_map(int.parse)
  let assert Ok(secrets) =
    secrets
    |> list.map(yielder.iterate(_, next_secret))
    |> list.try_map(yielder.at(_, 2000))
  secrets
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  let assert Ok(secrets) =
    input |> string.split("\n") |> list.try_map(int.parse)
  let price_by_sequence_per_buyer =
    secrets
    |> list.map(fn(initial) {
      let prices =
        yielder.iterate(initial, next_secret)
        |> yielder.map(fn(v) { v % 10 })
        |> yielder.take(2001)
        |> yielder.to_list()
      prices
      |> list.window_by_2()
      |> list.map(fn(pair) { pair.1 - pair.0 })
      |> list.window(4)
      |> list.zip(prices |> list.drop(4))
      // dict.from_list keeps the last value, monkeys stop at the first one.
      |> list.reverse()
      |> dict.from_list()
    })
  let assert Ok(sequences) =
    price_by_sequence_per_buyer
    |> list.map(dict.keys)
    |> list.map(set.from_list)
    |> list.reduce(set.union)
    |> result.map(set.to_list)
  let assert Ok(bananas) =
    sequences
    |> list.map(fn(sequence) {
      price_by_sequence_per_buyer
      |> list.filter_map(dict.get(_, sequence))
      |> list.fold(0, int.add)
    })
    |> list.reduce(int.max)
  bananas
}

fn next_secret(v: Int) -> Int {
  v |> step1() |> step2() |> step3()
}

fn step1(v: Int) -> Int {
  v |> int.bitwise_shift_left(6) |> mix(v) |> prune()
}

fn step2(v: Int) -> Int {
  v |> int.bitwise_shift_right(5) |> mix(v) |> prune()
}

fn step3(v: Int) -> Int {
  v |> int.bitwise_shift_left(11) |> mix(v) |> prune()
}

fn mix(a: Int, b: Int) -> Int {
  int.bitwise_exclusive_or(a, b)
}

fn prune(v: Int) -> Int {
  int.bitwise_and(v, 16_777_216 - 1)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("22")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}
