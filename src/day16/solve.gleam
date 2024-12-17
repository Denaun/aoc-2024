import adglent.{First, Second}
import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/order
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
  let #(start, end, walls) = input |> parse()
  let best = shortest_path(start, end, walls)
  find_paths(best, start, end, walls)
  |> list.flatten()
  |> list.map(fn(x) { x.0 })
  |> list.unique()
  |> list.length()
}

fn find_paths(
  target_cost: Int,
  from: Coord,
  to: Coord,
  walls: Set(Coord),
) -> List(List(#(Coord, Direction))) {
  priority_queue.from_list([#(target_cost, [#(from, East)])], fn(a, b) {
    int.compare(a.0, b.0) |> order.negate()
  })
  |> find_paths_loop(to, walls, dict.new())
}

fn find_paths_loop(
  to_visit: pairing_heap.Heap(#(Int, List(#(Coord, Direction)))),
  to: Coord,
  walls: Set(Coord),
  visited: Dict(#(Coord, Direction), Int),
) -> List(List(#(Coord, Direction))) {
  case to_visit |> priority_queue.pop() {
    Error(Nil) -> []
    Ok(#(#(0, [#(last, _), ..] as path), to_visit)) if last == to -> [
      path |> list.reverse(),
      ..{ to_visit |> find_paths_loop(to, walls, visited) }
    ]
    Ok(#(#(budget, path), to_visit)) -> {
      let assert [state, ..] = path
      case state, visited |> dict.get(state) {
        _, Ok(max_budget) if max_budget > budget ->
          to_visit
          |> find_paths_loop(to, walls, visited)
        #(from, direction), _ -> {
          let next = from |> forward(direction)
          case walls |> set.contains(next) {
            True -> to_visit
            _ ->
              to_visit
              |> priority_queue.push(
                #(budget - 1, [#(next, direction), ..path]),
              )
          }
          |> priority_queue.push(
            #(budget - 1000, [#(from, direction |> left()), ..path]),
          )
          |> priority_queue.push(
            #(budget - 1000, [#(from, direction |> right()), ..path]),
          )
          |> find_paths_loop(to, walls, visited |> dict.insert(state, budget))
        }
      }
    }
  }
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
