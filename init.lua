--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 1.0 :D --------------------------------
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
-- The white list, time and lag HUD, "/empty_inv" feature, "/privs" blocker function,     --
-- colored nametags function and profanity filter can be disabled or enabled via the .conf--
--                                                                                        --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Load settings file ----------------------------------------------------------------------
--------------------------------------------------------------------------------------------
server_tools = {}
dofile(minetest.get_modpath("server_tools").."/settings.txt")
if not server_tools.settings then
	print("\n[MOD] [server_tools ver: 1.0] [WARNING] Mod can not initialize, missing \""..
		""..minetest.get_modpath("server_tools").."/settings.txt\"!!!!!!\n")
	return
end
print("========================================================================\n"..
	  "[MOD] [server_tools ver: 1.0] Mod initializing.....\n")

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

local enable = minetest.setting_get("enable_privs_check_block")
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
				..minetest.privs_to_string(
					minetest.get_player_privs(param), ' ')
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
			minetest.show_formspec(name, "server_tools:info_form", 
				"size[10,6]"..
				"background[-0.25,-0.25;10.5,6.75;server_tools_bg.png^server_tools_overlay.png]"..
				"label[0.1, 0.00;Connection]"..
				"label[0.1, 0.25;IP address: "..info.address.."]"..
				"label[0.1, 0.50;IP ver: "..info.ip_version.."]"..
				"label[0.1, 0.75;Min rtt: "..info.min_rtt.."]"..
				"label[0.1, 1.00;Max rtt: "..info.max_rtt.."]"..
				"label[0.1, 1.25;Avg rtt: "..info.avg_rtt.."]"..
				"label[0.1, 1.50;Time logged in: "..info.connection_uptime.."]"..
				"label[3.75,-0.07;Player: "..param.."]"..
				"label[6.575, 0.0;Skin                   "..dskin.."]"..
				"image[6.575,0.075;4.0,2.1;"..skin.."]"..
				"label[0.1, 2.25;Stats]"..
				"label[0.1, 2.50;HP: "..player:get_hp().."]"..
				"label[0.1, 2.75;Breath: "..player:get_breath().."]"..
				"label[0.1, 3.00;Location: ("..px..", "..py..", "..pz..")]"..
				"label[0.1, 3.25;Speed: "..tostring(physics.speed).."]"..
				"label[0.1, 3.50;Jump: "..tostring(physics.jump).."]"..
				"label[0.1, 3.75;Gravity: "..tostring(physics.gravity).."]"..
				"label[0.1, 4.00;Sneak: "..tostring(physics.sneak).."]"..
				"label[0.1, 4.25;Sneak glitch: "..tostring(physics.sneak_glitch).."]"..
				"textlist[6.5,2.3;3.3,2.35;inventory;"..inv_list..";0;true]"..
				"textlist[3.7,0.65;2.4,4.0;privs;#0000ccPrivs:,   "..
					minetest.privs_to_string(minetest.get_player_privs(param), ',   ')..";0;true]"..
				"label[6.9, 4.95;Admin items]"..
				"label[6.9, 5.21;Dangerous items]"..
				"label[6.9, 5.48;Weilded item]"..
				"label[6.9, 5.73;Not in creative items]"..
				"image_button_exit[0.1,5.1;1.75,0.5;server_tools_btn_.png;exit;Close]"..
				"image_button_exit[1.7,5.1;1.75,0.5;server_tools_btn_.png;ch_player;Change Player]"..
				"image_button_exit[0.1,5.65;1.75,0.5;server_tools_btn_.png;grant;Grant]"..
				"image_button_exit[1.7,5.65;1.75,0.5;server_tools_btn_.png;revoke;Revoke]"..
				"label[4.2, 5.0;"..msg.."]"..
				"field[4.07, 5.6;2.5,1.0;input;;]"..
				"field[4.07, -5.6;2.5,1.0;param;;"..param.."]"..
				""
			)
		else
			minetest.chat_send_player(name, param.." is not online.")
		end
	end
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
			minetest.chat_send_player(name, "IP address of "..param.." is "..minetest.get_player_ip(param))
		else
			minetest.chat_send_player(name, param.." is not online.")
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
			minetest.chat_send_player(name, "Usage: /whereis <playername> ")
			return 
		end
		local player = minetest.get_player_by_name(param)
		if player then
			local pos = player:getpos()
			local px = math.floor(pos.x, 1)
			local py = math.floor(pos.y, 1)
			local pz = math.floor(pos.z, 1)
			minetest.chat_send_player(name, "Location of "..param.." is ("..px.." "..py.." "..pz..")")
		else
			minetest.chat_send_player(name, param.." is not online.")
		end
	end
})

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
			minetest.chat_send_player(name, param.." is holding a "..item)
		else
			minetest.chat_send_player(name, param.." is not online.")
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
			minetest.chat_send_player(name, "There is no weild item to remove!")
			return
		end
		if minetest.get_player_by_name(param) or not param or param == "" then
			minetest.get_player_by_name(param):set_wielded_item(nil)
			minetest.chat_send_player(name, param.."'s \""..itemname.."\" was removed!")
			minetest.chat_send_player(param, "You \""..itemname.."\" was removed by an admin!")
			minetest.log("action", name.." has removed "..param.."'s \""..itemname.."\"!")
		else
			minetest.chat_send_player(name, param.." is not online.")
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
			minetest.chat_send_player(name, "Usage: /search_inv <playername> <itemname>")
			return
		end
		local found, _, player, itemname = param:find("^([^%s]+)%s+(.+)$")
		if found == nil then
			worldedit.player_notify(name, "invalid usage!")
			return
		end
		if not minetest.get_player_by_name(player) then
			minetest.chat_send_player(name, player.." is not online.")
			return
		end
		if minetest.get_player_by_name(player):get_inventory():contains_item("main", itemname) then
			minetest.chat_send_player(name, player.." has the item \""..itemname.."\" in their inventory!")
		else
			minetest.chat_send_player(name, player.." doesn't have a \""..itemname.."\" in their inventory!")
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

