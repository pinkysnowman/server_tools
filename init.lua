--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.0 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
-- This mod adds some useful features and comands to the game as well as an optional      --
-- profanity and language filter that over rides the /me and /msg functions to help block --
-- un desired messages from being sent, also it reports violations to the minetest log!   --
--                                                                                        --
-- The mod also adds a time and lag hud, white list for players, the ability to kill or   --
-- set a players hp, the ability to look a players IP address, the ability to get players --
-- location, the ability to see what a player is weilding, the ability to remove a        --
-- players weild item, the ability to search a players inventory for an item, the ability --
-- to remove an item(s) from a players inventory, the ability to set time by the          --
-- "HH:MM am/pm" format, the ability to only let admin use "/privs" to view others        --
-- privileges, the ability to empty a players inventory list by "item_list" name, the     --
-- ability to set nametag colors of owner, admin and moderators, a full GUI player info   --
-- display and the ability to set up to 5 different /spawn locations.                     --
--                                                                                        --
-- Mod is fully compatable with the unified_inventory gui and adds functions to it!       --
--                                                                                        --
-- The white list, time and lag HUD, "/empty_inv" feature, "/privs" blocker function,     --
-- colored nametags function, selective PvP function and profanity filter can be disabled --
-- or enabled via the .conf                                                               --
--                                                                                        --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Load settings file ----------------------------------------------------------------------
--------------------------------------------------------------------------------------------
server_tools = {}
dofile(minetest.get_modpath("server_tools").."/settings.txt")
if not server_tools.settings then
	print("\n[MOD] [server_tools ver: 2.0] [WARNING] Mod can not initialize, missing \""..
		""..minetest.get_modpath("server_tools").."/settings.txt\"!!!!!!\n")
	return
end
print("========================================================================\n"..
	  "[MOD] [server_tools ver: 2.0] Mod initializing.....\n")

local function explode(sep, input)
	local t={}
	local i=0
	for k in string.gmatch(input,"([^"..sep.."]+)") do
		t[i]=k;i=i+1
	end
	return t
end

--------------------------------------------------------------------------------------------
-- Admin and moderator privs ---------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_privilege("admin", {
	description = "BAWS AF!", 
	give_to_singleplayer = true
})

minetest.register_privilege("mod", {
	description = "Moderator priv", 
	give_to_singleplayer = true
})

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

--------------------------------------------------------------------------------------------
-- "/privs" check blocker function ---------------------------------------------------------
-- Add the line >> enable_privs_check_block = true to the .conf to enable this feature! ----
--------------------------------------------------------------------------------------------

local enable = minetest.setting_getbool("enable_privs_check_block")
if enable == true then
	minetest.register_chatcommand("privs", {
		params = "<name>",
		description = "print out privileges of player",
		func = function(name, param)
			if param ~= ( "" or nil ) 
				and not minetest.check_player_privs(name, {privs=true})
				and not minetest.check_player_privs(name, {server=true})
				and not minetest.check_player_privs(name, {admin=true}) then
				return false, "Your privileges are insufficient to view others privileges!"
			end
			param = (param ~= "" and param or name)
			return true, "Privileges of "..param..": "
				..minetest.privs_to_string(minetest.get_player_privs(param), ' ')
		end,
	})
	print("\t>>>> \"/privs\" check will require admin level privileges!\n")
end

--------------------------------------------------------------------------------------------
-- GUI Player info feature -----------------------------------------------------------------
--------------------------------------------------------------------------------------------
--***in progress***

