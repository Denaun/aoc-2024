import adglent.{First, Second}
import coord.{type Coord}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/set.{type Set}
import gleam/string
import rememo/memo

pub fn part1(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(code) {
    let assert Ok(numeric_part) = code |> string.drop_end(1) |> int.parse()
    numeric_part * complexity(code, robots: 2)
  })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(code) {
    let assert Ok(numeric_part) = code |> string.drop_end(1) |> int.parse()
    numeric_part * complexity(code, robots: 25)
  })
  |> list.fold(0, int.add)
}

fn complexity(code: String, robots robots: Int) -> Int {
  use cache <- memo.create()
  let assert Ok(path) =
    { "A" <> code }
    |> string.to_graphemes()
    |> list.try_map(dict.get(numeric_keypad(), _))
  path
  |> list.window_by_2()
  |> list.map(fn(pair) {
    do_complexity(pair.0, pair.1, numeric_valid(), robots, cache)
  })
  |> list.fold(0, int.add)
}

fn do_complexity(
  a: Coord,
  b: Coord,
  valid: Set(Coord),
  robots: Int,
  cache,
) -> Int {
  use <- memo.memoize(cache, #(a, b, robots))
  let h = case b.x - a.x {
    n if n < 0 -> string.repeat("<", -n)
    n -> string.repeat(">", n)
  }
  let v = case b.y - a.y {
    m if m < 0 -> string.repeat("^", -m)
    m -> string.repeat("v", m)
  }
  let assert Ok(smallest) =
    [
      #(valid |> set.contains(coord.new(b.x, a.y)), h <> v <> "A"),
      #(valid |> set.contains(coord.new(a.x, b.y)), v <> h <> "A"),
    ]
    |> list.key_filter(True)
    |> list.unique()
    |> list.map(fn(code) {
      use <- bool.guard(when: robots == 0, return: code |> string.length())
      let assert Ok(path) =
        { "A" <> code }
        |> string.to_graphemes()
        |> list.try_map(dict.get(directional_keypad(), _))
      path
      |> list.window_by_2()
      |> list.map(fn(pair) {
        do_complexity(pair.0, pair.1, directional_valid(), robots - 1, cache)
      })
      |> list.fold(0, int.add)
    })
    |> smallest(int.compare)
  smallest
}

fn numeric_keypad() {
  [
    #("7", coord.new(0, 0)),
    #("8", coord.new(1, 0)),
    #("9", coord.new(2, 0)),
    #("4", coord.new(0, 1)),
    #("5", coord.new(1, 1)),
    #("6", coord.new(2, 1)),
    #("1", coord.new(0, 2)),
    #("2", coord.new(1, 2)),
    #("3", coord.new(2, 2)),
    #("0", coord.new(1, 3)),
    #("A", coord.new(2, 3)),
  ]
  |> dict.from_list()
}

fn numeric_valid() {
  numeric_keypad() |> dict.values() |> set.from_list()
}

fn directional_keypad() {
  [
    #("^", coord.new(1, 0)),
    #("A", coord.new(2, 0)),
    #("<", coord.new(0, 1)),
    #("v", coord.new(1, 1)),
    #(">", coord.new(2, 1)),
  ]
  |> dict.from_list()
}

fn directional_valid() {
  directional_keypad() |> dict.values() |> set.from_list()
}

fn smallest(l: List(v), by compare: fn(v, v) -> Order) -> Result(v, Nil) {
  l
  |> list.fold(Error(Nil), fn(acc, e) {
    case acc {
      Error(Nil) -> Ok(e)
      Ok(v) ->
        Ok(case e |> compare(v) {
          order.Lt -> e
          _ -> v
        })
    }
  })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("21")
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
