module query

pub enum Symbol {
	gt
	gte
	lt
	lte
	eq
	neq
	and
	or
	like
	in
}

pub enum ExpType {
	empty
	double_quotes
	key
	operator
	parenthesis
	single_quotes
	value
}