--[[
Copyright (c) 2012 Enrique CR

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
]]

--[[This Lua module simplifies the creation of prompt interfaces for user interaction with a program]]

local string = require("string")
local table = require("table")
local coroutine = require("coroutine")
local io = require("io")
local tostring = tostring

local base = _G

module("prompter")

local fn_tree=nil
local is_running=false


function tokenize(line)
	local tokens={}
	for token in string.gmatch(line, "[^%s]+") do
		table.insert(tokens,token)
	end
	return tokens
end

function call_function(fn, args)
	if base.type(args)=="table" then
		fn(base.unpack(args))
	else
		fn()
	end
end

function process_line(line)
	local fn=nil
	local tokens=tokenize(line)
	if #tokens > 0 then
		local name=tokens[1]
		local fn=fn_tree[name]
		if base.type(fn)=="function" then
			table.remove(tokens,1)
			call_function(fn,tokens)
		else
			if fn_tree.default ~= nil then 
				fn_tree.default(name)
				return
			end
		end
	end
end

function exit()
	is_running=false
end

function default(name)
	io.stderr:write("Function '" .. name .. "' is not available, available function are: ")
	for n,v in base.pairs(fn_tree) do
		if base.type(v) == "function" and n ~="default" then
			io.stderr:write(n .. " ")
		end
	end
	io.stderr:write("\n")
end

function run()
	if fn_tree == nil then 
		io.stderr:write("Must initialize [init()] prompter first!\n")
		return
	end
	is_running=true
	for line in io.stdin:lines() do
		process_line(line)
		if is_running == false then
			return
		end
	end
end

function init(function_tree)
	if function_tree ~= nil then
		fn_tree=function_tree
	else
		fn_tree={}
	end
	if fn_tree.default == nil then
		fn_tree.default=default
	end
	if fn_tree.exit ~= nil then
		if type(fn_tree.exit) == "table" then
			table.insert(fn_tree.exit,exit)
		else
			local ne={fn_tree.exit,exit}
			fn_tree.exit=ne
		end
	else
		fn_tree.exit=exit
	end
end