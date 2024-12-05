import atto.{type Parser}

pub fn sep_by(
  left: Parser(a, t, s, c, e),
  sep: Parser(_, t, s, c, e),
  right: Parser(b, t, s, c, e),
) -> Parser(#(a, b), t, s, c, e) {
  use l <- atto.do(left)
  use <- atto.drop(sep)
  use r <- atto.do(right)
  atto.pure(#(l, r))
}

pub fn non_consuming(a: Parser(a, t, s, c, e)) {
  fn(in, pos, ctx) {
    case a.run(in, pos, ctx) {
      Ok(x) -> Ok(x)
      Error(atto.ParseError(span, got, expected)) ->
        Error(atto.ParseError(atto.Span(..span, start: pos), got, expected))
      Error(atto.Custom(span, v)) ->
        Error(atto.Custom(atto.Span(..span, start: pos), v))
    }
  }
  |> atto.Parser
}
