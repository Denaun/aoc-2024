import adglent.{type Example, Example}
import day17/solve
import glacier/should
import gleam/list

type Problem1AnswerType =
  String

type Problem2AnswerType =
  Int

const part1_examples: List(Example(Problem1AnswerType)) = [
  Example(
    "Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0",
    "4,6,3,5,6,3,5,2,1,0",
  ),
]

const part2_examples: List(Example(Problem2AnswerType)) = [
  Example(
    "Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0",
    117_440,
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