minetest.register_chatcommand("info", {
	params = "<playername> | leave playername empty to see your info",
	description = "Shows players information.",
	privs = {admin=true},
	func = function(name, param)
		server_tools.info_form(name, param)
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	local f_privs = minetest.get_player_privs(fields.param or name)
	local f_player,f_priv
	local message = "     Entry box"
	if formname ~= "server_tools:info_form" then return end
	if fields.exit then return 
	elseif fields.revoke then
		if fields.input ~= "" then f_priv = fields.input else f_priv = "na" end
		if not minetest.registered_privileges[f_priv] then
			message = "Unknown privilege"
		else
			f_privs[f_priv] = nil
			minetest.set_player_privs(fields.param, f_privs)
		end
		server_tools.info_form(name, fields.param, message)

	elseif fields.grant then
		if fields.input ~= "" then f_priv = fields.input else f_priv = "na" end
		if not minetest.registered_privileges[f_priv] then
			message = "Unknown privilege"
		else
			f_privs[f_priv] = true
			minetest.set_player_privs(fields.param, f_privs)
		end
		server_tools.info_form(name, fields.param, message)
		elseif fields.ch_player then
		if fields.input ~= "" then 
			f_player = fields.input 
		else 
			f_player = fields.param 
			message = "  Entry box blank"
		end
		if not minetest.get_player_by_name(f_player) then 
			--minetest.chat_send_player(name, f_player.." is not online.") 
			f_player = name
			message = " Player is offline"
		end
		server_tools.info_form(name, f_player, message)
	end
end)

function server_tools.info_form(name, param, text)
	if not param or param == "" then param = name end
	if minetest.get_player_by_name(param) then
		local msg = text or "     Entry box"
		local player = minetest.get_player_by_name(param)
		local physics = player:get_physics_override()
		local info = minetest.get_player_information(param)
		local pos = player:getpos()
		local px = math.floor(pos.x, 1)
		local py = math.floor(pos.y, 1)
		local pz = math.floor(pos.z, 1)
		local skin, dskin
		if minetest.get_modpath("player_textures") then
			local skin_file = minetest.get_modpath("player_textures").."/textures/player_"..param..".png"
			local is_skin = io.open(skin_file)
			if is_skin then
				is_skin:close()
				skin = "player_"..param..".png"
				dskin = ""
			elseif minetest.get_modpath("skins") then
				local mod_skin = skins.skins[param]
				if mod_skin and skins.get_type(mod_skin) == skins.type.MODEL then
					skin = mod_skin..".png"
					dskin = ""
				else
					skin = "character.png"
					dskin = "Default skin!"
				end
			else
				skin = "character.png"
				dskin = "Default skin!"
			end
			local inv_list = "#0000ccMain:"
			local item = player:get_wielded_item():get_name()
			for i = 1, 32 do
				local t_color = ""
				local stack = player:get_inventory():get_stack("main", i)
				local item_name = stack:get_name()
				if item_name and item_name ~= "" then
					for search, color in pairs(server_tools.inv_hl) do
						if item_name:find(search) then
							t_color = color
						end
					end
					if minetest.get_item_group(item_name, "not_in_creative_inventory") == 1 
						or minetest.registered_items[item_name]["description"] == "" then
						t_color = t_color.."!!"
					end
					if item == item_name then
						inv_list = inv_list..","..t_color.."*"..item_name.."*"
					else
						inv_list = inv_list..","..t_color..item_name
					end
				end
			end
			inv_list = inv_list..",#0000ccCraft:"
			for i = 1, 9 do
				local t_color = ""
				local stack = player:get_inventory():get_stack("craft", i)
				local item_name = stack:get_name()
				if item_name and item_name ~= "" then
					for search, color in pairs(server_tools.inv_hl) do
						if item_name:find(search) then
							t_color = color
						end
					end
					if minetest.get_item_group(item_name, "not_in_creative_inventory") == 1 
						or minetest.registered_items[item_name]["description"] == "" then
						t_color = t_color.."!!"
					end
					inv_list = inv_list..","..t_color..item_name
				end
			end
			minetest.show_formspec(name, "server_tools:info_form", table.concat({
				"size[10,6]",
				"background[-0.25,-0.25;10.5,6.75;server_tools_bg.png^server_tools_overlay.png]",
				"label[0.1, 0.00;Connection]",
				"label[0.1, 0.25;IP address: "..info.address.."]",
				"label[0.1, 0.50;IP ver: "..info.ip_version.."]",
				"label[0.1, 0.75;Min rtt: "..info.min_rtt.."]",
				"label[0.1, 1.00;Max rtt: "..info.max_rtt.."]",
				"label[0.1, 1.25;Avg rtt: "..info.avg_rtt.."]",
				"label[0.1, 1.50;Time logged in: "..info.connection_uptime.."]",
				"label[3.75,-0.07;Player: "..param.."]",
				"label[6.575, 0.0;Skin                   "..dskin.."]",
				"image[6.575,0.075;4.0,2.1;"..skin.."]",
				"label[0.1, 2.25;Stats]",
				"label[0.1, 2.50;HP: "..player:get_hp().."]",
				"label[0.1, 2.75;Breath: "..player:get_breath().."]",
				"label[0.1, 3.00;Location: ("..px..", "..py..", "..pz..")]",
				"label[0.1, 3.25;Speed: "..tostring(physics.speed).."]",
				"label[0.1, 3.50;Jump: "..tostring(physics.jump).."]",
				"label[0.1, 3.75;Gravity: "..tostring(physics.gravity).."]",
				"label[0.1, 4.00;Sneak: "..tostring(physics.sneak).."]",
				"label[0.1, 4.25;Sneak glitch: "..tostring(physics.sneak_glitch).."]",
				"textlist[6.5,2.3;3.3,2.35;inventory;"..inv_list..";0;true]",
				"textlist[3.7,0.65;2.4,4.0;privs;#0000ccPrivs:,   ",
					minetest.privs_to_string(minetest.get_player_privs(param), ',   ')..";0;true]",
				"label[6.9, 4.95;Admin items]",
				"label[6.9, 5.21;Dangerous items]",
				"label[6.9, 5.48;Weilded item]",
				"label[6.9, 5.73;Not in creative items]",
				"image_button_exit[0.1,5.1;1.75,0.5;server_tools_btn_.png;exit;Close]",
				"image_button_exit[1.7,5.1;1.75,0.5;server_tools_btn_.png;ch_player;Change Player]",
				"image_button_exit[0.1,5.65;1.75,0.5;server_tools_btn_.png;grant;Grant]",
				"image_button_exit[1.7,5.65;1.75,0.5;server_tools_btn_.png;revoke;Revoke]",
				"label[4.2, 5.0;"..msg.."]",
				"field[4.07, 5.6;2.5,1.0;input;;]",
				"field[4.07, -5.6;2.5,1.0;param;;"..param.."]",
				""
			}))
		else
			return false, param.." is not online."
		end
	end
end

if unified_inventory then
	unified_inventory.register_button("server_tools_player_info", {
		type = "image",
		image = "server_tools_info.png",
		action = function(player)
			local name = player:get_player_name()
			if minetest.check_player_privs(name, {admin=true}) then
				server_tools.info_form(name)
			else
				minetest.chat_send_player(name,"This feature requires admin privilege!")
			end
		end,
	})
	print("\t>>>> unified_inventory button for player information is available!\n")

end

print("\t>>>> GUI for player information is available!\n")

--------------------------------------------------------------------------------------------
-- IP look up feature ----------------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("ip", {
	params = "<playername> | leave playername empty to see your IP",
	description = "Shows IP address.",
	privs = {admin=true},
	func = function(name, param)
		if not param or param == "" then param = name end
		if minetest.get_player_by_name(param) then
			return true, "IP address of "..param.." is "..minetest.get_player_ip(param)
		else
			return false, param.." is not online."
		end
	end
})

--------------------------------------------------------------------------------------------
-- whereis feature -------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("whereis", {
	params = "<playername>",
	description = "Shows a players location.",
	privs = {admin=true},
	func = function(name, param)
		if not param or param == "" then 
			return false, "Usage: /whereis <playername> "
		end
		local player = minetest.get_player_by_name(param)
		if player then
			local pos = player:getpos()
			local px = math.floor(pos.x, 1)
			local py = math.floor(pos.y, 1)
			local pz = math.floor(pos.z, 1)
			return true, "Location of "..param.." is ("..px.." "..py.." "..pz..")"
		else
			return false, param.." is not online."
		end
	end
})

--------------------------------------------------------------------------------------------
-- wherewas feature ------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

local pl_was = {}
local pl_was_changed = false
local pl_was_file = minetest.get_worldpath() .. "/pl_was.plf"

local function load_pl_was()
	local input = io.open(pl_was_file, "r")
	if input then
		repeat
			local line_out = input:read("*l")
			if line_out == nil then
				break
			end
			local found, _, name, pos = line_out:find("^([^%s]+)%s+(.+)$")
			if not found then
				return
			end
			pl_was[name] = minetest.string_to_pos(pos)
		until input:read(0) == nil
		io.close(input)
	end
end

load_pl_was()

local function save_pl_was()
	local output = io.open(pl_was_file, "w")
	local data = {}
	for i, v in pairs(pl_was) do
		table.insert(data,string.format("%s %.1f %.1f %.1f", i,v.x,v.y,v.z))
	end
	output:write(table.concat(data,"\n"))
	io.close(output)
	return
end

minetest.register_chatcommand("wherewas", {
	params = "<playername>",
	description = "Shows a players last known location.",
	privs = {admin=true},
	func = function(name, param)
		if not param or param == "" then 
			return false, "Usage: /wherewas <playername> "
		end
		local pos = pl_was[param]
		if pos then
			local px = math.floor(pos.x, 1)
			local py = math.floor(pos.y, 1)
			local pz = math.floor(pos.z, 1)
			return true, "Last known location of "..param.." is ("..px.." "..py.." "..pz..")"
		else
			return false, param.." doesn't have a last know location. Player may still be online, try using /whereis."
		end
	end
})

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	local pos = player:getpos()
	pl_was[name] = pos
	pl_was_changed = true
end)

