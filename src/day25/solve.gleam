import adglent.{First, Second}
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string

const width = 5

const height = 7

fn parse(input: String) -> #(List(List(Int)), List(List(Int))) {
  let schematics = input |> string.split("\n\n")
  let locks =
    schematics
    |> list.filter(string.starts_with(_, "#"))
    |> list.map(fn(lock) { lock |> string.split("\n") |> from_schematic() })
  let keys =
    schematics
    |> list.filter(string.starts_with(_, "."))
    |> list.map(fn(key) {
      key
      |> string.split("\n")
      |> list.reverse()
      |> from_schematic()
    })
  #(locks, keys)
}

fn from_schematic(schematic: List(String)) -> List(Int) {
  use <- bool.lazy_guard(
    when: schematic |> list.length() == height,
    otherwise: fn() { panic },
  )
  schematic
  |> list.index_fold(list.repeat(option.None, width), fn(lock, line, ix) {
    line
    |> string.to_graphemes()
    |> list.map2(lock, fn(char, col) {
      case char {
        "#" -> option.Some(ix)
        "." -> col
        _ -> panic
      }
    })
  })
  |> list.map(option.unwrap(_, 0))
}

pub fn part1(input: String) {
  let #(locks, keys) = input |> parse()
  locks
  |> list.map(fn(lock) {
    keys
    |> list.count(fn(key) {
      use #(l, k) <- list.all(list.zip(lock, key))
      l + k < height - 1
    })
  })
  |> list.fold(0, int.add)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("25")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second -> panic
  }
}
