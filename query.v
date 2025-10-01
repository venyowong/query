module query

pub struct NoneQuery {}

pub struct EmptyQuery {}

pub struct BaseQuery {
pub:
	key string
	ope Symbol
	value string
}

pub struct CompoundQuery {
pub mut:
	left Query
	right Query
	ope Symbol
}

pub type Query = NoneQuery | EmptyQuery | BaseQuery | CompoundQuery

pub fn Query.new(key string, ope Symbol, value string) Query {
	return BaseQuery {
		key: key
		ope: ope
		value: value
	}
}

pub fn Query.parse(exp string) !Query {
	if exp.len == 0 {
		return EmptyQuery{}
	}

	expression := Expression.parse(exp)!
	return expression_to_query(expression)
}

pub fn (q1 Query) and(q2 Query) Query {
	return CompoundQuery {
		left: q1
		right: q2
		ope: Symbol.and
	}
}

pub fn (q1 Query) or(q2 Query) Query {
	return CompoundQuery {
		left: q1
		right: q2
		ope: Symbol.or
	}
}

pub fn (q1 BaseQuery) and(q2 Query) Query {
	return CompoundQuery {
		left: q1
		right: q2
		ope: Symbol.and
	}
}

pub fn (q1 BaseQuery) or(q2 Query) Query {
	return CompoundQuery {
		left: q1
		right: q2
		ope: Symbol.or
	}
}

pub fn (q1 CompoundQuery) and(q2 Query) Query {
	return CompoundQuery {
		left: q1
		right: q2
		ope: Symbol.and
	}
}

pub fn (q1 CompoundQuery) or(q2 Query) Query {
	return CompoundQuery {
		left: q1
		right: q2
		ope: Symbol.or
	}
}

fn expression_to_query(exp Expression) !Query {
	match exp {
		BaseExpression {
			return BaseQuery {
				key: exp.key
				ope: exp.ope
				value: exp.value
			}
		}
		CompoundExpression {
			// convert all expressions to queries
			mut queries := []Query{}
			for x in exp.expressions {
				queries << expression_to_query(x)!
			}

			mut len := exp.symbols.len
			for i := 0; i < len; {
				if exp.symbols[i] != Symbol.and {
					i++
					continue
				}

				println(i)
				queries[i] = queries[i].and(queries[i + 1]) // and
				for j := i + 1; j < len; j++ { // move query
					queries[j] = queries[j + 1]
				}
				len--
			}

			for i := 0; i < len; {
				if exp.symbols[i] != Symbol.or {
					return error("unexpected symbol: ${exp.symbols[i]}")
				}

				println(i)
				queries[i] = queries[i].or(queries[i + 1]) // or
				for j := i + 1; j < len; j++ { // move query
					queries[j] = queries[j + 1]
				}
				len--
			}

			return queries[0]
		}
	}
}