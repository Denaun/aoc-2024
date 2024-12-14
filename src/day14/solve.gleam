import adglent.{First, Second}
import atto
import atto/ops
import atto/text
import atto/text_util
import coord.{type Coord}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/yielder
import parse_util

type Robot {
  Robot(p: Coord, v: Coord)
}

fn parser() {
  let coord =
    parse_util.sep_by(
      parse_util.signed_int(),
      atto.token(","),
      parse_util.signed_int(),
    )
    |> atto.map(coord.from_pair)
  let position = {
    use <- atto.drop(text.match("p="))
    coord |> text_util.ws()
  }
  let velocity = {
    use <- atto.drop(text.match("v="))
    coord |> text_util.ws()
  }
  let robot = {
    use p <- atto.do(position)
    use v <- atto.do(velocity)
    atto.pure(Robot(p, v))
  }
  ops.many(robot)
}

pub fn part1(input: String, size: Coord) {
  let assert Ok(robots) = parser() |> atto.run(text.new(input), Nil)
  robots
  |> list.map(fn(robot) {
    coord.map3(robot.p, robot.v, size, fn(p, v, s) {
      int.modulo(p + v * 100, s) |> result.lazy_unwrap(fn() { panic })
    })
  })
  |> list.group(fn(coord) {
    case coord, size {
      coord.Coord(x_c, y_c), coord.Coord(x_s, y_s)
        if x_c < x_s / 2 && y_c < y_s / 2
      -> 0
      coord.Coord(x_c, y_c), coord.Coord(x_s, y_s)
        if x_c > x_s / 2 && y_c < y_s / 2
      -> 1
      coord.Coord(x_c, y_c), coord.Coord(x_s, y_s)
        if x_c < x_s / 2 && y_c > y_s / 2
      -> 2
      coord.Coord(x_c, y_c), coord.Coord(x_s, y_s)
        if x_c > x_s / 2 && y_c > y_s / 2
      -> 3
      _, _ -> 4
    }
  })
  |> dict.delete(4)
  |> dict.values()
  |> list.map(list.length)
  |> list.fold(1, int.multiply)
}

pub fn part2(input: String, size: Coord) {
  let assert Ok(robots) = parser() |> atto.run(text.new(input), Nil)
  let assert Ok(#(christmas, seconds)) =
    yielder.iterate(robots, fn(robots) {
      robots
      |> list.map(fn(robot) {
        coord.map3(robot.p, robot.v, size, fn(p, v, s) {
          int.modulo(p + v, s) |> result.lazy_unwrap(fn() { panic })
        })
        |> Robot(robot.v)
      })
    })
    |> yielder.map(list.map(_, fn(r) { r.p }))
    |> yielder.index()
    |> yielder.find(fn(with_index) {
      let #(robots, _) = with_index
      let coords = robots |> set.from_list()
      robots |> list.length() == coords |> set.size()
    })
  christmas |> render(size)
  seconds
}

fn render(coords: List(Coord), size: Coord) {
  let coords = coords |> set.from_list()
  yielder.range(0, size.y - 1)
  |> yielder.each(fn(y) {
    yielder.range(0, size.x - 1)
    |> yielder.each(fn(x) {
      case coords |> set.contains(coord.new(x, y)) {
        True -> io.print("#")
        _ -> io.print(".")
      }
    })
    io.println("")
  })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("14")
  case part {
    First ->
      part1(input, coord.new(101, 103))
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input, coord.new(101, 103))
      |> adglent.inspect
      |> io.println
  }
}
