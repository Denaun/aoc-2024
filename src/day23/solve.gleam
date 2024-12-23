import adglent.{First, Second}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set
import gleam/string

fn parse(input: String) -> Result(List(#(String, String)), Nil) {
  input
  |> string.split("\n")
  |> list.try_map(string.split_once(_, "-"))
}

pub fn part1(input: String) {
  let assert Ok(connections) = input |> parse() |> result.map(to_bidi_dict)
  {
    connections
    |> dict.keys()
    |> list.filter(string.starts_with(_, "t"))
    |> list.map_fold(set.new(), fn(visited, first) {
      #(
        visited |> set.insert(first),
        connections
          |> neighbors(first)
          |> set.filter(fn(second) { !set.contains(visited, second) })
          |> set.to_list()
          |> list.flat_map(fn(second) {
            connections
            |> neighbors(second)
            |> set.filter(fn(third) { !set.contains(visited, third) })
            |> set.to_list()
          })
          |> list.count(fn(third) {
            connections
            |> neighbors(third)
            |> set.contains(first)
          }),
      )
    })
    |> pair.second()
    |> list.fold(0, int.add)
  }
  / 2
}

pub fn part2(input: String) {
  let assert Ok(connections) = input |> parse() |> result.map(to_bidi_dict)
  largest_all_connected(connections)
  |> list.sort(string.compare)
  |> string.join(",")
}

fn largest_all_connected(connections) {
  connections
  |> largest_all_connected_loop([], connections |> dict.keys())
}

fn largest_all_connected_loop(connections, current, candidates) {
  case candidates {
    [] -> current
    [first, ..rest] -> {
      let with =
        connections
        |> largest_all_connected_loop(
          [first, ..current],
          candidates
            |> list.filter(set.contains(neighbors(connections, first), _)),
        )
      let without = connections |> largest_all_connected_loop(current, rest)
      case with |> list.length() >= without |> list.length() {
        True -> with
        False -> without
      }
    }
  }
}

fn to_bidi_dict(connections) {
  connections
  |> list.flat_map(fn(c) { [c, c |> pair.swap()] })
  |> list.fold(dict.new(), fn(acc, pair) {
    acc
    |> dict.upsert(pair.0, fn(v) {
      v |> option.lazy_unwrap(set.new) |> set.insert(pair.1)
    })
  })
}

fn neighbors(d, k) {
  case d |> dict.get(k) {
    Ok(v) -> v |> set.delete(k)
    _ -> panic
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("23")
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
