import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/yielder

pub fn part1(input: String) {
  let assert Ok(secrets) =
    input |> string.split("\n") |> list.try_map(int.parse)
  let assert Ok(secrets) =
    secrets
    |> list.map(yielder.iterate(_, fn(secret) {
      secret |> step1() |> step2() |> step3()
    }))
    |> list.try_map(yielder.at(_, 2000))
  secrets
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
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
