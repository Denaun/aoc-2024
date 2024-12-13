import adglent.{First, Second}
import coord.{type Coord}
import counter
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/set.{type Set}
import parse_util

fn parse(input: String) -> Dict(Coord, String) {
  input
  |> parse_util.parse_map(dict.new(), fn(acc, c, coord) {
    acc |> dict.insert(coord, c)
  })
}

pub fn part1(input: String) {
  let plots = input |> parse()
  let regions = plots |> find_regions()
  regions
  |> list.fold(0, fn(acc, region) {
    acc + { region |> set.size() } * { region |> perimeter() |> list.length() }
  })
}

pub fn part2(input: String) {
  let plots = input |> parse()
  let regions = plots |> find_regions()
  regions
  |> list.fold(0, fn(acc, region) {
    acc
    + { region |> set.size() }
    * {
      region
      |> perimeter()
      |> merge_edges()
      |> list.length()
    }
  })
}

fn find_regions(plots: Dict(Coord, String)) -> List(Set(Coord)) {
  let #(_, regions) =
    plots
    |> dict.keys()
    |> list.map_fold(set.new(), fn(visited, coord) {
      case visited |> set.contains(coord) {
        False -> {
          let region = find_region_loop(plots, coord, set.from_list([coord]))
          #(visited |> set.union(region), region)
        }
        _ -> #(visited, set.new())
      }
    })
  regions
  |> list.filter(fn(region) { !{ region |> set.is_empty() } })
}

fn find_region_loop(
  plots: Dict(Coord, String),
  coord: Coord,
  region: Set(Coord),
) -> Set(Coord) {
  let assert Ok(plant) = plots |> dict.get(coord)
  [coord.new(-1, 0), coord.new(1, 0), coord.new(0, -1), coord.new(0, 1)]
  |> list.map(coord.add(coord, _))
  |> list.fold(region, fn(region, neighbor) {
    case plots |> dict.get(neighbor), region |> set.contains(neighbor) {
      Ok(p), False if p == plant -> {
        region
        |> set.union(find_region_loop(
          plots,
          neighbor,
          region |> set.insert(neighbor),
        ))
      }
      _, _ -> region
    }
  })
}

type Edge {
  Horizontal(x0: Int, x1: Int, y: Int)
  Vertical(x: Int, y0: Int, y1: Int)
}

fn perimeter(region: Set(Coord)) -> List(Edge) {
  region
  |> set.fold(set.new(), fn(perimeter, plant) {
    set.from_list([
      Horizontal(plant.x, plant.x + 1, plant.y),
      Horizontal(plant.x, plant.x + 1, plant.y + 1),
      Vertical(plant.x, plant.y, plant.y + 1),
      Vertical(plant.x + 1, plant.y, plant.y + 1),
    ])
    |> set.symmetric_difference(perimeter)
  })
  |> set.to_list()
}

fn merge_edges(edges: List(Edge)) -> List(Edge) {
  let intersections =
    edges
    |> list.flat_map(fn(e) {
      case e {
        Horizontal(x0, x1, y) -> [coord.new(x0, y), coord.new(x1, y)]
        Vertical(x, y0, y1) -> [coord.new(x, y0), coord.new(x, y1)]
      }
    })
    |> counter.from_list()
  edges
  |> list.sort(fn(a, b) {
    case a, b {
      Horizontal(x0, x1, y0), Horizontal(x2, x3, y1) ->
        int.compare(y0, y1)
        |> order.break_tie(int.compare(x0, x2))
        |> order.break_tie(int.compare(x1, x3))
      Vertical(x0, y0, y1), Vertical(x1, y2, y3) ->
        int.compare(x0, x1)
        |> order.break_tie(int.compare(y0, y2))
        |> order.break_tie(int.compare(y1, y3))
      Horizontal(..), Vertical(..) -> order.Lt
      Vertical(..), Horizontal(..) -> order.Gt
    }
  })
  |> list.fold([], fn(sides, edge) {
    case sides {
      [] -> [edge]
      [s, ..rest] ->
        case s, edge {
          Horizontal(x0, x1, y0), Horizontal(x2, x3, y1)
            if x1 == x2 && y0 == y1
          ->
            case intersections |> counter.get(coord.new(x1, y0)) {
              n if n > 2 -> [edge, ..sides]
              _ -> [Horizontal(x0, x3, y0), ..rest]
            }
          Vertical(x0, y0, y1), Vertical(x1, y2, y3) if x0 == x1 && y1 == y2 ->
            case intersections |> counter.get(coord.new(x0, y1)) {
              n if n > 2 -> [edge, ..sides]
              _ -> [Vertical(x0, y0, y3), ..rest]
            }
          _, _ -> [edge, ..sides]
        }
    }
  })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("12")
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
