import adglent.{First, Second}
import atto
import atto/ops
import atto/text
import atto/text_util
import gleam/int
import gleam/io
import gleam/list

fn parser() -> atto.Parser(List(#(Int, List(Int))), String, String, c, e) {
  {
    use goal <- atto.do(text_util.decimal())
    use <- atto.drop(atto.token(":") |> text_util.ws())
    use numbers <- atto.do(ops.sep1(text_util.decimal(), text_util.hspaces1()))
    atto.pure(#(goal, numbers))
  }
  |> ops.sep1(text_util.newline())
}

pub fn part1(input: String) {
  let assert Ok(tests) = parser() |> atto.run(text.new(input), Nil)
  tests
  |> list.filter_map(fn(t) {
    let #(goal, numbers) = t
    case numbers |> can_equal(goal) {
      True -> Ok(goal)
      _ -> Error(Nil)
    }
  })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

fn can_equal(numbers: List(Int), goal: Int) -> Bool {
  can_equal_loop(numbers, goal, 0)
}

fn can_equal_loop(numbers: List(Int), goal: Int, current: Int) -> Bool {
  case numbers {
    [] -> goal == current
    [x, ..rest] -> {
      can_equal_loop(rest, goal, current * x)
      || can_equal_loop(rest, goal, current + x)
    }
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("7")
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
