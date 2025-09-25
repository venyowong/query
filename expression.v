module query

pub struct BaseExpression {
pub:
	key string
	ope Symbol
	value string
}

pub struct CompoundExpression {
pub mut:
	expressions []Expression
	symbols []Symbol
}

pub type Expression = BaseExpression | CompoundExpression

pub fn Expression.parse(exp string) !Expression {
	mut expression := CompoundExpression{}
	mut left_start_index := -1
	mut parenthesis_level := 0
	mut token_start_index :=-1
	mut expect_exp := 0 // 0 expression 1 symbol
	mut current_type := 0 // 0 none 1 key 2 symbol 3 value
	mut key := ""
	mut value := ""
	mut symbol := ""
	for i:= 0; i < exp.len; i++ {
		c := exp[i]
		match expect_exp {
			0 {
				match current_type {
					0 {
						match c {
							`(` {
								if parenthesis_level == 0 { // first left parenthesis
									left_start_index = i
									parenthesis_level++
								} else {
									parenthesis_level++
								}
							}
							`)` {
								if parenthesis_level == 0 {
									panic("unexpected symbols ) in pos $i of $exp")
								} else if parenthesis_level == 1 {
									str := exp[(left_start_index+1)..i]
									expression.expressions << Expression.parse(str)!
									expect_exp = 1
									left_start_index = -1
									parenthesis_level = 0
									parenthesis_level--
								} else {
									parenthesis_level--
								}
							}
							else {
								if parenthesis_level == 0 {
									token_start_index = i
									current_type = 1
								}
							}
						}
					}
					1 {
						match c {
							` ` {
								key = exp[token_start_index..i]
								current_type = 2
								token_start_index = -1
							}
							else {}
						}
					}
					2 {
						match c {
							` ` {
								if token_start_index != -1 {
									symbol = exp[token_start_index..i]
									current_type = 3
									token_start_index = -1
								}
							}
							else {
								if token_start_index == -1 {
									token_start_index = i
								}
							}
						}
					}
					3 {
						match c {
							` ` {
								if token_start_index != -1 {
									value = exp[token_start_index..i]
									expression.expressions << BaseExpression {
										key: key
										value: value
										ope: parse_symbol(symbol)!
									}
									current_type = 0
									expect_exp = 1
									token_start_index = -1
								}
							}
							else {
								if token_start_index == -1 {
									token_start_index = i
								}
							}
						}
					}
					else {
						panic("parse error, invalid current_type: $current_type")
					}
				}
				
			}
			1 {
				match c {
					` ` {
						if token_start_index != -1 {
							symbol = exp[token_start_index..i]
							expression.symbols << parse_symbol(symbol)!
							token_start_index = -1
							expect_exp = 0
						}
					}
					else {
						if token_start_index == -1 {
							token_start_index = i
						}
					}
				}
			}
			else {
				panic("parse error, invalid expect_exp: $expect_exp")
			}
		}
	}
	if current_type == 3 { // if the end of expression is value, should add expression to expression.expressions
		expression.expressions << BaseExpression {
			key: key
			value: exp[token_start_index..exp.len]
			ope: parse_symbol(symbol)!
		}
	}
	if left_start_index >= 0 { // if the end of expression is sub expression, should parse it and add expression to expression.expressions
		if parenthesis_level != 0 {
			panic("unable to find paired parentheses")
		}
		expression.expressions << Expression.parse(exp[left_start_index+1..exp.len-1])!
	}
	if expression.expressions.len != expression.symbols.len + 1 {
		panic("invalid expression: $expression.expressions.len $expression.symbols.len")
	}
	if expression.symbols.len == 0 {
		return expression.expressions[0]
	}
	return expression
}

fn parse_symbol(symbol string) !Symbol {
	match symbol.to_lower() {
		">" {return Symbol.gt}
		">=" {return Symbol.gte}
		"<" {return Symbol.lt}
		"<=" {return Symbol.lte}
		"==" {return Symbol.eq}
		"!=" {return Symbol.neq}
		"||" {return Symbol.or}
		"&&" {return Symbol.and}
		"in" {return Symbol.in}
		"like" {return Symbol.like}
		else {panic("invalid symbol: $symbol")}
	}
}