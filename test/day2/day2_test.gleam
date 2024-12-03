import adglent.{type Example, Example}
import atto
import atto/text
import day2/solve
import glacier/should
import gleam/list

type Problem1AnswerType =
  Int

type Problem2AnswerType =
  Int

const part1_examples: List(Example(Problem1AnswerType)) = [
  Example(
    "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9",
    2,
  ),
]

const part2_examples: List(Example(Problem2AnswerType)) = [
  Example(
    "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9",
    4,
  ),
]

pub fn parser_test() {
  atto.run(
    solve.parser(),
    text.new(
      "1 2 3
4 5 6",
    ),
    Nil,
  )
  |> should.equal(Ok([[1, 2, 3], [4, 5, 6]]))
}

pub fn part1_test() {
  part1_examples
  |> should.not_equal([])
  use example <- list.map(part1_examples)
  solve.part1(example.input)
  |> should.equal(example.answer)
}

pub fn part2_test() {
  part2_examples
  |> should.not_equal([])
  use example <- list.map(part2_examples)
  solve.part2(example.input)
  |> should.equal(example.answer)
}
