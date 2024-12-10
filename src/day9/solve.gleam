import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

type Sized(a) {
  Sized(value: a, size: Int)
}

type WithIndex(a) {
  WithIndex(value: a, index: Int)
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
  let disk = input |> parse() |> with_index()
  let #(to_compact, free) =
    disk
    |> list.partition(fn(block) {
      case block {
        WithIndex(Sized(File(_), _), _) -> True
        _ -> False
      }
    })
  to_compact
  |> list.reverse()
  |> yielder.from_list()
  |> yielder.transform(free, fn(free, block) {
    case
      free
      |> list.take_while(fn(x) { x.index < block.index })
      |> try_insert(block.value)
    {
      Ok(#(inserted, free)) -> yielder.Next(inserted, free)
      Error(Nil) -> yielder.Next(block, free)
    }
  })
  |> yielder.fold(0, fn(acc, block) {
    acc
    + case block {
      WithIndex(Sized(File(id), size), index) ->
        list.range(index, index + size - 1)
        |> list.fold(0, fn(acc, ix) { acc + id * ix })
      _ -> 0
    }
  })
}

fn unpack(s: Sized(a)) -> List(a) {
  s.value |> list.repeat(s.size)
}

fn with_index(l: List(Sized(a))) -> List(WithIndex(Sized(a))) {
  case l {
    [] -> []
    [first, ..rest] -> [
      WithIndex(first, 0),
      ..rest
      |> list.scan(WithIndex(first, 0), fn(acc, d) {
        WithIndex(d, acc.index + acc.value.size)
      })
    ]
  }
}

type FullBlock =
  WithIndex(Sized(Block))

fn try_insert(
  l: List(FullBlock),
  block: Sized(Block),
) -> Result(#(FullBlock, List(FullBlock)), Nil) {
  case l {
    [] -> Error(Nil)
    [WithIndex(Sized(Free, size), index), ..rest] if size >= block.size ->
      Ok(
        #(WithIndex(block, index), [
          WithIndex(Sized(Free, size - block.size), index + block.size),
          ..rest
        ]),
      )
    [skip, ..rest] ->
      rest
      |> try_insert(block)
      |> result.map(fn(x) { #(x.0, [skip, ..x.1]) })
  }
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
