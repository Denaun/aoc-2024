import adglent.{First, Second}
import coord.{type Coord}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import parse_util

pub fn part1(input: String) {
  let height_by_coord =
    input
    |> parse_util.parse_map(dict.new(), fn(height_by_coord, c, coord) {
      let assert Ok(h) = c |> int.parse()
      height_by_coord |> dict.insert(coord, h)
    })
  height_by_coord
  |> dict.filter(fn(_, height) { height == 0 })
  |> dict.keys()
  |> list.flat_map(trail_ends(height_by_coord, _))
  |> list.length()
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

fn trail_ends(height_by_coord: Dict(Coord, Int), from c: Coord) {
  trail_ends_loop(height_by_coord, c, set.from_list([c])) |> list.unique()
}

fn trail_ends_loop(
  height_by_coord: Dict(Coord, Int),
  c: Coord,
  visited: Set(Coord),
) {
  case height_by_coord |> dict.get(c) {
    Ok(height) if height == 9 -> [c]
    Error(_) -> []
    Ok(height) ->
      [coord.new(-1, 0), coord.new(1, 0), coord.new(0, -1), coord.new(0, 1)]
      |> list.map(coord.add(c, _))
      |> list.filter(fn(c) { visited |> set.contains(c) |> bool.negate })
      |> list.flat_map(fn(next) {
        case height_by_coord |> dict.get(next) {
          Ok(h) if h == height + 1 ->
            height_by_coord
            |> trail_ends_loop(next, visited |> set.insert(next))
          _ -> []
        }
      })
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("10")
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
