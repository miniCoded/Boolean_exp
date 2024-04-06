local Token = {}

function Token:new(name, symbol)
	local o = {}

	for k, v in pairs(self) do
		o[k] = v
	end

	setmetatable(o, {
		__eq = function(a, b)
			if a.name == b.name and a.symbol == b.symbol then
				return true
			else
				return false
			end
		end
	})

	o.name = name
	o.symbol = symbol

	return o
end

Token.name = "NaN"
Token.symbol = 'X'

function Token:tostring()
	return self.name .. "(\'" .. self.symbol .. "\')"
end

return Token