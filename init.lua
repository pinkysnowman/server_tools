--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
-- This mod adds some useful features and comands to the game as well as an optional      --
-- profanity and language filter that over rides the /me and /msg functions to help block --
-- un desired messages from being sent, also it reports violations to the minetest log!   --
--                                                                                        --
-- The mod also adds a time and lag hud, white list for players, the ability to kill or   --
-- set a players hp, the ability to look a players IP address, the ability to get players --
-- location, the ability to see what a player is wielding, the ability to remove a        --
-- players wield item, the ability to search a players inventory for an item, the ability --
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
server_tools.print_out = {}
server_tools.owner = minetest.setting_get("name")
server_tools.modpath = minetest.get_modpath("server_tools")
server_tools.runtimepath = server_tools.modpath.."/runtime"
server_tools.worldpath = minetest.get_worldpath()
server_tools.ui_loaded = minetest.get_modpath("unified_inventory")
server_tools.irc_loaded = minetest.get_modpath("irc")
dofile(server_tools.modpath.."/settings.txt")
if not server_tools.settings then
	print("\n[MOD] [server_tools ver: 2.0] [WARNING] Mod can not initialize, missing \""..
		""..server_tools.modpath.."/settings.txt\"!!!!!!\n")
	return
end
table.insert(server_tools.print_out, "========================================================================\n"..
	  "[MOD] [server_tools ver: 2.0] Mod initializing......")
if server_tools.ui_loaded then 
	table.insert(server_tools.print_out, "\t>>>> [MOD] [unified_inventory] was found!")
end
if server_tools.irc_loaded then 
	table.insert(server_tools.print_out, "\t>>>> [MOD] [irc] was found!")
end
dofile(server_tools.runtimepath.."/settime.lua")
dofile(server_tools.runtimepath.."/privs_cmd.lua")
dofile(server_tools.runtimepath.."/selective_pvp.lua")
dofile(server_tools.runtimepath.."/info.lua")
dofile(server_tools.runtimepath.."/ip.lua")
dofile(server_tools.runtimepath.."/where.lua")
dofile(server_tools.runtimepath.."/wield.lua")
dofile(server_tools.runtimepath.."/inventory.lua")
dofile(server_tools.runtimepath.."/health.lua")
dofile(server_tools.runtimepath.."/home.lua")
dofile(server_tools.runtimepath.."/hud.lua")
dofile(server_tools.runtimepath.."/whitelist.lua")
dofile(server_tools.runtimepath.."/spawn.lua")
dofile(server_tools.runtimepath.."/chat.lua")
dofile(server_tools.runtimepath.."/nametag.lua")
dofile(server_tools.runtimepath.."/names.lua")
dofile(server_tools.runtimepath.."/server_helpers.lua")
dofile(server_tools.runtimepath.."/death.lua")
dofile(server_tools.runtimepath.."/keyword.lua")
dofile(server_tools.runtimepath.."/auto_reply.lua")
dofile(server_tools.runtimepath.."/physics.lua")

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

function server_tools.explode(sep, input)
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
	description = "Admin privilege!", 
	give_to_singleplayer = true
})

minetest.register_privilege("mod", {
	description = "Moderator privilege", 
	give_to_singleplayer = true
})

minetest.register_chatcommand("server_tools", {
	description = "Shows \"server_tools\" load status for easier ingame debug of mod!",
	privs = {admin=true},
	func = function(name)
		return true, table.concat(server_tools.print_out, "\n")
	end
})

table.insert(server_tools.print_out, "\t>>>> \"/server_tools\" cmd loaded for easier ingame debug of mod!")

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

table.insert(server_tools.print_out, "\n Please refer to the readme.txt for use of this mod.\n"..
	  " copyright 2015 Ginger Pollard (crazyginger72,cg72)\n"..
	  "========================================================================")
print(table.concat(server_tools.print_out, "\n\n"))