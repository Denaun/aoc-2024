import adglent.{First, Second}
import atto.{type Parser}
import atto/ops
import atto/text
import atto/text_util
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/set.{type Set}
import gleam/string
import parse_util

pub fn rules() -> Parser(List(#(Int, Int)), String, String, c, e) {
  ops.sep1(
    parse_util.sep_by(text_util.decimal(), atto.token("|"), text_util.decimal()),
    by: text_util.newline(),
  )
}

pub fn updates() -> Parser(List(List(Int)), String, String, c, e) {
  ops.sep1(
    ops.sep1(text_util.decimal(), by: atto.token(",")),
    by: text_util.newline(),
  )
}

pub fn part1(input: String) {
  let assert [input_rules, input_updates] = input |> string.split(on: "\n\n")
  let assert Ok(rules) = rules() |> atto.run(text.new(input_rules), Nil)
  let assert Ok(updates) = updates() |> atto.run(text.new(input_updates), Nil)
  let precedences =
    rules
    |> list.group(fn(rule) { rule.1 })
    |> dict.map_values(fn(_, group) {
      group |> list.map(fn(rule) { rule.0 }) |> set.from_list
    })
  updates
  |> list.filter(fn(update) { update |> has_right_order(precedences) })
  |> list.map(middle)
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  let assert [input_rules, input_updates] = input |> string.split(on: "\n\n")
  let assert Ok(rules) = rules() |> atto.run(text.new(input_rules), Nil)
  let assert Ok(updates) = updates() |> atto.run(text.new(input_updates), Nil)
  let antecedences =
    rules
    |> list.group(fn(rule) { rule.0 })
    |> dict.map_values(fn(_, group) {
      group |> list.map(fn(rule) { rule.1 }) |> set.from_list
    })
  let precedences =
    rules
    |> list.group(fn(rule) { rule.1 })
    |> dict.map_values(fn(_, group) {
      group |> list.map(fn(rule) { rule.0 }) |> set.from_list
    })
  updates
  |> list.filter(fn(update) {
    update |> has_right_order(precedences) |> bool.negate
  })
  |> list.map(list.sort(_, fn(a, b) {
    case
      antecedences
      |> dict.get(a)
      |> result.map(set.contains(_, b)),
      precedences
      |> dict.get(a)
      |> result.map(set.contains(_, b))
    {
      Ok(True), _ -> order.Lt
      _, Ok(True) -> order.Gt
      _, _ -> order.Eq
    }
  }))
  |> list.map(middle)
  |> list.fold(0, int.add)
}

fn has_right_order(update: List(Int), precedences: Dict(Int, Set(Int))) -> Bool {
  has_right_order_loop(update, precedences, set.new())
}

fn has_right_order_loop(
  update: List(Int),
  precedences: Dict(Int, Set(Int)),
  invalid: Set(Int),
) {
  case update {
    [] -> True
    [page, ..rest] ->
      case invalid |> set.contains(page) {
        True -> False
        False ->
          rest
          |> has_right_order_loop(
            precedences,
            precedences
              |> dict.get(page)
              |> result.map(set.union(invalid, _))
              |> result.unwrap(set.new()),
          )
      }
  }
}

fn middle(a: List(a)) -> a {
  a
  |> list.drop(list.length(a) / 2)
  |> list.first()
  |> result.lazy_unwrap(fn() { panic })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("5")
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
