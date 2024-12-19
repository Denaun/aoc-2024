import adglent.{First, Second}
import atto.{type Parser}
import atto/ops
import atto/text
import atto/text_util
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

type Opcode {
  Adv
  Bxl
  Bst
  Jnz
  Bxc
  Out
  Bdv
  Cdv
}

type Register {
  A
  B
  C
}

type Combo {
  Literal(v: Int)
  Register(r: Register)
  Reserved
}

fn parser() -> Parser(#(Dict(Register, Int), List(Int)), String, String, c, e) {
  use <- atto.drop(text.match("Register A: "))
  use a <- atto.do(text_util.decimal() |> text_util.ws())
  use <- atto.drop(text.match("Register B: "))
  use b <- atto.do(text_util.decimal() |> text_util.ws())
  use <- atto.drop(text.match("Register C: "))
  use c <- atto.do(text_util.decimal() |> text_util.ws())
  use <- atto.drop(text.match("Program: "))
  use program <- atto.do(ops.sep1(text_util.decimal(), atto.token(",")))
  atto.pure(#([#(A, a), #(B, b), #(C, c)] |> dict.from_list(), program))
}

pub fn part1(input: String) {
  let assert Ok(#(memory, program)) = parser() |> atto.run(text.new(input), Nil)
  program
  |> execute(memory)
  |> list.map(int.to_string)
  |> string.join(",")
}

pub fn part2(input: String) {
  let assert Ok(#(memory, program)) = parser() |> atto.run(text.new(input), Nil)
  program
  |> find_self(memory)
}

fn execute(program: List(Int), memory: Dict(Register, Int)) -> List(Int) {
  let #(_, _, output) =
    program
    |> list.index_map(fn(x, i) { #(i, x) })
    |> dict.from_list()
    |> execute_loop(#(0, memory, []))
  output |> list.reverse()
}

fn execute_loop(
  program: Dict(Int, Int),
  state: #(Int, Dict(Register, Int), List(Int)),
) -> #(Int, Dict(Register, Int), List(Int)) {
  let #(ip, memory, output) = state
  case program |> dict.get(ip) {
    Ok(instruction) ->
      program
      |> execute_loop(case
        instruction |> to_opcode(),
        program |> dict.get(ip + 1)
      {
        _, Error(Nil) -> panic
        Adv, Ok(operand) -> #(
          ip + 2,
          memory
            |> dict.insert(
              A,
              memory
                |> read(A)
                |> int.bitwise_shift_right(
                  operand |> to_combo() |> resolve(memory),
                ),
            ),
          output,
        )
        Bxl, Ok(operand) -> #(
          ip + 2,
          memory
            |> dict.insert(
              B,
              memory |> read(B) |> int.bitwise_exclusive_or(operand),
            ),
          output,
        )
        Bst, Ok(operand) -> #(
          ip + 2,
          memory
            |> dict.insert(
              B,
              operand |> to_combo() |> resolve(memory) |> int.bitwise_and(7),
            ),
          output,
        )
        Jnz, Ok(operand) -> {
          case memory |> read(A) {
            0 -> #(ip + 2, memory, output)
            _ -> #(operand, memory, output)
          }
        }
        Bxc, _ -> #(
          ip + 2,
          memory
            |> dict.insert(
              B,
              memory |> read(B) |> int.bitwise_exclusive_or(memory |> read(C)),
            ),
          output,
        )
        Out, Ok(operand) -> #(ip + 2, memory, [
          operand |> to_combo() |> resolve(memory) |> int.bitwise_and(0b111),
          ..output
        ])
        Bdv, Ok(operand) -> #(
          ip + 2,
          memory
            |> dict.insert(
              B,
              memory
                |> read(A)
                |> int.bitwise_shift_right(
                  operand |> to_combo() |> resolve(memory),
                ),
            ),
          output,
        )
        Cdv, Ok(operand) -> #(
          ip + 2,
          memory
            |> dict.insert(
              C,
              memory
                |> read(A)
                |> int.bitwise_shift_right(
                  operand |> to_combo() |> resolve(memory),
                ),
            ),
          output,
        )
      })
    Error(Nil) -> state
  }
}

fn find_self(program: List(Int), memory: Dict(Register, Int)) -> Int {
  program
  |> list.index_map(fn(x, i) { #(i, x) })
  |> dict.from_list()
  |> find_self_loop(memory |> dict.insert(A, 1), program |> list.reverse())
}

fn find_self_loop(
  program: Dict(Int, Int),
  memory: Dict(Register, Int),
  target: List(Int),
) -> Int {
  case program |> execute_loop(#(0, memory, [])) {
    #(_, _, output) if output == target -> memory |> read(A)
    #(_, _, output) ->
      program
      |> find_self_loop(
        memory
          |> dict.insert(
            A,
            memory
              |> read(A)
              |> case count_matches(target, output) == output |> list.length() {
                True -> int.bitwise_shift_left(_, 3)
                _ -> int.add(_, 1)
              },
          ),
        target,
      )
  }
}

fn count_matches(a: List(v), b: List(v)) -> Int {
  case a, b {
    [x, ..a], [y, ..b] if x == y -> 1 + count_matches(a, b)
    _, _ -> 0
  }
}

fn to_opcode(v: Int) -> Opcode {
  case v {
    0 -> Adv
    1 -> Bxl
    2 -> Bst
    3 -> Jnz
    4 -> Bxc
    5 -> Out
    6 -> Bdv
    7 -> Cdv
    _ -> panic as "invalid opcode"
  }
}

fn to_combo(v: Int) -> Combo {
  case v {
    x if 0 <= x && x <= 3 -> Literal(x)
    4 -> Register(A)
    5 -> Register(B)
    6 -> Register(C)
    7 -> Reserved
    _ -> panic as "invalid operand"
  }
}

fn read(memory: Dict(Register, Int), r: Register) -> Int {
  let assert Ok(v) = memory |> dict.get(r)
  v
}

fn resolve(op: Combo, memory: Dict(Register, Int)) -> Int {
  case op {
    Literal(v) -> v
    Register(r) -> memory |> read(r)
    Reserved -> panic
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("17")
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
