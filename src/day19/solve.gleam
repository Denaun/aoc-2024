import adglent.{First, Second}
import gleam/io
import gleam/list
import gleam/set
import gleam/string

fn parse(input: String) -> #(List(String), List(String)) {
  let assert [patterns, designs] = input |> string.split("\n\n")
  #(patterns |> string.split(", "), designs |> string.split("\n"))
}

pub fn part1(input: String) {
  let #(patterns, designs) = input |> parse()
  designs |> list.count(can_display(_, patterns))
}

fn can_display(design: String, patterns: List(String)) -> Bool {
  let n = design |> string.length()
  let dp = set.from_list([0])
  list.range(1, n)
  |> list.fold(dp, fn(dp, i) {
    case
      patterns
      |> list.any(fn(pattern) {
        let k = pattern |> string.length()
        k <= i
        && dp |> set.contains(i - k)
        && design |> string.slice(i - k, k) == pattern
      })
    {
      True -> dp |> set.insert(i)
      _ -> dp
    }
  })
  |> set.contains(n)
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("19")
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
