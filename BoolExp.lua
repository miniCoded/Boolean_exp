--[[
	Parts of the program:
	- Lex: convert characters and symbols into tokens that can be worked with
	- Parse: convert those tokens into an AST. Also, detect syntax errors
	- Exect: travel along the AST, computing the calculations
]]

--[[
	This is the list of operations:
	- Identity: A, (), ()()
	- NOT: A', ()'
	- AND: AB, A()
	- OR: A+B

	The order is:
	- Parenthesis
	- NOT
	- AND
	- OR
	]]
local Token = require("Boolean_exp.Token")
local AST = require("Boolean_exp.AST.AST")

-- Lexer. Turns the source code into a list of tokens that the program can understand.
function Tokenize(src)
	-- Trimm all spaces and tabs
	src = string.gsub(src, " ?	?", "")
	src = string.upper(src)

	local tokens = {}

	do
		local i = 1
		while i <= #src do
			local c_char = string.sub(src, i, i)
			local is_var = function (c)
				return string.byte(c) >= 65 and string.byte(c) <= 90
			end
			local next = string.sub(src, i+1, i+1)
			if c_char == '+' then
				table.insert(tokens, Token:new("OR", '+'))
			elseif c_char == '\'' then
				table.insert(tokens, Token:new("NOT", '\''))
			elseif c_char == '(' then
				table.insert(tokens, Token:new("L_BRACKET", '('))
			elseif c_char == ')' then
				table.insert(tokens, Token:new("R_BRACKET", ')'))
			elseif is_var(c_char) then
				table.insert(tokens, Token:new("VAR", c_char))
			end
			if i < #src and (is_var(c_char) or c_char == ')' or c_char == '\'') and (is_var(next) or next == '(') then
				table.insert(tokens, Token:new("AND", "*"))
			end
			
			i = i + 1
		end
	end

	return tokens
end

-- Get the variables
function GetVars(exp, tokens)
	if not exp and not tokens then
		return false
	end

	local variables = {}
	exp = string.upper(exp)
	for i = 1, #exp, 1 do
		local c_char = string.sub(exp, i, i)
		local exists = false
		if string.byte(c_char) >= 65 and string.byte(c_char) <= 90 then
			local n_var = Token:new("VAR", c_char)
			for j = 1, #variables, 1 do
				if variables[j] == n_var then
					exists = true
					break
				end
			end
			if not exists then
				table.insert(variables, n_var)
			end
		end
	end

	table.sort(variables, function (a, b)
		if string.byte(a.symbol) < string.byte(b.symbol) then
			return true
		else
			return false
		end
	end)

	return variables, Gen_AST(tokens)
end

-- Generate the solution
function Parse(vars, node, ...)
	local args = ...
	if #args ~= #vars then
		return false
	end

	if #node.args == 0 then
		for i = 1, #vars, 1 do

			if node.token == vars[i] then
				return args[i]
			end
		end
	elseif #node.args == 1 then
		local res = node.op(Parse(vars, node.args[1], args))

		return res
	elseif #node.args == 2 then
		local res = node.op(Parse(vars, node.args[1], args), Parse(vars, node.args[2], args))

		return res
	end
end

return {Tokenize, GetVars, Parse}