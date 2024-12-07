import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string
import gleam/yielder

pub type Pos {
  Pos(x: Int, y: Int)
}

pub fn parse(input: String) -> #(Pos, Option(Pos), Set(Pos)) {
  input
  |> string.split("\n")
  |> list.index_fold(#(Pos(0, 0), None, set.new()), fn(acc, line, x) {
    line
    |> string.to_graphemes()
    |> list.index_fold(acc, fn(acc, c, y) {
      let #(size, guard, obstacles) = acc
      let size = Pos(int.max(size.x, x), int.max(size.y, y))
      case c {
        "#" -> #(size, guard, obstacles |> set.insert(Pos(x, y)))
        "^" -> #(size, Some(Pos(x, y)), obstacles)
        _ -> #(size, guard, obstacles)
      }
    })
  })
}

pub fn part1(input: String) {
  let assert #(size, Some(guard), obstacles) = input |> parse()
  let assert Ok(#(_, _, visited)) =
    moves(guard, obstacles)
    |> yielder.find(fn(acc) {
      let #(guard, _, _) = acc
      guard.x < 0 || guard.y < 0 || guard.x >= size.x || guard.y >= size.y
    })
  visited |> set.size()
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

fn moves(guard: Pos, obstacles: Set(Pos)) {
  use #(guard, direction, visited) <- yielder.iterate(#(guard, Up, set.new()))
  let assert Ok(#(guard, direction)) =
    yielder.iterate(direction, turn_right)
    |> yielder.find_map(fn(d) {
      let next = guard |> move(d)
      case obstacles |> set.contains(next) {
        True -> Error(Nil)
        False -> Ok(#(next, d))
      }
    })
  #(guard, direction, visited |> set.insert(guard))
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

fn move(p: Pos, d: Direction) -> Pos {
  case d {
    Up -> Pos(p.x - 1, p.y)
    Left -> Pos(p.x, p.y - 1)
    Down -> Pos(p.x + 1, p.y)
    Right -> Pos(p.x, p.y + 1)
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