minetest.register_on_shutdown(function()
	save_pl_was()
end)

minetest.register_globalstep(function ( dtime )
	if pl_was_changed == true then
		save_pl_was()
		pl_was_changed = false
	end
end)

--------------------------------------------------------------------------------------------
-- Weild item lookup feature ---------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("weild", {
	params = "<playername>",
	description = "Shows what a players weild item is.",
	privs = {admin=true},
	func = function(name, param)
		if minetest.get_player_by_name(param) or not param or param == "" then
			local item = minetest.get_player_by_name(param):get_wielded_item():get_name()
			if item == "" then item = ".....nothing?" end
			return true, param.." is holding a "..item
		else
			return false, param.." is not online."
		end
	end
})

--------------------------------------------------------------------------------------------
-- Remove weild item feature ---------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("removeweild", {
	params = "<playername>",
	description = "Removes a players weild item!",
	privs = {admin=true},
	func = function(name, param)
		local item = minetest.get_player_by_name(param):get_wielded_item()
		local itemname = item:get_name()
		if item == ( "" or nil or ":" ) or not item then 
			return false, "There is no weild item to remove!"
		end
		if minetest.get_player_by_name(param) or not param or param == "" then
			minetest.get_player_by_name(param):set_wielded_item(nil)
			minetest.log("action", name.." has removed "..param.."'s \""..itemname.."\"!")
			minetest.chat_send_player(param, "Your \""..itemname.."\" was removed by an admin!")
			return true, param.."'s \""..itemname.."\" was removed!"
		else
			return false, param.." is not online."
		end
	end
})

--------------------------------------------------------------------------------------------
-- Player inventory look up feature --------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("search_inv", {
	params = "<playername> <itemname>",
	description = "Searches players inventory for an item.",
	privs = {admin=true},
	func = function(name, param)
		if param == "" then
			return false, "Usage: /search_inv <playername> <itemname>"
		end
		local found, _, player, itemname = param:find("^([^%s]+)%s+(.+)$")
		if found == nil then
			return false, "invalid usage!"
		end
		if not minetest.get_player_by_name(player) then
			return false, player.." is not online."
		end
		if minetest.get_player_by_name(player):get_inventory():contains_item("main", itemname) then
			return true, player.." has the item \""..itemname.."\" in their inventory!"
		else
			return true, player.." doesn't have a \""..itemname.."\" in their inventory!"
		end
	end
})

--------------------------------------------------------------------------------------------
-- Player inventory remove item feature ----------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("remove_inv", {
	params = "<playername> <itemname> <amount>",
	description = "Searches players inventory for an item.",
	privs = {admin=true},
	func = function(name, param)
		if param == "" then
			minetest.chat_send_player(name, "Usage: /remove_inv <playername> <itemname> <optional amount>")
			return
		end
		local found, _, player, itemname, amount = param:find("^([^%s]+)%s+(.+)$")
		if found == nil then
			worldedit.player_notify(name, "Usage: /remove_inv <playername> <itemname> <optional amount>")
			return
		end
		if not minetest.get_player_by_name(player) then
			minetest.chat_send_player(name, player.." is not online.")
			return
		end
		if minetest.get_player_by_name(player):get_inventory():contains_item("main", itemname) then
			if not amount then amount = "" end
			minetest.chat_send_player(name, "\""..itemname.."\" has been removed from "..player.."'s inventory!")
			minetest.chat_send_player(player, "\""..itemname.."\" has been removed from your inventory by an admin!")
			minetest.log("action", "\""..itemname.."\" has been removed from "..player.."'s inventory by "..name.."!")
			if amount == "" then amount = 65535 end
			minetest.get_player_by_name(player):get_inventory():remove_item("main", itemname.." "..amount)
		else
			minetest.chat_send_player(name, player.." doesn't have a \""..itemname.."\" in their inventory!")
		end
	end
})

--------------------------------------------------------------------------------------------
-- Player inventory list empty feature -----------------------------------------------------
-- Add the line >> enable_empty_inv = true to the .conf to disable this feature! -----------
--------------------------------------------------------------------------------------------

