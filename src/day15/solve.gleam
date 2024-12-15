import adglent.{First, Second}
import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import parse_util

type Day15 {
  Part1(
    robot: Coord,
    boxes: Set(Coord),
    walls: Set(Coord),
    moves: List(Direction),
  )
  Part2(
    robot: Coord,
    boxes: Dict(Coord, Coord),
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
  Part1(robot, boxes, walls, moves)
}

fn expand(input: Day15) -> Day15 {
  let assert Part1(robot, boxes, walls, moves) = input
  let expand = fn(c: Coord) { coord.new(c.x, 2 * c.y) }
  let right = fn(c: Coord) { coord.new(c.x, c.y + 1) }
  let robot = expand(robot)
  let boxes =
    boxes
    |> set.to_list()
    |> list.flat_map(fn(box) {
      let left = box |> expand()
      let right = left |> right()
      [#(left, right), #(right, left)]
    })
    |> dict.from_list()
  let walls =
    walls
    |> set.to_list()
    |> list.flat_map(fn(wall) {
      let left = wall |> expand()
      [left, left |> right()]
    })
    |> set.from_list()
  Part2(robot, boxes, walls, moves)
}

pub fn part1(input: String) {
  let assert Part1(robot, boxes, walls, moves) = input |> parse()
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
  let assert Part2(robot, boxes, walls, moves) = input |> parse() |> expand()
  let #(_, boxes) =
    moves
    |> list.fold(#(robot, boxes), fn(acc, direction) {
      let #(robot, boxes) = acc
      let step = robot |> move(direction)
      case step |> try_push(direction, boxes, walls) {
        Ok(boxes) -> #(step, boxes)
        _ -> #(robot, boxes)
      }
    })
  boxes
  |> dict.filter(fn(k, v) { v == coord.new(k.x, k.y + 1) })
  |> dict.keys()
  |> list.map(gps_coordinate)
  |> list.fold(0, int.add)
}

fn try_push(
  coord: Coord,
  direction: Direction,
  boxes: Dict(Coord, Coord),
  walls: Set(Coord),
) -> Result(Dict(Coord, Coord), Nil) {
  case walls |> set.contains(coord), boxes |> dict.get(coord) {
    True, _ -> Error(Nil)
    _, Error(Nil) -> Ok(boxes)
    _, Ok(other) -> {
      let next = coord |> move(direction)
      let other_next = other |> move(direction)
      other_next
      |> try_push(direction, boxes, walls)
      |> result.then(fn(boxes) {
        case next == other {
          True -> Ok(boxes)
          _ ->
            next
            |> try_push(direction, boxes, walls)
        }
      })
      |> result.map(fn(boxes) {
        boxes
        |> dict.delete(coord)
        |> dict.delete(other)
        |> dict.insert(next, other_next)
        |> dict.insert(other_next, next)
      })
    }
  }
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
