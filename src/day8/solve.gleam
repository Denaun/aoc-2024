import adglent.{First, Second}
import coord.{type Coord, Coord}
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option
import gleam/string

fn parse(input: String) -> #(Coord, Dict(String, List(Coord))) {
  input
  |> string.split("\n")
  |> list.index_fold(#(coord.origin(), dict.new()), fn(acc, line, x) {
    line
    |> string.to_graphemes()
    |> list.index_fold(acc, fn(acc, c, y) {
      let #(size, antennas) = acc
      let size = size |> coord.max(coord.new(x + 1, y + 1))
      case c {
        "." -> #(size, antennas)
        _ -> #(
          size,
          antennas
            |> dict.upsert(c, fn(coords) {
              let new = coord.new(x, y)
              coords
              |> option.map(list.prepend(_, new))
              |> option.unwrap([new])
            }),
        )
      }
    })
  })
}

pub fn part1(input: String) {
  let #(size, antennas) = input |> parse()
  antennas
  |> dict.values()
  |> list.flat_map(list.combination_pairs)
  |> list.flat_map(fn(pair) {
    let #(a, b) = pair
    [
      a |> coord.add(a) |> coord.subtract(b),
      b |> coord.add(b) |> coord.subtract(a),
    ]
  })
  |> list.filter(coord.is_inside(_, size))
  |> list.unique()
  |> list.length()
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("8")
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
