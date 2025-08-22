local addr="10.0.0.10"
if string.match(addr, "%a") then
	print("yep")
else
	print("nope")
end

local addr="2A03:6ee2:1232:123"
if string.match(addr, "%a") then
	print("yep")
else
	print("nope")
end

