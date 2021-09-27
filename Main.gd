extends Panel

# returns 'null' in case of error
static func parse(texte: String):
	var tokens = tokenize(texte)
	if tokens == null:
		return null
	return parse_expr_bp(tokens, 0)

# returns 'null' in case of error
static func parse_expr_bp(tokens: Array, min_bp: int):
	var lhs
	match tokens.pop_front():
		null:
			print_debug("expected number, found EOF")
			return null
		var token:
			if token is float: lhs = token
			else:
				print_debug("expected number, found ", token)
				return null
	while true:
		var op = tokens.front()
		match op:
			'+', '-', 'x', '/': pass
			null: break
			_:
				print_debug("expected operand, found ", op)
				return null
		var l_bp
		var r_bp
		match infix_binding_power(op):
			[var l, var r]:
				l_bp = l
				r_bp = r
		if l_bp < min_bp:
			break
		tokens.pop_front()
		var rhs = parse_expr_bp(tokens, r_bp)
		if rhs == null:
			return null
		match op:
			'+': lhs = lhs + rhs
			'-': lhs = lhs - rhs
			'x': lhs = lhs * rhs
			'/': lhs = lhs / rhs
	return lhs

static func infix_binding_power(op: String):
	match op:
		'+', '-': return [1, 2]
		'x', '/': return [3, 4]
		_: print_debug("unknown operand: ", op)

static func tokenize(texte: String):
	var tokens = []
	var index = 0
	while index < texte.length():
		var c = texte[index]
		match c:
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
				match parse_nombre(texte, index):
					[null, _]: return null
					[var consumed, var nombre]:
						index += consumed
						tokens.append(nombre)
			'+', '-', 'x', '/', '(', ')':
				tokens.append(c)
				index += 1
			' ', '\t', '\n', '\r': index += 1
			_:
				print_debug("unknown character: ", c)
				return null
	return tokens

# Returns '[null, 0]' in case of error.
static func parse_nombre(texte: String, at: int):
	var resultat: float = 0
	var index: int = 0
	var after_comma: int = -1
	while at + index < texte.length():
		var caractere = texte[at + index]
		match caractere:
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
				resultat = resultat * 10 + int(caractere)
				index += 1
				if after_comma >= 0:
					after_comma += 1
			',':
				after_comma = 0
				index += 1
			_:
				break
	if index == 0:
		return [null, 0]
	else:
		if after_comma >= 0:
			resultat = resultat / pow(10, float(after_comma))
		return [index, resultat]

func _on_Entre_text_entered(new_text: String):
	var parsed = parse(new_text)
	if parsed == null:
		$Sortie.bbcode_text = "[center]ERREUR[/center]"
	else:
		$Sortie.bbcode_text = "[center]" + String(parsed).replace(".", ",") + "[/center]"