local disable = minetest.setting_get("enable_empty_inv")
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

local enable = minetest.setting_get("enable_damage")
if enable == true then
	minetest.register_chatcommand("kill", {
	    params = "<playername>",
	    description = "The player will be klled immediately",
	    privs = {admin=true},
	    func = function(name, param)
	        if param == "" then
	            minetest.chat_send_player(name, "Usage: /kill <playername>")
	            return
	        end
	        if minetest.get_player_by_name(param) then
	        	minetest.get_player_by_name(param):set_hp(0)
	            minetest.chat_send_player(name, param.." has been killed.")
	            minetest.chat_send_player(param, "An admin has killed you!")
	            minetest.log("action", name.." has killed "..param..".")
	            return
	        elseif not minetest.get_player_by_name(param) then
	        	minetest.chat_send_player(name, param.." isn't online.")
	        end
	    end
	})

	minetest.register_chatcommand("killme", {
	    description = "Kills you immediately",
	    privs = {interact=true},
	    func = function(name, param)
	        if minetest.get_player_by_name(name) then
	        	minetest.get_player_by_name(name):set_hp(0)
	            minetest.chat_send_player(name, "You have been killed.")
	            return
	        end
	    end
	})

	minetest.register_chatcommand("sethp", {
	    params = "<playername> <value>",
	    description = "Allows to set a player's HP.",
	    privs = {admin=true},
	    func = function(name, param)
	        if param == "" then
	            minetest.chat_send_player(name, "Usage: /sethp <playername> <value 1-20>")
	            return
	        end
	        local user, hp = string.match(param, " *([%w%-]+) *(%d*)")
	        hp = tonumber(hp)
	        if hp == nil or hp == "" or hp >20 or hp <= 1 then
	            minetest.chat_send_player(name, "Usage: /sethp <playername> <value 1-20>")
	           return
	        end
	        if minetest.get_player_by_name(user) then
	            minetest.get_player_by_name(user):set_hp(hp)
	            minetest.chat_send_player(name, user.."'s HP set to "..hp..".")
	            minetest.chat_send_player(user, name.." set your hp to "..hp.."!")
	            minetest.log("action", name.." has set "..user.."'s HP to "..hp..".")
	            return
	        elseif not minetest.get_player_by_name(user) then
	        	minetest.chat_send_player(name, user.." isn't online.")
	        end
	    end
	})

	print("\t>>>> \"/kill\", \"/killme\" and \"/sethp\" Loaded!\n")
else
	print("\t>>>> Damage is not enabled, \n\t     \"/kill\", \"/killme\" and \"/sethp\" not loaded!\n")
end

--------------------------------------------------------------------------------------------
-- Time and Lag hud ------------------------------------------------------------------------
-- Add the line >> load_time_lag_hud = false to the .conf to disable this feature! ---------
--------------------------------------------------------------------------------------------

