function hookfunction(func, rep)
	local env = getfenv(debug.info(2, 'f'))
	for i, v in pairs(env) do
		if v == func then
			env[i] = rep
			return rep
		end
	end
end
