--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- White list function ---------------------------------------------------------------------
-- Add the line >> enable_whitelist = true to the .conf to enable this feature! ------------
--------------------------------------------------------------------------------------------

local enable = minetest.setting_getbool("enable_whitelist")
if enable == true then
	local world_path = minetest.get_worldpath()
	local admin = minetest.setting_get("name")
	local whitelist = {}

	local function load_whitelist()
		local file, err = io.open(world_path.."/thelist.txt", "r")
		if err then
			return
		end
		for line in file:lines() do
			whitelist[line] = true
		end
		file:close()
	end

	local function save_whitelist()
		local file, err = io.open(world_path.."/thelist.txt", "w")
		if err then
			return
		end
		for item in pairs(whitelist) do
			file:write(item.."\n")
		end
		file:close()
	end

	load_whitelist()

	minetest.register_on_prejoinplayer(function(name, ip)
		if name == "singleplayer" or name == admin or whitelist[name] then
			return
		end
		return "This server is private, you are not getting on!"
	end)

	minetest.register_chatcommand("whitelist", {
		params = "{add|remove} <nick>",
		help = "Manipulate the whitelist",
		privs = {admin=true},
		func = function(name, param)
			local action, whitename = param:match("^([^ ]+) ([^ ]+)$")
			if action == "add" then
				if whitelist[whitename] then
					return false, whitename..
						" is already good."
				end
				whitelist[whitename] = true
				save_whitelist()
				return true, "Added "..whitename.." to \"the list\"."
			elseif action == "remove" then
				if not whitelist[whitename] then
					return false, whitename.." is not on \"the list\"."
				end
				whitelist[whitename] = nil
				save_whitelist()
				return true, "Removed "..whitename.." from \"the list\"."
			else
				return false, "Invalid action."
			end
		end,
	})
	table.insert(server_tools.print_out, "\t>>>> Whitelist function loaded!")
else
	table.insert(server_tools.print_out, "\t>>>> Whitelist function will not be loaded!")
end
