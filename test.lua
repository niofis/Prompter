local prm=require("prompter")

local fns={}

fns.mesta=function (t)
	print((t or "") .. " mesta!")
end

prm.init(fns)
prm.run()