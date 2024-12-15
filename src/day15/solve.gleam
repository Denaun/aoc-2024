import adglent.{First, Second}
import coord.{type Coord}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string
import parse_util

type Day15 {
  Day15(
    robot: Coord,
    boxes: Set(Coord),
    walls: Set(Coord),
    moves: List(Direction),
  )
}

type Direction {
  Up
  Down
  Left
  Right
}

fn parse(input: String) -> Day15 {
  let assert [map, moves] = input |> string.split("\n\n")
  let assert #(Some(robot), boxes, walls) =
    map
    |> parse_util.parse_map(#(None, set.new(), set.new()), fn(acc, c, coord) {
      let #(robot, boxes, walls) = acc
      case c {
        "#" -> #(robot, boxes, walls |> set.insert(coord))
        "O" -> #(robot, boxes |> set.insert(coord), walls)
        "@" ->
          case robot {
            None -> #(Some(coord), boxes, walls)
            _ -> panic
          }
        _ -> acc
      }
    })
  let moves =
    moves
    |> string.replace("\n", "")
    |> string.to_graphemes()
    |> list.map(fn(c) {
      case c {
        "^" -> Up
        "v" -> Down
        "<" -> Left
        ">" -> Right
        _ -> panic
      }
    })
  Day15(robot, boxes, walls, moves)
}

pub fn part1(input: String) {
  let Day15(robot, boxes, walls, moves) = input |> parse()
  let #(_, boxes) =
    moves
    |> list.fold(#(robot, boxes), fn(acc, direction) {
      let #(robot, boxes) = acc
      let step = robot |> move(direction)
      case step |> try_move(direction, boxes, walls) {
        Ok(next) if next == step -> #(step, boxes)
        Ok(next) -> #(step, boxes |> set.delete(step) |> set.insert(next))
        Error(Nil) -> #(robot, boxes)
      }
    })
  boxes |> set.map(gps_coordinate) |> set.fold(0, int.add)
}

fn try_move(
  next: Coord,
  direction: Direction,
  boxes: Set(Coord),
  walls: Set(Coord),
) -> Result(Coord, Nil) {
  case walls |> set.contains(next), boxes |> set.contains(next) {
    True, _ -> Error(Nil)
    False, False -> Ok(next)
    False, True -> next |> move(direction) |> try_move(direction, boxes, walls)
  }
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

fn move(coord: Coord, direction: Direction) {
  case direction {
    Up -> coord.new(-1, 0)
    Down -> coord.new(1, 0)
    Left -> coord.new(0, -1)
    Right -> coord.new(0, 1)
  }
  |> coord.add(coord)
}

fn gps_coordinate(coord: Coord) {
  coord.y + 100 * coord.x
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("15")
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
