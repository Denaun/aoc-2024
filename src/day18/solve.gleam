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
  let assert Ok(length) =
    shortest_path(
      coord.new(0, 0),
      size,
      pixels |> list.take(bytes) |> set.from_list(),
    )
  length
}

fn shortest_path(
  from: Coord,
  size: Coord,
  walls: Set(Coord),
) -> Result(Int, Nil) {
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
) -> Result(Int, Nil) {
  case to_visit |> priority_queue.pop() {
    Error(Nil) -> Error(Nil)
    Ok(#(#(cost, coord), _)) if coord == size -> Ok(cost)
    Ok(#(#(cost, coord), to_visit)) -> {
      coord
      |> neighbors(size)
      |> list.filter(fn(next) {
        !{ visited |> set.contains(next) } && !{ walls |> set.contains(next) }
      })
      |> list.fold(to_visit, fn(acc, next) {
        acc |> priority_queue.push(#(cost + 1, next))
      })
      |> shortest_path_loop(size, walls, visited |> set.insert(coord))
    }
  }
}

pub fn part2(input: String, size: Coord) {
  let assert Ok(pixels) = parser() |> atto.run(text.new(input), Nil)
  let assert [blocking, ..] =
    pixels
    |> list.fold_until([], fn(acc, pixel) {
      let pixels = [pixel, ..acc]
      case shortest_path(coord.new(0, 0), size, pixels |> set.from_list()) {
        Ok(_) -> list.Continue(pixels)
        Error(Nil) -> list.Stop(pixels)
      }
    })
  blocking
}

fn neighbors(c: Coord, size: Coord) -> List(Coord) {
  [coord.new(-1, 0), coord.new(1, 0), coord.new(0, -1), coord.new(0, 1)]
  |> list.map(coord.add(c, _))
  |> list.filter(fn(next) {
    next.x >= 0 && next.y >= 0 && next.x <= size.x && next.y <= size.y
  })
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
      part2(input, coord.new(70, 70))
      |> adglent.inspect
      |> io.println
  }
}
