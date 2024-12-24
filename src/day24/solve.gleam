import adglent.{First, Second}
import atto
import atto/ops
import atto/text
import atto/text_util
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import parse_util

fn parse(input: String) -> #(Dict(String, Bool), List(#(Gate, String))) {
  let assert Ok(#(wires, gates)) = input |> string.split_once("\n\n")
  let id = text.match("\\w+")
  let assert Ok(wires) =
    parse_util.sep_by(
      id,
      text.match(": "),
      text.match("[01]") |> atto.map(fn(c) { c == "1" }),
    )
    |> text_util.ws()
    |> ops.some()
    |> atto.map(dict.from_list)
    |> atto.run(text.new(wires), Nil)
  let assert Ok(gates) =
    {
      use left <- atto.do(id |> text_util.ws())
      use op <- atto.do(
        ops.choice([
          text.match("AND") |> atto.map(fn(_) { And }),
          text.match("OR") |> atto.map(fn(_) { Or }),
          text.match("XOR") |> atto.map(fn(_) { Xor }),
        ])
        |> text_util.ws(),
      )
      use right <- atto.do(id |> text_util.ws())
      use <- atto.drop(text.match("->") |> text_util.ws())
      use out <- atto.do(id |> text_util.ws())
      atto.pure(#(Gate(left, op, right), out))
    }
    |> ops.some()
    |> atto.run(text.new(gates), Nil)
  #(wires, gates)
}

pub fn part1(input: String) {
  let #(wires, gates) =
    input
    |> parse()
  wires
  |> propagate(gates)
  |> dict.filter(fn(wire, _) { wire |> string.starts_with("z") })
  |> dict.fold(0, fn(acc, wire, on) {
    use <- bool.guard(when: !on, return: acc)
    let assert Ok(bit) = wire |> string.drop_start(1) |> int.parse()
    acc |> int.bitwise_or(1 |> int.bitwise_shift_left(bit))
  })
}

fn propagate(
  wires: Dict(String, Bool),
  gates: List(#(Gate, String)),
) -> Dict(String, Bool) {
  use <- bool.guard(when: gates |> list.is_empty(), return: wires)
  let #(wires, gates) =
    gates
    |> list.map_fold(wires, fn(wires, gate) {
      case gate.0 |> eval(wires) {
        Ok(v) -> #(wires |> dict.insert(gate.1, v), option.None)
        _ -> #(wires, option.Some(gate))
      }
    })
  wires |> propagate(gates |> list.filter_map(option.to_result(_, Nil)))
}

pub fn part2(input: String) {
  let #(wires, gates) =
    input
    |> parse()
  let last_out = "z" <> { dict.size(wires) / 2 } |> int.to_string
  gates
  |> list.filter_map(fn(pair) {
    let #(gate, out) = pair
    case gate, out {
      Gate(_, Xor, _), _ -> {
        gates
        |> list.find_map(fn(pair) {
          case pair {
            #(Gate(l, Or, r), _) if l == out || r == out -> Ok(out)
            _ -> Error(Nil)
          }
        })
      }
      Gate(_, Or, _), "z" <> _ if out == last_out -> Error(Nil)
      Gate(_, _, _), "z" <> _ -> Ok(out)
      Gate(_, And, _), out -> {
        gates
        |> list.find_map(fn(pair) {
          case pair {
            #(Gate(_, Or, _), _) -> Error(Nil)
            #(Gate(l, _, r), _) if l == out || r == out -> Ok(out)
            _ -> Error(Nil)
          }
        })
      }
      _, _ -> Error(Nil)
    }
  })
  |> list.sort(string.compare)
  |> string.join(",")
}

type Gate {
  Gate(left: String, op: Op, right: String)
}

type Op {
  And
  Or
  Xor
}

fn eval(gate: Gate, wires: Dict(String, Bool)) -> Result(Bool, Nil) {
  case wires |> dict.get(gate.left), wires |> dict.get(gate.right) {
    Ok(left), Ok(right) ->
      case gate.op {
        And -> bool.and
        Or -> bool.or
        Xor -> bool.exclusive_or
      }(left, right)
      |> Ok
    _, _ -> Error(Nil)
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("24")
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
