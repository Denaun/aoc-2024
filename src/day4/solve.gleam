import adglent.{First, Second}
import atto
import atto/ops
import atto/text
import atto/text_util
import gleam/int
import gleam/io
import gleam/list

pub fn part1(input: String) {
  let assert Ok(lines) =
    ops.many(text.match("."))
    |> ops.sep(by: text_util.newline())
    |> atto.run(text.new(input), Nil)
  let horizontal =
    lines
    |> list.map(fn(line) { line |> list.window(4) |> list.count(is_xmas) })
    |> list.fold(0, int.add)
  let vertical =
    lines
    |> list.transpose()
    |> list.map(fn(line) { line |> list.window(4) |> list.count(is_xmas) })
    |> list.fold(0, int.add)
  let diagonal1 =
    lines
    |> list.transpose()
    |> list.window(4)
    |> list.map(fn(group) {
      group
      |> list.transpose()
      |> list.window(4)
      |> list.count(fn(square) {
        case square {
          [[x, ..], [_, m, ..], [_, _, a, ..], [_, _, _, s, ..]] ->
            is_xmas([x, m, a, s])
          _ -> False
        }
      })
    })
    |> list.fold(0, int.add)
  let diagonal2 =
    lines
    |> list.transpose()
    |> list.window(4)
    |> list.map(fn(group) {
      group
      |> list.transpose()
      |> list.window(4)
      |> list.count(fn(square) {
        case square {
          [[_, _, _, x, ..], [_, _, m, ..], [_, a, ..], [s, ..]] ->
            is_xmas([x, m, a, s])
          _ -> False
        }
      })
    })
    |> list.fold(0, int.add)
  horizontal + vertical + diagonal1 + diagonal2
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

fn is_xmas(word: List(String)) -> Bool {
  word == ["X", "M", "A", "S"] || word == ["S", "A", "M", "X"]
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("4")
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
