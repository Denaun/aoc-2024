import adglent.{First, Second}
import atto.{type Parser}
import atto/ops
import atto/text
import atto/text_util
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp

pub fn part1(input: String) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(re, input)
  |> list.map(fn(match) {
    let assert [Some(lhs), Some(rhs)] = match.submatches
    let assert Ok(lhs) = int.parse(lhs)
    let assert Ok(rhs) = int.parse(rhs)
    lhs * rhs
  })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
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
