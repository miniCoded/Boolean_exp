--[[
	The AST (Abstract Syntax Tree) generates a tree which contains nodes that represent the operations to be done.
	Each node contains:
	- A token that indicats what it is
	- The arguments to be passed to it
	- The operation
	The up-most node contains the operation of least precedence and is the one to return the result

	In the case of Boole algebra, these are the operations:
	- Parenthesis ()
	- NOT (')
	- AND (*)
	- OR (+)
]]
--[[
	The AST works as a recursive process: a pass per operator will be made, starting from the least precedence.
	If a match of that operator is found, then a node will be created with that operator and it's arguments will be
	whatver is on the left and whaever is on the right (both an Identity operation [A=A]). After that, the function will
	be executed again per argument. Once there are no more matches, the function will end.

	This is the precedence: OR->AND->NOT->()
]]
local Token = require("Boolean_exp.Token")
local Node = require("Boolean_exp.AST.Node")

local token_list = {
	Token:new("OR", '+'),
	Token:new("AND", '*'),
	Token:new("NOT", '\''),
	Token:new("L_BRACKET", '('),
	Token:new("R_BRACKET", ')'),
}

local precedence = {
	Token:new("OR", '+'),
	Token:new("AND", '*'),
	Token:new("NOT", '\''),
	Token:new("L_BRACKET", '('),
}

function Gen_AST(tokens)
	-- Start of the list of tokens
	local s = 1
	-- End of the list of tokens
	local e = #tokens

	-- The new node to return
	local n = nil
	-- The left (or only) argument of the operator
	local l_arg = {}
	-- The right argument of the operator
	local r_arg = {}

	-- Iterate over all operator in precedence. If the end is reached and no operator has been matched, 
	-- then the token must be an argument (variable)
	for _, p in pairs(precedence) do
		-- Count of bracket depth
		local b_count = 0
		-- Ignore whatever is inside the brackets
		local i_bracket = false

		-- If the operator is not a bracket
		if p ~= precedence[4] then

			-- If the precedence token is OR or AND
			if p == precedence[1] or p == precedence[2] then
				-- Iterate over the current tokens
				for t = 1, e, 1 do
					-- Current token
					local c_token = tokens[t]

					-- If a left bracket is reached, increase the bracket count and ignore whatever is
					-- inside those brackets
					if c_token == token_list[4] then
						b_count = b_count + 1
						i_bracket = true
					-- If a right bracket is reached, decrease the counter
					elseif c_token == token_list[5] then
						b_count = b_count - 1
					end
					-- If the counter has reached 0, then stop ignoring
					if b_count == 0 then
						i_bracket = false
					end

					-- If a matching operator has been found and not ignoring brackets
					if c_token == p and not i_bracket then
						-- Fill the left argument with whatever is to the left of the operator
						for i = s, t-1, 1 do
							table.insert(l_arg, tokens[i])
						end
						-- Fill the right argumet with whatever is to the right of the operator
						for i = t+1, e, 1 do
							table.insert(r_arg, tokens[i])
						end

						-- Recursively, generate a new AST for the left and right arguments
						l_arg = Gen_AST(l_arg)
						r_arg = Gen_AST(r_arg)

						-- Generate and OR node
						if p == precedence[1] then
							n = Node:new("OR", c_token, function (a, b)
								if a == '0' and b == '0' then
									return '0'
								else
									return '1'
								end
							end, l_arg, r_arg)
						-- Otherwise, generate an AND node
						else
							n = Node:new("AND", c_token, function (a, b)
								if a == '1' and b == '1' then
									return '1'
								else
									return '0'
								end
							end, l_arg, r_arg)
						end

						return n
					end
				end
			-- If neither of those, then is NOT
			else
				-- In this case, since NOT is a suffix operator, it should evaluate from right to left
				for t = e, s, -1 do
					local c_token = tokens[e]

					-- The same behaviour, but flipped
					-- During debugging, the counter will appear negative, but it's OK
					--[[if c_token == token_list[4] then
						b_count = b_count + 1
					elseif c_token == token_list[5] then
						b_count = b_count - 1
						i_bracket = true
					end
					if b_count == 0 then
						i_bracket = false
					end]]

					-- Also, NOT is an uniary operator, meaning that it only takes one argument
					if c_token == p and not i_bracket then
						for i = 1, e-1, 1 do
							table.insert(l_arg, tokens[i])
						end
						l_arg = Gen_AST(l_arg)
	
						n = Node:new("NOT", c_token, function (a)
							if a == '1' then
								return '0'
							else
								return '1'
							end
						end, l_arg)
						return n
					end
				end
			end
		-- If not, then the precedence token is L_BRACKET and it must mean that, whatever is
		-- tokens, it is inside a bracket
		elseif p == precedence[4] and tokens[1] == p then
			for i = s+1, e-1, 1 do
				table.insert(l_arg, tokens[i])
			end

			l_arg = Gen_AST(l_arg)

			n = Node:new("ID", Token:new("ID", "°"), function (a)
				return a
			end, l_arg)

			return n
		end
	end

	n = Node:new(tokens[1].symbol, tokens[1], function (a)
		return a
	end)

	return n
end

return {Gen_AST}