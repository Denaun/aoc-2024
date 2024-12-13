import adglent.{type Example, Example}
import day12/solve
import glacier/should
import gleam/list

type Problem1AnswerType =
  Int

type Problem2AnswerType =
  Int

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

const part2_examples: List(Example(Problem2AnswerType)) = [
  Example(
    "AAAA
BBCD
BBCC
EEEC",
    80,
  ),
  Example(
    "OOOOO
OXOXO
OOOOO
OXOXO
OOOOO",
    436,
  ),
  Example(
    "EEEEE
EXXXX
EEEEE
EXXXX
EEEEE",
    236,
  ),
  Example(
    "AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA",
    368,
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
    1206,
  ),
]

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
