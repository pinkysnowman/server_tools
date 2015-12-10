--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Set time by hours and minuites feature --------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("time", {
	params = "<0..23>:<0..59> <am|pm> | <0..24000> ",
	description = "set time of day",
	privs = {settime=true},
	func = function(name, param)
		local def,hr,min
		if param == "os" then
			local os_found, os_, os_hr, os_m, os_s, os_def = os.date("%X"):find("^([%d.-]+)[:] *([%d.-]+)[:] *([%d.-]+)[ ] *([%w%-]+)")
			hr = tonumber(os_hr) 
			min = tonumber(os_m)
			def = os_def
		else
			local found, _, h, m, d = param:find("^([%d.-]+)[:] *([%d.-]+)[ ] *([%w%-]+)")
			hr = tonumber(h) 
			min = tonumber(m)
			def = d
			if found == nil then
				local found2, _2, hr2, m2 = param:find("^([%d.-]+)[:] *([%d.-]+)")
				if found2 == nil then
					if param and param ~= "" then
						local time = tonumber(param)
						if not time or time > 24000 or time < 0 then
							return false, "Invalid time! Usage: <hour>:<minuite> <am / pm>"
						end
						minetest.set_timeofday((time % 24000) / 24000)
						minetest.log("action", name.." sets time to "..time)
						return true, "Time of day changed to "..time
					end
					return false,  "Missing time! Usage: <hour>:<minuite> <am / pm>"
				else
					hr = tonumber(hr2) 
					min = tonumber(m2)
					def = "am"
				end
			end
		end
		def = def:lower()
		if hr == nil or hr > 24 or hr < 0 
			or min == nil or min >= 60 or min < 0
			or (def ~= "am" and def ~= "pm") then 
			return false, "Invalid time! Usage: <hour : minuite> <am / pm>" 
		end 
		if def == "am" and hr == 12 then hr = hr - 12 end
		if def == "pm" and hr < 12 then hr = hr + 12 end
		minetest.set_timeofday((hr * 60 + min) / 1440)
		if min < 10 then min = "0"..min end
		minetest.log("action", name.." sets time "..hr..":"..min.." "..def)
		return true, "Time of day changed to "..hr..":"..min.." "..def
	end,
})
