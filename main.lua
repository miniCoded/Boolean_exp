-- Team 10B

local BoolExp = require("Boolean_exp.BoolExp")

local exp = "AC + (A'(C+BD))'(DA + C) + B'D"

local vars, root = GetVars(exp, Tokenize(exp))