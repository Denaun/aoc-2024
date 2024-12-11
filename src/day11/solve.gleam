import adglent.{First, Second}
import atto
import atto/ops
import atto/text
import atto/text_util
import gleam/int
import gleam/io
import gleam/string
import rememo/memo

pub fn part1(input: String) {
  let assert Ok(stones) =
    ops.sep1(text_util.decimal(), text_util.hspaces1())
    |> atto.run(text.new(input), Nil)
  use cache <- memo.create()
  changes(stones, 25, cache)
}

pub fn part2(input: String) {
  let assert Ok(stones) =
    ops.sep1(text_util.decimal(), text_util.hspaces1())
    |> atto.run(text.new(input), Nil)
  use cache <- memo.create()
  changes(stones, 75, cache)
}

fn changes(stones: List(Int), times: Int, cache) -> Int {
  case stones, times {
    [_], 0 -> 1
    [0], _ -> changes([1], times - 1, cache)
    [v], _ -> {
      use <- memo.memoize(cache, #(v, times))
      let s = v |> int.to_string()
      case s |> string.length() {
        x if x % 2 == 0 -> {
          let assert Ok(first) = s |> string.slice(0, x / 2) |> int.parse()
          let assert Ok(second) = s |> string.slice(x / 2, x / 2) |> int.parse()
          changes([first], times - 1, cache)
          + changes([second], times - 1, cache)
        }
        _ -> changes([v * 2024], times - 1, cache)
      }
    }
    [s, ..rest], _ -> changes([s], times, cache) + changes(rest, times, cache)
    [], _ -> 0
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
