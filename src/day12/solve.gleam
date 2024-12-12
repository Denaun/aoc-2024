import adglent.{First, Second}
import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
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
    acc + { region |> set.size() } * { region |> perimeter() |> set.size() }
  })
}

pub fn part2(input: String) {
  todo as "Implement solution to part 2"
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
  Edge(a: Coord, b: Coord)
}

fn perimeter(region: Set(Coord)) -> Set(Edge) {
  region
  |> set.fold(set.new(), fn(perimeter, plant) {
    set.from_list([
      Edge(coord.add(plant, coord.new(-1, 0)), plant),
      Edge(plant, coord.add(plant, coord.new(1, 0))),
      Edge(coord.add(plant, coord.new(0, -1)), plant),
      Edge(plant, coord.add(plant, coord.new(0, 1))),
    ])
    |> set.symmetric_difference(perimeter)
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
