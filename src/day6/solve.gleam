import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{Next}

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
      let size = Pos(int.max(size.x, x + 1), int.max(size.y, y + 1))
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
  obstacles
  |> moves(from: #(guard, Up))
  |> yielder.map(fn(x) { x.0 })
  |> yielder.take_while(is_inside(_, size))
  |> yielder.fold(set.new(), set.insert)
  |> set.size()
}

pub fn part2(input: String) {
  let assert #(size, Some(guard), obstacles) = input |> parse()
  let initial = #(guard, Up)
  obstacles
  |> moves(from: initial)
  |> yielder.take_while(fn(vec) { vec.0 |> is_inside(size) })
  |> yielder.filter_map(fn(vec) {
    let assert Ok(#(obstacle, _)) =
      obstacles |> moves(from: vec) |> yielder.at(1)
    obstacles
    |> set.insert(obstacle)
    |> moves(from: initial)
    |> yielder.take_while(fn(vec) { vec.0 |> is_inside(size) })
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
  obstacles: Set(Pos),
  from initial: #(Pos, Direction),
) -> yielder.Yielder(#(Pos, Direction)) {
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

fn move(p: Pos, d: Direction) -> Pos {
  case d {
    Up -> Pos(p.x - 1, p.y)
    Left -> Pos(p.x, p.y - 1)
    Down -> Pos(p.x + 1, p.y)
    Right -> Pos(p.x, p.y + 1)
  }
}

fn is_inside(p: Pos, size: Pos) {
  p.x >= 0 && p.y >= 0 && p.x < size.x && p.y < size.y
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