local disable = minetest.setting_getbool("enable_empty_inv")
if disable == true then
	minetest.register_chatcommand("empty_inv", {
		params = "<player> <list>",
		description = "Destroys all items in players inventory ,crafting grid or other items list.",
		privs = {admin=true},
		func = function(name, param)
			local found, _, player, list = param:find("^([^%s]+)%s+(.+)$")
			if list ~= "main" and list ~= "craft" then
				return false, "You must specify the item list to clear! ex: \"main\", \"craft\" or other list."
			end
			local plname = minetest.get_player_by_name(player)
			if not plname or plname == name then
				return false, "Can not empty!!!"
			end
			local inv = plname:get_inventory()
			inv:set_list(list, {})
			minetest.chat_send_player(player, "Your item list \""..list.."\" has been cleared by an admin!")
			minetest.log("action", player.."'s item list \""..list.."\" has been cleared by "..name.."!")
			return true, player.."'s item list \""..list.."\" has been cleared!"
		end,
	})
	print("\t>>>> \"/empty_inv\" command Loaded!\n\t     Admin can now clear a players inventory list!\n")
end

--------------------------------------------------------------------------------------------
-- Player Kill and HP setting --------------------------------------------------------------
--------------------------------------------------------------------------------------------

local enable = minetest.setting_getbool("enable_damage")
if enable == true then
	minetest.register_chatcommand("kill", {
	    params = "<playername>",
	    description = "The player will be klled immediately",
	    privs = {admin=true},
	    func = function(name, param)
	        if param == "" then
	            return false, "Usage: /kill <playername>"
	        end
	        if minetest.get_player_by_name(param) then
	        	minetest.get_player_by_name(param):set_hp(0)
	            minetest.chat_send_player(param, "An admin has killed you!")
	            minetest.log("action", name.." has killed "..param..".")
	            return true, param.." has been killed."
	        elseif not minetest.get_player_by_name(param) then
	        	return false, param.." isn't online."
	        end
	    end
	})

	minetest.register_chatcommand("killme", {
	    description = "Kills you immediately",
	    privs = {interact=true},
	    func = function(name, param)
	        if minetest.get_player_by_name(name) then
	        	minetest.get_player_by_name(name):set_hp(0)
	            return true, "You have been killed."
	        end
	    end
	})

	minetest.register_chatcommand("sethp", {
	    params = "<playername> <value>",
	    description = "Allows to set a player's HP.",
	    privs = {admin=true},
	    func = function(name, param)
	        if param == "" then
	            return false, "Usage: /sethp <playername> <value 1-20>"
	        end
	        local user, hp = string.match(param, " *([%w%-]+) *(%d*)")
	        hp = tonumber(hp)
	        if hp == nil or hp == "" or hp >20 or hp <= 1 then
	            return false, "Usage: /sethp <playername> <value 1-20>"
	        end
	        if minetest.get_player_by_name(user) then
	            minetest.get_player_by_name(user):set_hp(hp)
	            minetest.chat_send_player(user, name.." set your hp to "..hp.."!")
	            minetest.log("action", name.." has set "..user.."'s HP to "..hp..".")
	            return true, user.."'s HP set to "..hp.."."
	        elseif not minetest.get_player_by_name(user) then
	        	return false, user.." isn't online."
	        end
	    end
	})

	print("\t>>>> \"/kill\", \"/killme\" and \"/sethp\" Loaded!\n")
else
	print("\t>>>> Damage is not enabled, \n\t     \"/kill\", \"/killme\" and \"/sethp\" not loaded!\n")
end

--------------------------------------------------------------------------------------------
-- homes function --------------------------------------------------------------------------
-- Add the line >> override_homes = false to the .conf to disable this feature! ------------
--------------------------------------------------------------------------------------------

local override = minetest.setting_getbool("override_homes")
if override ~= false then

	local homes_file = minetest.get_worldpath() .. "/players/"
	local old_homes_file = minetest.get_worldpath() .. "/homes"

	local function loadhome(name)
		local input = io.open(homes_file..name..".phf", "r")
		if input then
			local line_out = input:read("*l")
			if line_out then
				local found, _, name, pos = line_out:find("^([^%s]+)%s+(.+)$")
				io.close(input)
				return pos
			else
				return 
			end
		end
	end

	local function savehome(name,pos)
		if not pos then pos = minetest.get_player_by_name(name):getpos() end
		local output = io.open(homes_file..name..".phf", "w")
		output:write(name.." "..pos.x.." "..pos.y.." "..pos.z)
		io.close(output)
	end

	local function importhomes(erase_old)
		local input = io.open(old_homes_file, "r") 
		if input then
			repeat
				local x = input:read("*n")
				if x == nil then
					break
				end
				local y = input:read("*n")
				local z = input:read("*n")
				local n = input:read("*l")
				savehome(n:sub(2), {x=x, y=y, z=z})
			until input:read(0) == nil
			io.close(input)
			if erase_old == "erase" then
				io.open(old_homes_file, "wb"):write("Homes have been converted to the .phf format"..
								" and stored in the /players directory of the world directory")
				return true, "Home files imported and old file was erased!"
			end
			return true, "Home files imported!"
		else
			return false, "ERROR IMPORTING HOMES!!!"
		end
	end

	minetest.register_chatcommand("home", {    
		description = "Teleports you to your home.",
		privs = {interact=true},
		func = function(name)
			local player = minetest.get_player_by_name(name)
			if player then
				local home = minetest.string_to_pos(loadhome(name))
				if home then
					player:setpos(home)
					return true, "Teleporting home!"
				else
					return false, "Home is not set, set a home using /sethome"
				end
			end
		end,
	})

	minetest.register_chatcommand("sethome", {
		description = "Sets your home.",
		privs = {interact=true},
		func = function(name)
			savehome(name)
			return true, "Home is set!"
		end,
	})

	minetest.register_chatcommand("importhomes", {
		description = "Imports old homes file to new format!",
		params = "<erase> | Leave blank to leave the existing homes file as it is.",
		privs = {server=true},
		func = function(name,param)
			return importhomes(param)
		end,
	})

	print("\t>>>> \"/home\" and \"/sethome\" overrides loaded!\n")
