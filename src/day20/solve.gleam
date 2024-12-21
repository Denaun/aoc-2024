import adglent.{First, Second}
import coord.{type Coord}
import gleam/bool
import gleam/dict
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/set.{type Set}
import parse_util

fn parse(input: String) -> #(Coord, Coord, Set(Coord)) {
  let assert #(option.Some(start), option.Some(end), walls) =
    input
    |> parse_util.parse_map(
      #(option.None, option.None, set.new()),
      fn(acc, c, coord) {
        let #(start, end, walls) = acc
        case c {
          "S" -> #(option.Some(coord), end, walls)
          "E" -> #(start, option.Some(coord), walls)
          "#" -> #(start, end, walls |> set.insert(coord))
          _ -> acc
        }
      },
    )
  #(start, end, walls)
}

pub fn part1(input: String, at_least threshold: Int) {
  let #(start, end, walls) =
    input
    |> parse()
  let costs =
    walls
    |> find_path(start, end)
    |> list.index_map(pair.new)
    |> dict.from_list()
  costs
  |> dict.keys()
  |> list.flat_map(shortcuts(_, costs))
  |> list.count(fn(cost) { cost >= threshold })
}

pub fn part2(input: String, at_least threshold: Int) {
  let #(start, end, walls) =
    input
    |> parse()
  walls
  |> find_path(start, end)
  |> list.index_map(pair.new)
  |> list.combination_pairs()
  |> list.filter_map(fn(pair) {
    let #(#(p0, c0), #(p1, c1)) = pair
    case coord.l1_distance(p0, p1) {
      d if d > 20 -> Error(Nil)
      d -> Ok(c1 - c0 - d)
    }
  })
  |> list.count(fn(cost) { cost >= threshold })
}

fn find_path(walls, start, end) {
  use <- bool.guard(when: start == end, return: [start])
  let assert Ok(next) =
    start |> neighbors |> list.find(fn(n) { !{ walls |> set.contains(n) } })
  [start, ..do_find_path(walls, next, end, start)]
}

fn do_find_path(walls, from, to, prev) {
  use <- bool.guard(when: from == to, return: [from])
  let assert Ok(next) =
    from
    |> neighbors()
    |> list.find(fn(n) { n != prev && !{ walls |> set.contains(n) } })
  [from, ..do_find_path(walls, next, to, from)]
}

fn shortcuts(from, costs) {
  let assert Ok(base) = costs |> dict.get(from)
  from
  |> step_neighbors()
  |> list.filter_map(fn(n) {
    case costs |> dict.get(n) {
      Ok(c) -> Ok(c - base - 2)
      _ -> Error(Nil)
    }
  })
}

fn neighbors(c: Coord) -> List(Coord) {
  [coord.new(-1, 0), coord.new(1, 0), coord.new(0, -1), coord.new(0, 1)]
  |> list.map(coord.add(c, _))
}

fn step_neighbors(c: Coord) -> List(Coord) {
  [
    coord.new(-2, 0),
    coord.new(-1, -1),
    coord.new(-1, 1),
    coord.new(0, -2),
    coord.new(2, 0),
    coord.new(1, -1),
    coord.new(1, 1),
    coord.new(0, 2),
  ]
  |> list.map(coord.add(c, _))
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("20")
  case part {
    First ->
      part1(input, at_least: 100)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input, at_least: 100)
      |> adglent.inspect
      |> io.println
  }
}
