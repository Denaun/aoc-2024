import adglent.{First, Second}
import atto.{type Parser}
import atto/ops
import atto/text
import atto/text_util
import gleam/int
import gleam/io
import gleam/list

pub fn parser() -> Parser(List(List(Int)), String, String, e, f) {
  ops.sep1(text_util.decimal(), by: text_util.hspaces1())
  |> ops.sep1(by: text_util.newline())
}

pub fn part1(input: String) -> Int {
  let assert Ok(reports) = atto.run(parser(), text.new(input), Nil)
  reports |> list.count(is_safe)
}

pub fn part2(input: String) {
  let assert Ok(reports) = atto.run(parser(), text.new(input), Nil)
  reports
  |> list.count(fn(report) {
    report
    |> list.combinations(list.length(report) - 1)
    |> list.any(is_safe)
  })
}

fn is_safe(report: List(Int)) -> Bool {
  let assert [a, b, ..] = report
  case a > b {
    True -> report
    False -> report |> list.map(int.negate)
  }
  |> list.window_by_2()
  |> list.all(fn(pair) { pair.0 >= pair.1 + 1 && pair.0 <= pair.1 + 3 })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("2")
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