else
	print("\t>>>> \"/home\" and \"/sethome\" overrides not loaded!\n")
end

--------------------------------------------------------------------------------------------
-- Time and Lag hud ------------------------------------------------------------------------
-- Add the line >> load_time_lag_hud = false to the .conf to disable this feature! ---------
--------------------------------------------------------------------------------------------

local disable = minetest.setting_getbool("load_time_lag_hud")
if disable ~= false then
    local player_hud = {}
    local player_hud_time = {}
    local player_hud_lag = {}
    local timer = 0;
    
    local function floormod ( x, y )
            return (math.floor(x) % y);
    end
    local function get_lag(raw)
            local a = explode(", ",minetest.get_server_status())
            local b = explode("=",a[4])
                    local lagnum = tonumber(string.format("%.2f", b[1]))
 		    local clag = 0
		    if lagnum > clag then 
			    clag = lagnum 
		    else
			    clag = clag * .75
		    end
                    if raw ~= nil then
                            return clag
                    else
                            return ("Current Lag: %s sec"):format(clag);
                    end
    end
    local function get_time ()
    local t, m, h, d
    t = 24*60*minetest.get_timeofday()
    m = floormod(t, 60)
    t = t / 60
    h = floormod(t, 60)
           
        
    if h == 12 then
        d = "pm"
    elseif h >= 13 then
        h = h - 12
        d = "pm"
    elseif h == 0 then
        h = 12
        d = "am"
    else
        d = "am"
    end
        return ("World time %02d:%02d %s"):format(h, m, d);
    end
    local function generatehud(player)
            local name = player:get_player_name()
            player_hud_time[name] = player:hud_add({
                    hud_elem_type = "text",
                    name = "player_hud:time",
                    position = {x=0.835, y=0.955},
                    text = get_time(),
                    scale = {x=100,y=100},
                    alignment = {x=0,y=0},
                    number = 0xFFFFFF,
            })
            player_hud_lag[name] = player:hud_add({
                    hud_elem_type = "text",
                    name = "player_hud:lag",
                    position = {x=0.835, y=0.975},
                    text = get_lag(),
                    scale = {x=100,y=100},
                    alignment = {x=0,y=0},
                    number = 0xFFFFFF,
            })
    end
    local function updatehud(player, dtime)
            local name = player:get_player_name()
            if player_hud_time[name] then 
            	player:hud_change(player_hud_time[name], "text", get_time()) 
            end
            if player_hud_lag[name] then 
            	player:hud_change(player_hud_lag[name], "text", get_lag()) 
            end
    end
    local function removehud(player)
            local name = player:get_player_name()
            if player_hud_time[name] then
                    player:hud_remove(player_hud_time[name])
            end
            if player_hud_lag[name] then
                    player:hud_remove(player_hud_lag[name])
            end
    end
    minetest.register_globalstep(function ( dtime )
    	timer = timer + dtime
        if (timer >= 1.0) then
        	timer = 0
            for _,player in ipairs(minetest.get_connected_players()) do
                    updatehud(player, dtime)
            end
        end
    end)
    minetest.register_on_joinplayer(function(player)
            minetest.after(0,generatehud,player)
    end)
    minetest.register_on_leaveplayer(function(player)
            minetest.after(1,removehud,player)
    end)
    print("\t>>>> Time and Lag HUD loaded!\n")
else
    print("\t>>>> Time and Lag HUD not loaded!\n")
end

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
	print("\t>>>> Whitelist function loaded!\n")
else
	print("\t>>>> Whitelist function will not be loaded!\n")
end

--------------------------------------------------------------------------------------------
-- Spawn points ----------------------------------------------------------------------------
-- Add the line >> static_spawnpoint"_<number>" = <cords here as x y z>  to your .conf :D --
--------------------------------------------------------------------------------------------

if server_tools.load_spawn_cmd then --set in the settings.txt
	local spawn  = minetest.setting_get("static_spawnpoint")
	local spawn2 = minetest.setting_get("static_spawnpoint_2")
	local spawn3 = minetest.setting_get("static_spawnpoint_3")
	local spawn4 = minetest.setting_get("static_spawnpoint_4")
	local spawn5 = minetest.setting_get("static_spawnpoint_5")

	minetest.register_chatcommand("spawn", {
		params = "0/1/2/3/4/5/<blank>",
		description = "Teleport to spawn",
		privs = {shout=true,interact=true},
		func = function(name, param)
			if param == "0" or param == "1" or param == "" and spawn ~= nil then
				local player = minetest.get_player_by_name(name)
				player:setpos(minetest.string_to_pos(spawn))
				return true, "Teleporting to spawn ..."	
			elseif param == "2" and spawn2 ~= nil then
				local player = minetest.get_player_by_name(name)
				player:setpos(minetest.string_to_pos(spawn2))
				return true, "Teleporting to spawn 2..."	
			elseif param == "3" and spawn3 ~= nil then
				local player = minetest.get_player_by_name(name)
				player:setpos(minetest.string_to_pos(spawn3))
				return true, "Teleporting to spawn 3..."
			elseif param == "4" and spawn4 ~= nil then
				local player = minetest.get_player_by_name(name)
				player:setpos(minetest.string_to_pos(spawn4))
				return true, "Teleporting to spawn 4..."	
			elseif param == "5" and spawn5 ~= nil then
				local player = minetest.get_player_by_name(name)
				player:setpos(minetest.string_to_pos(spawn5))
				return true, "Teleporting to spawn 5..."
			else
				minetest.log("action", "[MOD ERROR] \"Spawn\" /spawn"..param.." not set!!!")
				return false, "Invalid use of comand or spawn"..param..
					" not set, please try the comand again or contact an admin!"
			end
		end,
	})

	if spawn or spawn2 or spawn3 or spawn4 or spawn5 then
		local s1,s2,s3,s4,s5
		if spawn  then s1 = "1"  else s1 = "" end
		if spawn2 then s2 = " 2" else s2 = "" end
		if spawn3 then s3 = " 3" else s3 = "" end
		if spawn4 then s4 = " 4" else s4 = "" end
		if spawn5 then s5 = " 5" else s5 = "" end
		print("\t>>>> \"/spawn("..s1..s2..s3..s4..s5..")\" Loaded!\n")
	end
