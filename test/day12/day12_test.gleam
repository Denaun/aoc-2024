import adglent.{type Example, Example}
import day12/solve
import glacier/should
import gleam/list

type Problem1AnswerType =
  Int

type Problem2AnswerType =
  String

const part1_examples: List(Example(Problem1AnswerType)) = [
  Example(
    "AAAA
BBCD
BBCC
EEEC",
    140,
  ),
  Example(
    "OOOOO
OXOXO
OOOOO
OXOXO
OOOOO",
    772,
  ),
  Example(
    "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE",
    1930,
  ),
]

/// Add examples for part 2 here:
/// ```gleam
///const part2_examples: List(Example(Problem2AnswerType)) = [Example("some input", "")]
/// ```
const part2_examples: List(Example(Problem2AnswerType)) = []

pub fn part1_test() {
  part1_examples
  |> should.not_equal([])
  use example <- list.map(part1_examples)
  solve.part1(example.input)
  |> should.equal(example.answer)
}

pub fn part2_test() {
  part2_examples
  |> should.equal([])
  use example <- list.map(part2_examples)
  solve.part2(example.input)
  |> should.equal(example.answer)
}