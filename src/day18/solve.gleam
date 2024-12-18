import adglent.{First, Second}
import atto
import atto/ops
import atto/text
import atto/text_util
import coord.{type Coord}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleamy/priority_queue.{type Queue}
import parse_util

fn parser() -> atto.Parser(List(coord.Coord), String, String, c, e) {
  let coord =
    parse_util.sep_by(text_util.decimal(), atto.token(","), text_util.decimal())
    |> atto.map(fn(pair) { coord.new(pair.0, pair.1) })
    |> text_util.ws()
  ops.many(coord)
}

pub fn part1(input: String, size: Coord, bytes: Int) {
  let assert Ok(pixels) = parser() |> atto.run(text.new(input), Nil)
  shortest_path(
    coord.new(0, 0),
    size,
    pixels |> list.take(bytes) |> set.from_list(),
  )
}

fn shortest_path(from: Coord, size: Coord, walls: Set(Coord)) -> Int {
  let cost = fn(pair: #(Int, Coord)) {
    pair.0 + { pair.1 |> l1_distance(size) }
  }
  priority_queue.from_list([#(0, from)], fn(a, b) {
    int.compare(a |> cost(), b |> cost())
  })
  |> shortest_path_loop(size, walls, set.new())
}

fn shortest_path_loop(
  to_visit: Queue(#(Int, Coord)),
  size: Coord,
  walls: Set(Coord),
  visited: Set(Coord),
) -> Int {
  let assert Ok(#(top, to_visit)) = to_visit |> priority_queue.pop()
  case top {
    #(cost, coord) if coord == size -> cost
    #(cost, coord) -> {
      [coord.new(-1, 0), coord.new(1, 0), coord.new(0, -1), coord.new(0, 1)]
      |> list.map(coord.add(coord, _))
      |> list.filter(fn(next) {
        { next.x >= 0 && next.y >= 0 && next.x <= size.x && next.y <= size.y }
        && !{ visited |> set.contains(next) }
        && !{ walls |> set.contains(next) }
      })
      |> list.fold(to_visit, fn(acc, next) {
        acc |> priority_queue.push(#(cost + 1, next))
      })
      |> shortest_path_loop(size, walls, visited |> set.insert(coord))
    }
  }
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

fn l1_distance(a: Coord, b: Coord) -> Int {
  int.absolute_value(a.x - b.x) + int.absolute_value(a.y - b.y)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("18")
  case part {
    First ->
      part1(input, coord.new(70, 70), 0)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}
