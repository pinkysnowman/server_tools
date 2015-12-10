--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Admin and moderator colored nametags function -------------------------------------------
--------------------------------------------------------------------------------------------

local owner_name = minetest.setting_get("name") --Playername listed in the .conf
local owner_color = minetest.setting_get("server_tools.owner_color")
local admin_color = minetest.setting_get("server_tools.admin_color")
local mod_color = minetest.setting_get("server_tools.mod_color")

minetest.register_on_joinplayer(function(player)
	local plname = player:get_player_name()
	local special = minetest.setting_get(plname)
	if special then
		player:set_nametag_attributes({color = special})
		minetest.log("action", "Player "..plname.."'s special nametag color loaded!")
		return
	end
	if player:get_player_name() == "Kimmy" then
		player:set_nametag_attributes({color = {a=255, r=255, g=120, b=000}})
		return
	end
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