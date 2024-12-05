import adglent.{First, Second}
import atto.{type Parser}
import atto/ops
import atto/text
import atto/text_util
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import parse_util

pub type Instruction {
  Mul(Int, Int)
  Do
  Dont
}

pub fn parser() -> Parser(List(Instruction), String, String, a, b) {
  ops.many(
    ops.choice([
      parse_util.non_consuming(mul()) |> atto.map(option.Some),
      text.match("do\\(\\)") |> atto.map(fn(_) { option.Some(Do) }),
      text.match("don't\\(\\)") |> atto.map(fn(_) { option.Some(Dont) }),
      atto.any() |> atto.map(fn(_) { option.None }),
    ]),
  )
  |> atto.map(list.filter_map(_, option.to_result(_, Nil)))
}

pub fn mul() -> Parser(Instruction, String, String, a, b) {
  use <- atto.label("mul")
  ops.between(
    text.match("mul\\("),
    parse_util.sep_by(text_util.decimal(), atto.token(","), text_util.decimal()),
    atto.token(")"),
  )
  |> atto.map(fn(pair) { Mul(pair.0, pair.1) })
}

pub fn part1(input: String) {
  let assert Ok(instructions) = parser() |> atto.run(text.new(input), Nil)
  instructions
  |> list.filter_map(fn(instruction) {
    case instruction {
      Mul(lhs, rhs) -> Ok(lhs * rhs)
      _ -> Error(Nil)
    }
  })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  let assert Ok(instructions) = parser() |> atto.run(text.new(input), Nil)
  let #(result, _) =
    instructions
    |> list.fold(#(0, True), fn(acc, instruction) {
      let #(acc, do) = acc
      case instruction {
        Mul(lhs, rhs) ->
          case do {
            True -> #(acc + lhs * rhs, do)
            False -> #(acc, do)
          }
        Do -> #(acc, True)
        Dont -> #(acc, False)
      }
    })
  result
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("3")
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
