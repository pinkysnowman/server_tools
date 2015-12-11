--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Playername filtering function -----------------------------------------------------------
-- Add the line >> disable_playername_filter = false to the .conf to disable this feature! -
--------------------------------------------------------------------------------------------

local disable = minetest.setting_getbool("disable_playername_filter")
if disable ~= true then
	minetest.register_on_prejoinplayer(function(name, ip)
		local lname = name:lower()
		for filter, reason in pairs(server_tools.disallowed_names) do
			if lname:find(filter) and name ~= server_tools.owner then
				return reason
			end
		end
	end)
	table.insert(server_tools.print_out, "\t>>>> Playername filtering Loaded!\n\t"
									   .."     *Owner \""..server_tools.owner.."\" exempted!")
else
	table.insert(server_tools.print_out, "\t>>>> Playername filtering not Loaded!")
end

--------------------------------------------------------------------------------------------
-- Playername "CASE" sensitive function ----------------------------------------------------
-- Add the line >> disable_playername_case = false to the .conf to disable this feature! ---
--------------------------------------------------------------------------------------------

local enable = minetest.setting_getbool("enable_playername_case")
if enable == true then
	minetest.register_on_prejoinplayer(function(name, ip)
		local lname = name:lower()
		for iname, data in pairs(minetest.auth_table) do
			if iname:lower() == lname and iname ~= name then
				return "Sorry, someone else is already using this"
					.." name.  Please pick another name."
					.."  Another posibility is that you used the"
					.." wrong case for your name."
			end
		end
	end)
	table.insert(server_tools.print_out, "\t>>>> Playername \"CASE\" sensitive Loaded!")
else
	table.insert(server_tools.print_out, "\t>>>> Playername \"CASE\" sensitive not Loaded!")
end
