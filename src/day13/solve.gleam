import adglent.{First, Second}
import atto
import atto/ops
import atto/text
import atto/text_util
import coord
import gleam/int
import gleam/io
import gleam/list

fn parser() {
  let button_a = {
    use <- atto.drop(text.match("Button A: X"))
    use x <- atto.do(text_util.signed(text_util.decimal(), int.negate))
    use <- atto.drop(text.match(", Y"))
    use y <- atto.do(text_util.signed(text_util.decimal(), int.negate))
    atto.pure(coord.new(x, y)) |> text_util.ws()
  }
  let button_b = {
    use <- atto.drop(text.match("Button B: X"))
    use x <- atto.do(text_util.signed(text_util.decimal(), int.negate))
    use <- atto.drop(text.match(", Y"))
    use y <- atto.do(text_util.signed(text_util.decimal(), int.negate))
    atto.pure(coord.new(x, y)) |> text_util.ws()
  }
  let prize = {
    use <- atto.drop(text.match("Prize: X="))
    use x <- atto.do(text_util.decimal())
    use <- atto.drop(text.match(", Y="))
    use y <- atto.do(text_util.decimal())
    atto.pure(coord.new(x, y)) |> text_util.ws()
  }
  let machine = {
    use a <- atto.do(button_a)
    use b <- atto.do(button_b)
    use prize <- atto.do(prize)
    atto.pure(#(a, b, prize))
  }
  ops.many(machine)
}

pub fn part1(input: String) {
  let assert Ok(machines) = parser() |> atto.run(text.new(input), Nil)
  machines
  |> list.filter_map(fn(machine) {
    let #(a, b, prize) = machine
    tokens(a, b, prize)
  })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  let assert Ok(machines) = parser() |> atto.run(text.new(input), Nil)
  machines
  |> list.filter_map(fn(machine) {
    let #(a, b, prize) = machine
    tokens(
      a,
      b,
      coord.add(prize, coord.new(10_000_000_000_000, 10_000_000_000_000)),
    )
  })
  |> list.fold(0, int.add)
}

fn tokens(a: coord.Coord, b: coord.Coord, prize: coord.Coord) {
  let b_factor = b.x * a.y - b.y * a.x
  let prize_factor = prize.x * a.y - prize.y * a.x
  case int.remainder(prize_factor, b_factor) {
    Ok(0) -> {
      let b_presses = prize_factor / b_factor
      let a_factor = prize.x - b.x * b_presses
      case int.remainder(a_factor, a.x) {
        Ok(0) -> {
          let a_presses = a_factor / a.x
          Ok(3 * a_presses + b_presses)
        }
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("13")
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
