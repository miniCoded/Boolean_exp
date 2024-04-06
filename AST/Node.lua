--[[
	Nodes contain their token, an operation (a function) and arguments toperform that operation
]]

local Node = {}

function Node:new(name, token, op, ...)
	local o = {}

	for k, v in pairs(self) do
		o[k] = v
	end

	setmetatable(o, {})

	o.name = name
	o.token = token
	o.op = op
	o.args = {}

	for _, v in pairs({...}) do
		table.insert(o.args, v)
	end

	return o
end

return Node