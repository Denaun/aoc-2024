import adglent.{First, Second}
import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/set
import gleam/string
import gleam/string_tree

pub fn part1(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(code) {
    let assert Ok(numeric_part) = code |> string.drop_end(1) |> int.parse()
    let assert Ok(shortest_sequence) =
      code
      |> directions(numeric_keypad())
      |> list.flat_map(directions(_, directional_keypad()))
      |> list.flat_map(directions(_, directional_keypad()))
      |> list.map(string.length)
      |> smallest(int.compare)
    shortest_sequence * numeric_part
  })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

fn directions(s: String, keypad: Dict(String, Coord)) -> List(String) {
  let valid = keypad |> dict.values() |> set.from_list()
  let assert Ok(path) =
    { "A" <> s }
    |> string.to_graphemes()
    |> list.try_map(dict.get(keypad, _))
  path
  |> list.window_by_2()
  |> list.fold([string_tree.new()], fn(acc, pair) {
    let #(a, b) = pair
    let h = case b.x - a.x {
      n if n < 0 -> string.repeat("<", -n)
      n -> string.repeat(">", n)
    }
    let v = case b.y - a.y {
      m if m < 0 -> string.repeat("^", -m)
      m -> string.repeat("v", m)
    }
    [
      #(valid |> set.contains(coord.new(b.x, a.y)), h <> v <> "A"),
      #(valid |> set.contains(coord.new(a.x, b.y)), v <> h <> "A"),
    ]
    |> list.key_filter(True)
    |> list.unique()
    |> list.flat_map(fn(move) { acc |> list.map(string_tree.append(_, move)) })
  })
  |> list.map(string_tree.to_string)
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
