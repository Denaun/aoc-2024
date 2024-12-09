import adglent.{First, Second}
import atto
import gleam/int
import gleam/io
import gleam/list
import gleam/string

type Sized(a) {
  Sized(value: a, size: Int)
}

type Block {
  File(id: Int)
  Free
}

fn parse(input: String) -> List(Sized(Block)) {
  use digit, ix <- list.index_map(input |> string.to_graphemes())
  let assert Ok(size) = digit |> int.parse()
  case ix % 2 {
    0 -> Sized(File(ix / 2), size)
    _ -> Sized(Free, size)
  }
}

pub fn part1(input: String) {
  let disk = input |> parse() |> list.flat_map(unpack)
  let to_compact =
    disk
    |> list.filter_map(fn(block) {
      case block {
        File(id) -> Ok(id)
        Free -> Error(Nil)
      }
    })
    |> list.reverse()
  let #(_, rev_ids) =
    disk
    |> list.take(to_compact |> list.length())
    |> list.fold(#(to_compact, []), fn(acc, block) {
      let #(to_compact, rev_ids) = acc
      case block, to_compact {
        File(id), _ -> #(to_compact, [id, ..rev_ids])
        Free, [id, ..to_compact] -> #(to_compact, [id, ..rev_ids])
        _, _ -> panic
      }
    })
  rev_ids
  |> list.reverse()
  |> list.index_fold(0, fn(acc, id, ix) { acc + id * ix })
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
}

fn unpack(s: Sized(a)) -> List(a) {
  s.value |> list.repeat(s.size)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("9")
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