end

--------------------------------------------------------------------------------------------
-- Profanity Monitor feature! --------------------------------------------------------------
-- Add the line >> disable_profanity_filter = false to the .conf to disable this feature! --
-- also includes an offline message delivery system for /msg -------------------------------
--------------------------------------------------------------------------------------------

local violationlog = minetest.get_worldpath().."/violationlog.txt"
local disable = minetest.setting_getbool("disable_profanity_filter")
local disable_olm = minetest.setting_getbool("disable_offline_msgs")
local olm_autoclear = minetest.setting_getbool("offline_msgs_auto_clear")
local offline_msgs_file = minetest.get_worldpath() .. "/offline_msgs"
local offline_msgs = {}

if disable_olm ~= true then
	local function load_offline_msg()
		local input = io.open(offline_msgs_file, "r")
		if input then
			repeat
				local line_out = input:read("*l")
				if line_out == nil or line_out == "" then
					break
				end
				local found, _, name, msg = line_out:find("^([^%s]+)%s(.+)$")
				offline_msgs[name] = msg
			until input:read(0) == nil
			io.close(input)
		end
	end

	load_offline_msg()

	function offline_msg(sendto,name,message)
		local prev_msg = ""
		if offline_msgs[sendto] then
			prev_msg = offline_msgs[sendto]..", next pm: "
		end
		offline_msgs[sendto] = prev_msg..os.date("PM %m/%d/%y %X from "..name..": \""..message.."\"")
		save_offline_msgs()
	end

	function save_offline_msgs()
		local output = io.open(offline_msgs_file, "w")
		local data = {}
		for i, v in pairs(offline_msgs) do
			if v ~= "" then
				table.insert(data,string.format("%s %s \n", i,v))
			end
		end
		output:write(table.concat(data))
		io.close(output)
	end

	minetest.register_on_joinplayer(function(player)
		local plname = player:get_player_name()
		if offline_msgs[plname] then
			minetest.chat_send_player(plname, offline_msgs[plname])
			minetest.log("action", plname.." recieved PM(s) "..offline_msgs[plname])
			if olm_autoclear == true then
				offline_msgs[name] = ""
				save_offline_msgs()	
			end
		end
	end)

	if olm_autoclear == true then
		print("\t>>>> Offline /msg auto clear on login is active!\n")
	else
		minetest.register_chatcommand("check_msg", {
			params = "<clear>",
			description = "Checks your offline messages.",
			func = function(name, param)
				if offline_msgs[name] and offline_msgs[name] ~= "" then
					local msg = offline_msgs[name]
					if param == "clear" then 
						offline_msgs[name] = ""
						save_offline_msgs()
						return true, "Offline messages were cleared!"
					else
						return true, offline_msgs[name]..", To clear offline messages do /check_msg clear"
					end
				else
					return false, "No messages to show!"
				end
			end
		})
	end

	print("\t>>>> Offline /msg useage is available!\n")
end

function check_filter(name,msg,type,sendto)
	if disable ~= true then
		local to = sendto or ""
		local lmsg = msg:lower()
		local block = false
		local why = ""
		for word, reason in pairs(server_tools.disallowed_words) do
			if lmsg:find(word) then
				minetest.log("action", "[ALERT!!!] \"profanity or bad words!!\" "..name..
					" is in violation!!!")
				violation(name,type,msg,to)
				if minetest.check_player_privs(name, {admin=true})
				or minetest.check_player_privs(name, {unfiltered=true}) then
					why = reason.."!"
				else
					block = true
					why = reason.."!"
				end
			end
		end
		return block, why
	end
end

minetest.register_privilege("unfiltered", {
	description = "Bypasses the chat filter", 
	give_to_singleplayer = true
})

function violation(name,type,msg,sendto)
	local to = sendto or ""
	local file = io.open(violationlog, "a")
	file:write(os.date("["..name.."] %m/%d/%y %X: \""..type.."\""..to.." "..msg.."\n"))
	file:close()
end

-- Handeler for public chat
---------------------------

minetest.register_on_chat_message(function(name, message)
	local block, reason = check_filter(name,message,"chat")
	if block == true then
		minetest.chat_send_player(name, "This will not be shown, "..reason)
		return true
	elseif reason ~= "" then
		minetest.chat_send_player(name, reason)
		return false
	else
		return false
	end
end)

-- Handeler for private chat
----------------------------

minetest.register_chatcommand("msg", {
	params = "<name> <message>",
	description = "Send a private message",
	privs = {shout=true},
	func = function(name, param)
		local found, _, sendto, message = param:find("^([^%s]+)%s(.+)$")
		if found then
			local block, reason = check_filter(name,message,"/msg",sendto)
			if block == true then
				return false, reason..", your message will not be sent!!!"
			end
			if minetest.get_player_by_name(sendto) then
				minetest.log("action", "PM from "..name.." to "..sendto..": "..message)
				minetest.chat_send_player(sendto, "PM from "..name..": "..message)
				if reason ~= "" then
					return true, reason..", Message sent"
				else
					return true, "Message sent"
				end
			else
				for is_name, data in pairs(minetest.auth_table) do
					if is_name == sendto then
						offline_msg(sendto,name,message)
						minetest.log("action", "PM from "..name.." to "..sendto..": "..message)
						if reason ~= "" then
							return true, reason..", "..sendto.." will recieve your message when they log back on!"
						else
							return true, sendto.." will recieve your message when they log back on!"
						end
					end
				end
				return false, "Player does not exist on this server, please check spelling and capitolization of the name!"
			end
		else
			return false, "Invalid usage, see /help msg"
		end
	end,
})

