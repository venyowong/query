module main

import query

fn main() {
	println(query.Query.parse("key1 == value1 || key2 > value2 && key3 < value3 && (key4 in ['value4'] || (key5 like value5))") or {
		return error(err)
	})
}
