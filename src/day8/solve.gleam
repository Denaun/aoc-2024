import adglent.{First, Second}
import coord.{type Coord, Coord}
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option
import gleam/yielder
import parse_util

fn parse(input: String) -> #(Coord, Dict(String, List(Coord))) {
  input
  |> parse_util.parse_map(#(coord.origin(), dict.new()), fn(acc, c, coord) {
    let #(size, antennas) = acc
    let size = size |> coord.max(coord.new(coord.x + 1, coord.y + 1))
    case c {
      "." -> #(size, antennas)
      _ -> #(
        size,
        antennas
          |> dict.upsert(c, fn(coords) {
            coords
            |> option.map(list.prepend(_, coord))
            |> option.unwrap([coord])
          }),
      )
    }
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
  let #(size, antennas) = input |> parse()
  antennas
  |> dict.values()
  |> list.flat_map(list.combination_pairs)
  |> list.flat_map(fn(pair) {
    let #(a, b) = pair
    let from_a =
      yielder.iterate(a, coord.add(_, a |> coord.subtract(b)))
      |> yielder.take_while(coord.is_inside(_, size))
    let from_b =
      yielder.iterate(b, coord.add(_, b |> coord.subtract(a)))
      |> yielder.take_while(coord.is_inside(_, size))
    from_a |> yielder.append(from_b) |> yielder.to_list()
  })
  |> list.unique()
  |> list.length()
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