--Handeler for "/me" chat
-------------------------

minetest.register_chatcommand("me", {
	params = "<action>",
	description = "chat action (eg. /me goes outside)",
	privs = {shout=true},
	func = function(name, param)
		local block, reason = check_filter(name,param,"/me")
		if block == true then
			return false, "This will not be shown, "..reason
		elseif reason ~= "" then
			minetest.chat_send_player(name, reason)
		end
		minetest.chat_send_all("* "..name.." "..param)
	end,
})

if disable ~= true then
	print("\t>>>> Profanity filter function loaded!\n")
else
	print("\t>>>> Profanity filter function will not be loaded!!!\n")
end

--------------------------------------------------------------------------------------------
-- Admin and moderator colored nametags function -------------------------------------------
--------------------------------------------------------------------------------------------

local owner_name = minetest.setting_get("name") --Playername listed in the .conf
local owner_color = minetest.setting_get("server_tools.owner_color")
local admin_color = minetest.setting_get("server_tools.admin_color")
local mod_color = minetest.setting_get("server_tools.mod_color")

minetest.register_on_joinplayer(function(player)
	if player:get_player_name() == owner_name and owner_color then
		player:set_nametag_attributes({color = server_tools.o_color })
		return
	end
	if minetest.check_player_privs(player:get_player_name(), {admin=true}) and admin_color then
		player:set_nametag_attributes({color = server_tools.a_color })
		return
	end
	if minetest.check_player_privs(player:get_player_name(), {mod=true}) and mod_color then
		player:set_nametag_attributes({color = server_tools.m_color })
		return
	end
end)

if owner_color or admin_color or mod_color then
	local oc, ac, mc
	if owner_color then
		if server_tools.o_color then 
			oc = "\t     *Owner's nametag will be colored!\n" 
		else 
			oc = "\t     *Owner's nametag color missing form settings.txt!\n" 
		end
	end
	if admin_color then
		if server_tools.a_color then 
			ac = "\t     *All admin's nametags will be colored!\n" 
		else 
			ac = "\t     *Admin's nametag color missing form settings.txt!\n" 
		end
	end
	if mod_color then
		if server_tools.m_color then 
			mc = "\t     *All moderator's nametags will be colored!\n" 
		else 
			mc = "\t     *Moderator's nametag color missing form settings.txt!\n" 
		end
	end
	print("\t>>>> Nametag colors Loaded!\n "..oc..ac..mc)
end

--------------------------------------------------------------------------------------------
-- Playername filtering function -----------------------------------------------------------
-- Add the line >> disable_playername_filter = false to the .conf to disable this feature! -
--------------------------------------------------------------------------------------------

local disable = minetest.setting_getbool("disable_playername_filter")
if disable ~= true then
	minetest.register_on_prejoinplayer(function(name, ip)
		local lname = name:lower()
		for filter, reason in pairs(server_tools.disallowed_names) do
			if lname:find(filter) then
				return reason
			end
		end
	end)
	print("\t>>>> Playername filtering Loaded!\n")
else
	print("\t>>>> Playername filtering not Loaded!\n")
end

--------------------------------------------------------------------------------------------
-- Playername "CASE" sensitive function ----------------------------------------------------
-- Add the line >> disable_playername_case = false to the .conf to disable this feature! ---
--------------------------------------------------------------------------------------------

local disable = minetest.setting_getbool("disable_playername_case")
if disable ~= true then
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
	print("\t>>>> Playername \"CASE\" sensitive Loaded!\n")
else
	print("\t>>>> Playername \"CASE\" sensitive not Loaded!\n")
end

--------------------------------------------------------------------------------------------
-- Selective PvP function ------------------------------------------------------------------
-- Add the line >> disable_selective_pvp = true to the .conf to disable this feature! ------
--------------------------------------------------------------------------------------------

local pvp_bar = {
	physical = false,
	collisionbox = {x = 0, y = 0, z = 0},
	visual = "sprite",
	textures = {"server_tools_pvp.png"},
	visual_size = {x = 0.5, y = 0.3, z = 0.3},
	wielder = nil,
}

local pvp_enable = {}

function pvp_bar:on_step(dtime)
	local wielder = self.wielder or "none"
	if wielder == (nil or "none") then	
		self.object:remove()
		return
	elseif not minetest.get_player_by_name(wielder)  then
		self.object:remove()
		return
	end
	if pvp_enable[wielder] == "disabled" then
		self.object:set_properties({textures = {"server_tools_blank.png"}})
	else
		self.object:set_properties({textures = {"server_tools_pvp.png"}})
	end
end

minetest.register_entity("server_tools:pvpbar", pvp_bar)

