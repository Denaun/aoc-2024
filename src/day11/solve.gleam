import adglent.{First, Second}
import atto
import atto/ops
import atto/text
import atto/text_util
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/yielder

pub fn part1(input: String) {
  let assert Ok(stones) =
    ops.sep1(text_util.decimal(), text_util.hspaces1())
    |> atto.run(text.new(input), Nil)
  let assert Ok(stones) =
    stones
    |> yielder.iterate(list.flat_map(_, change))
    |> yielder.at(25)
  stones
  |> list.length()
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

fn change(v: Int) {
  case v {
    0 -> [1]
    _ -> {
      let s = v |> int.to_string()
      case s |> string.length() {
        x if x % 2 == 0 -> {
          let assert Ok(first) = s |> string.slice(0, x / 2) |> int.parse()
          let assert Ok(second) = s |> string.slice(x / 2, x / 2) |> int.parse()
          [first, second]
        }
        _ -> [v * 2024]
      }
    }
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("11")
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
