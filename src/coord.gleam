import gleam/int

pub type Coord {
  Coord(x: Int, y: Int)
}

pub fn new(x: Int, y: Int) -> Coord {
  Coord(x, y)
}

pub fn from_pair(pair: #(Int, Int)) -> Coord {
  Coord(pair.0, pair.1)
}

pub fn origin() -> Coord {
  Coord(0, 0)
}

pub fn add(a: Coord, b: Coord) -> Coord {
  map2(a, b, int.add)
}

pub fn subtract(a: Coord, b: Coord) -> Coord {
  map2(a, b, int.subtract)
}

pub fn max(a: Coord, b: Coord) -> Coord {
  map2(a, b, int.max)
}

fn map2(a: Coord, b: Coord, f: fn(Int, Int) -> Int) {
  Coord(f(a.x, b.x), f(a.y, b.y))
}

pub fn map3(a: Coord, b: Coord, c: Coord, f: fn(Int, Int, Int) -> Int) {
  Coord(f(a.x, b.x, c.x), f(a.y, b.y, c.y))
}

pub fn is_inside(p: Coord, size: Coord) -> Bool {
  p.x >= 0 && p.y >= 0 && p.x < size.x && p.y < size.y
}