local disable = minetest.setting_getbool("disable_selective_pvp")
if not disable and minetest.setting_getbool("enable_damage") and minetest.setting_getbool("enable_pvp") then

	function server_tools.set_pvp(name, param)
		pvp_enable[name] = param
		return "Your PvP is "..param.."!"
	end

	local function add_pvp_bar(pl)
			local plname = pl:get_player_name()
			local pos = pl:getpos()
			local ent = minetest.env:add_entity(pos, "server_tools:pvpbar")
			server_tools.set_pvp(plname, "disabled")
			if ent ~= nil then
				ent:set_attach(pl, "", {x = 0, y = 9, z = 0}, {x = 0, y = 0, z = 0})
				ent = ent:get_luaentity()
				ent.wielder = plname
			end
	end

	minetest.register_on_joinplayer(add_pvp_bar)

	minetest.register_on_leaveplayer(function(player)
		local plname = player:get_player_name()
		server_tools.set_pvp(plname, "disabled")
	end)

	minetest.register_chatcommand("pvp", {
		description = "Enables PvP for you.",
		params = "<on|off>",
		privs = {interact=true},
		func = function(name, param)
			param = param:lower()
			if param == "off" then
				return true, server_tools.set_pvp(name, "disabled")
			elseif param == "on" then
				return true, server_tools.set_pvp(name, "enabled")
			else
				return false, "Your PvP is set to "..pvp_enable[name].." Usage: /pvp on to enable or /pvp off to disable."
			end
		end
	})

	minetest.register_on_punchplayer(
		function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, pvp)
		local h_name = hitter:get_player_name()
		local p_name = player:get_player_name()
		if not hitter:is_player() then
			return false
		else
			if pvp_enable[h_name] == "disabled" then
				if time_from_last_punch > 3 or time_from_last_punch == nil then
					minetest.chat_send_player(h_name, "You have PvP disabled!")
				end
				return true
			elseif pvp_enable[p_name] == "disabled" then
				if time_from_last_punch > 3 or time_from_last_punch == nil then
					minetest.chat_send_player(h_name, "Player has PvP disabled!")
				end
				return true
			else
				return false
			end
		end
	end)

	if unified_inventory then
		unified_inventory.register_button("server_tools_toggle_pvp", {
			type = "image",
			image = "server_tools_pvp.png",
			action = function(player)
				local plname = player:get_player_name()
				if pvp_enable[plname] == "disabled" then
					minetest.chat_send_player(plname, server_tools.set_pvp(plname, "enabled"))
				else
					minetest.chat_send_player(plname, server_tools.set_pvp(plname, "disabled"))
				end
			end,
		})
		print("\t>>>> unified_inventory PvP toggle button is available!\n")
	end
end

--------------------------------------------------------------------------------------------
-- Admin tools and nodes -------------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_node("server_tools:light", {
	description = "Light node",
	drawtype = "airlike",
	walkable = false,
	pointable = false,
	light_source = 14,
	paramtype = "light",
	buildable_to = true,
	sunlight_propagates = true,
	groups = {not_in_creative_inventory=1},
})

minetest.register_tool("server_tools:pick", {
	description = "Admin pick",
	inventory_image = "server_tools_pick.png",
	groups = {not_in_creative_inventory=1},
	range = 10,
	tool_capabilities = {
		full_punch_interval = 0,
		max_drop_level=3,
	},
})

minetest.register_on_punchnode(function(pos, node, puncher)
	local plname = puncher:get_player_name()
	if puncher:get_wielded_item():get_name() == "server_tools:pick" and minetest.env: get_node(pos).name ~= "air" then
		--if minetest.check_player_privs(puncher:get_player_name(), {admin=true}) then -- too slow atm
			minetest.env:remove_node(pos)
			minetest.log("action", plname.." digs ".. node.name.." at "..minetest.pos_to_string(pos))
		--else
			--minetest.chat_send_player(plname, "This tool requires the admin privilege!")
			--minetest.log("action", plname.." trys digging ".. node.name.." at "..minetest.pos_to_string(pos))
		--end
	end
end)



--------------------------------------------------------------------------------------------
-- Server announcments ---------------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("server", {
	params = "<message>",
	description = "Sends message to all as ***SERVER***",
	privs = {server=true},
	func = function(name, param)
		minetest.chat_send_all("***SERVER*** "..param)
		minetest.log("action", name.." invokes /server => \""..param.."\"")
	end,
})

--------------------------------------------------------------------------------------------
-- Server welcome for new players feature --------------------------------------------------
-- Add the line >> enable_welcome = true to the .conf to enable this feature! --------------
-- Add the line >> welcome_msg = <message here> .conf set aditional welcome message --------
--------------------------------------------------------------------------------------------

local server_name = minetest.setting_get("server_name")
local welcome = minetest.setting_get("welcome_msg") 

if minetest.setting_getbool("enable_welcome") then
	local welcome_msg = ""
	if welcome then
		welcome_msg = ", "..welcome
	end
	minetest.register_on_newplayer(function(player)
		local plname = player:get_player_name()
		minetest.chat_send_player("Welcome to "..server_name..welcome_msg)
	end)
	print("\t>>>> New player welcome message enabled!\n")
end

--------------------------------------------------------------------------------------------
-- Player death message feature ------------------------------------------------------------
-- Add the line >> enable_death_msg = true to the .conf to enable this feature! ------------
--------------------------------------------------------------------------------------------

if minetest.setting_getbool("enable_death_msg") then
	minetest.register_on_dieplayer(function(player)
		local plname = player:get_player_name()
		minetest.chat_send_all(plname.." has died!")
	end)
	print("\t>>>> Player death messages enabled!\n")
end

--------------------------------------------------------------------------------------------
-- Extended kick feature -------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- minetest.register_chatcommand("-kick", {
-- 	params = "<name> [reason]",
-- 	description = "kick a player",
-- 	privs = {kick=true},
-- 	func = function(name, param)
-- 		local tokick, reason = param:match("([^ ]+) (.+)")
-- 		tokick = tokick or param
-- 		if not minetest.kick_player(tokick, reason) then
-- 			return false, "Failed to kick player " .. tokick
-- 		end
-- 		local log_reason = ""
-- 		if reason then
-- 			log_reason = " with reason \"" .. reason .. "\""
-- 		end
-- 		minetest.log("action", name .. " kicks " .. tokick .. log_reason)
-- 		return true, "Kicked " .. tokick
-- 	end,
-- })

--------------------------------------------------------------------------------------------
-- AFK kick feature ------------------------------------------------------------------------
--------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------



print("\n Please refer to the readme.txt for use of this mod.\n"..
	  " copyright 2015 Ginger Pollard (crazyginger72,cg72)\n"..
	  "========================================================================")