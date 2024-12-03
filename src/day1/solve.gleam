import adglent.{First, Second}
import atto.{type Parser}
import atto/ops
import atto/text
import atto/text_util
import gleam/int
import gleam/io
import gleam/list

fn line() -> Parser(#(Int, Int), String, String, e, f) {
  use <- atto.label("line")
  use a <- atto.do(text_util.decimal() |> text_util.ws())
  use b <- atto.do(text_util.decimal())
  atto.pure(#(a, b))
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
  todo as "Implement solution to part 2"
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
