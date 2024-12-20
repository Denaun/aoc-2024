import adglent.{First, Second}
import atto.{type Parser}
import atto/ops
import atto/text
import atto/text_util
import counter
import gleam/int
import gleam/io
import gleam/list
import parse_util

fn line() -> Parser(#(Int, Int), String, String, e, f) {
  use <- atto.label("line")
  parse_util.sep_by(
    text_util.decimal(),
    text_util.hspaces1(),
    text_util.decimal(),
  )
}

pub fn parser() -> Parser(#(List(Int), List(Int)), String, String, e, f) {
  ops.sep1(line(), by: text_util.newline())
  |> atto.map(fn(lines) {
    #(
      list.map(lines, fn(line) { line.0 }),
      list.map(lines, fn(line) { line.1 }),
    )
  })
}

pub fn part1(input: String) {
  let assert Ok(#(first, second)) = atto.run(parser(), text.new(input), Nil)
  list.zip(
    list.sort(first, by: int.compare),
    list.sort(second, by: int.compare),
  )
  |> list.map(fn(pair) { int.absolute_value(pair.0 - pair.1) })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  let assert Ok(#(first, second)) = atto.run(parser(), text.new(input), Nil)
  let counts = second |> counter.from_list
  first
  |> list.map(fn(v) { counts |> counter.get(v) |> int.multiply(v) })
  |> list.fold(0, int.add)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("1")
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
