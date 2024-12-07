import adglent.{type Example, Example}
import day6/solve
import glacier/should
import gleam/list

type Problem1AnswerType =
  Int

type Problem2AnswerType =
  Int

const part1_examples: List(Example(Problem1AnswerType)) = [
  Example(
    ".#..
..#.
.^..",
    2,
  ),
  Example(
    "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
",
    41,
  ),
]

const part2_examples: List(Example(Problem2AnswerType)) = [
  Example(
    "....
     .##.
     #.^#
     ....",
    1,
  ),
  Example(
    "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
",
    6,
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
