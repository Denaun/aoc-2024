import adglent.{First, Second}
import coord.{type Coord}
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/yielder.{Next}
import parse_util

pub fn parse(input: String) -> #(Coord, Option(Coord), Set(Coord)) {
  input
  |> parse_util.parse_map(#(coord.origin(), None, set.new()), fn(acc, c, coord) {
    let #(size, guard, obstacles) = acc
    let size = size |> coord.max(coord.new(coord.x + 1, coord.y + 1))
    case c {
      "#" -> #(size, guard, obstacles |> set.insert(coord))
      "^" -> #(size, Some(coord), obstacles)
      _ -> #(size, guard, obstacles)
    }
  })
}

pub fn part1(input: String) {
  let assert #(size, Some(guard), obstacles) = input |> parse()
  obstacles
  |> moves(from: #(guard, Up))
  |> yielder.map(fn(x) { x.0 })
  |> yielder.take_while(coord.is_inside(_, size))
  |> yielder.fold(set.new(), set.insert)
  |> set.size()
}

pub fn part2(input: String) {
  let assert #(size, Some(guard), obstacles) = input |> parse()
  let initial = #(guard, Up)
  obstacles
  |> moves(from: initial)
  |> yielder.take_while(fn(vec) { vec.0 |> coord.is_inside(size) })
  |> yielder.filter_map(fn(vec) {
    let assert Ok(#(obstacle, _)) =
      obstacles |> moves(from: vec) |> yielder.at(1)
    obstacles
    |> set.insert(obstacle)
    |> moves(from: initial)
    |> yielder.take_while(fn(vec) { vec.0 |> coord.is_inside(size) })
    |> yielder.transform(set.new(), fn(visited, vec) {
      Next(visited |> set.contains(vec), visited |> set.insert(vec))
    })
    |> yielder.find(fn(is_loop) { is_loop })
    |> result.replace(obstacle)
  })
  |> yielder.fold(set.new(), set.insert)
  |> set.delete(guard)
  |> set.size()
}

fn moves(
  obstacles: Set(Coord),
  from initial: #(Coord, Direction),
) -> yielder.Yielder(#(Coord, Direction)) {
  use #(guard, direction) <- yielder.iterate(initial)
  let assert Ok(next) =
    yielder.iterate(direction, turn_right)
    |> yielder.find_map(fn(d) {
      let next = guard |> move(d)
      case obstacles |> set.contains(next) {
        True -> Error(Nil)
        False -> Ok(#(next, d))
      }
    })
  next
}

type Direction {
  Up
  Left
  Down
  Right
}

fn turn_right(from: Direction) -> Direction {
  case from {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn move(p: Coord, d: Direction) -> Coord {
  case d {
    Up -> coord.new(p.x - 1, p.y)
    Left -> coord.new(p.x, p.y - 1)
    Down -> coord.new(p.x + 1, p.y)
    Right -> coord.new(p.x, p.y + 1)
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("6")
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