local disable = minetest.setting_get("load_time_lag_hud")
if disable ~= false then
    player_hud = {}
    player_hud.time = {}
    player_hud.lag = {}
    local timer = 0;
    local function explode(sep, input)
            local t={}
                    local i=0
            for k in string.gmatch(input,"([^"..sep.."]+)") do
                t[i]=k;i=i+1
            end
            return t
    end
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
            player_hud.time[name] = player:hud_add({
                    hud_elem_type = "text",
                    name = "player_hud:time",
                    position = {x=0.835, y=0.955},
                    text = get_time(),
                    scale = {x=100,y=100},
                    alignment = {x=0,y=0},
                    number = 0xFFFFFF,
            })
            player_hud.lag[name] = player:hud_add({
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
            timer = timer + dtime;
            if (timer >= 1.0) then
                    timer = 0;
                    if player_hud.time[name] then player:hud_change(player_hud.time[name], "text", get_time()) end
                    if player_hud.lag[name] then player:hud_change(player_hud.lag[name], "text", get_lag()) end
            end
    end
    local function removehud(player)
            local name = player:get_player_name()
            if player_hud.time[name] then
                    player:hud_remove(player_hud.time[name])
            end
            if player_hud.lag[name] then
                    player:hud_remove(player_hud.lag[name])
            end
    end
    minetest.register_globalstep(function ( dtime )
            for _,player in ipairs(minetest.get_connected_players()) do
                    updatehud(player, dtime)
            end
    end);
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

local enable = minetest.setting_get("enable_whitelist")
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
			minetest.chat_send_player(name, "Teleporting to spawn...")
			player:setpos(minetest.string_to_pos(spawn))
			return true	
		elseif param == "2" and spawn2 ~= nil then
			local player = minetest.get_player_by_name(name)
			minetest.chat_send_player(name, "Teleporting to spawn 2...")
			player:setpos(minetest.string_to_pos(spawn2))
			return true	
		elseif param == "3" and spawn3 ~= nil then
			local player = minetest.get_player_by_name(name)
			minetest.chat_send_player(name, "Teleporting to spawn 3...")
			player:setpos(minetest.string_to_pos(spawn3))
			return true
		elseif param == "4" and spawn4 ~= nil then
			local player = minetest.get_player_by_name(name)
			minetest.chat_send_player(name, "Teleporting to spawn 4...")
			player:setpos(minetest.string_to_pos(spawn4))
			return true	
		elseif param == "5" and spawn5 ~= nil then
			local player = minetest.get_player_by_name(name)
			minetest.chat_send_player(name, "Teleporting to spawn 5...")
			player:setpos(minetest.string_to_pos(spawn5))
			return true	
		else
			minetest.chat_send_player(name, "Invalid use of comand or spawn"..param..
				" not set, please try the comand again or contact an admin!")
			minetest.log("action", "[MOD ERROR] \"Spawn\" /spawn"..param.." not set!!!")
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

--------------------------------------------------------------------------------------------
-- Profanity Monitor feature! --------------------------------------------------------------
-- Add the line >> disable_profanity_filter = false to the .conf to disable this feature! --
--------------------------------------------------------------------------------------------

local violationlog = minetest.get_worldpath().."/violationlog.txt"
local disable = minetest.setting_get("disable_profanity_filter")
if disable ~= true then

function violation(name, type, msg)
	file = io.open(violationlog, "a")
	file:write(os.date("["..name.."] %m/%d/%y %X: \""..type.."\" "..msg.."\n"))
	file:close()
end

-- Handeler for public chat
---------------------------

--!!! Currently doesn't block the message only warn player and reports to log!!!

	minetest.register_on_chat_message(function(name, message, playername, player)
		local lmessage = message:lower()
		for word, reason in pairs(server_tools.disallowed_words) do
			if lmessage:find(word) then
				local player = minetest.get_player_by_name(name)
				violation(player:get_player_name(), "chat", message)
				minetest.log("action", "[ALERT!!!] \"profanity or bad words!!\" "..player:get_player_name()..
					" is in violation!!!")
				minetest.chat_send_player(player:get_player_name(), reason.."!")
				return false
			end
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
			local lmessage = message:lower()
			for word, reason in pairs(server_tools.disallowed_words) do
				if lmessage:find(word) then
					local player = minetest.get_player_by_name(name)
					violation(player:get_player_name(), "/msg", "to:"..name..", "..message)
					minetest.log("action", "[ALERT!!!] \"profanity or bad words!!\" "..player:get_player_name()..
					" is in violation!!!")
					minetest.chat_send_player(player:get_player_name(), reason..", your message will not be sent!!!")
					return 
				end
			end
			if minetest.get_player_by_name(sendto) then
				minetest.log("action", "PM from "..name.." to "..sendto..": "..message)
				minetest.chat_send_player(sendto, "PM from "..name..": "..message)
				minetest.chat_send_player(name, "Message sent")
			else
				minetest.chat_send_player(name, "The player "..sendto.." is not online")
			end
		else
			minetest.chat_send_player(name, "Invalid usage, see /help msg")
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
		local lparam = param:lower()
		for word, reason in pairs(server_tools.disallowed_words) do
			if lparam:find(word) then
				local player = minetest.get_player_by_name(name)
				violation(player:get_player_name(), "/me", param)
				minetest.log("action", "[ALERT!!!] \"profanity or bad words!!\" "..player:get_player_name()..
					" is in violation!!!")
				minetest.chat_send_player(player:get_player_name(), reason..", your action will not be shown!!!")
				return 
			end
		end
		minetest.chat_send_all("* "..name.." "..param)
	end,
})

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

local disable = minetest.setting_get("disable_playername_filter")
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

local disable = minetest.setting_get("disable_playername_case")
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



print("\n Please refer to the readme.txt for use of this mod.\n"..
	  " copyright 2015 Ginger Pollard (crazyginger72,cg72)\n"..
	  "========================================================================")