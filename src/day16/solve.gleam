import adglent.{First, Second}
import coord.{type Coord}
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleamy/pairing_heap
import gleamy/priority_queue
import parse_util

fn parse(input: String) {
  let assert #(Some(start), Some(end), walls) =
    input
    |> parse_util.parse_map(#(None, None, set.new()), fn(acc, c, coord) {
      let #(start, end, walls) = acc
      case c {
        "#" -> #(start, end, walls |> set.insert(coord))
        "S" ->
          case start {
            None -> #(Some(coord), end, walls)
            _ -> panic as "Multiple starts found"
          }
        "E" ->
          case end {
            None -> #(start, Some(coord), walls)
            _ -> panic as "Multiple ends found"
          }
        _ -> acc
      }
    })
  #(start, end, walls)
}

pub fn part1(input: String) {
  let #(start, end, walls) = input |> parse()
  shortest_path(start, end, walls)
}

fn shortest_path(from: Coord, to: Coord, walls: Set(Coord)) -> Int {
  priority_queue.from_list([#(0, from, East)], fn(a, b) {
    int.compare(a.0, b.0)
  })
  |> shortest_path_loop(to, walls, set.new())
}

fn shortest_path_loop(
  to_visit: pairing_heap.Heap(#(Int, Coord, Direction)),
  to: Coord,
  walls: Set(Coord),
  visited: Set(#(Coord, Direction)),
) -> Int {
  let assert Ok(#(top, to_visit)) = to_visit |> priority_queue.pop()
  case top {
    #(cost, from, _) if from == to -> cost
    #(cost, from, direction) -> {
      let state = #(from, direction)
      let next = from |> forward(direction)
      case visited |> set.contains(state) {
        True -> to_visit
        _ ->
          case walls |> set.contains(next) {
            True -> to_visit
            _ ->
              to_visit
              |> priority_queue.push(#(cost + 1, next, direction))
          }
          |> priority_queue.push(#(cost + 1000, from, direction |> left()))
          |> priority_queue.push(#(cost + 1000, from, direction |> right()))
      }
      |> shortest_path_loop(to, walls, visited |> set.insert(state))
    }
  }
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

type Direction {
  North
  South
  East
  West
}

fn left(d: Direction) -> Direction {
  case d {
    North -> West
    South -> East
    East -> North
    West -> South
  }
}

fn right(d: Direction) -> Direction {
  case d {
    North -> East
    South -> West
    East -> South
    West -> North
  }
}

fn forward(c: Coord, d: Direction) -> Coord {
  case d {
    North -> c |> coord.add(coord.new(-1, 0))
    South -> c |> coord.add(coord.new(1, 0))
    East -> c |> coord.add(coord.new(0, 1))
    West -> c |> coord.add(coord.new(0, -1))
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("16")
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
