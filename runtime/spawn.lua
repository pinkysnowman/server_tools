--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Spawn points ----------------------------------------------------------------------------
-- Add the line >> static_spawnpoint"_<number>" = <cords here as x y z>  to your .conf :D --
--------------------------------------------------------------------------------------------

if minetest.get_modpath("spawn") then
	table.insert(server_tools.print_out, "\t>>>> \"/spawn not loaded, \"spawn\" mod detected!")
	return
else

	local spawn  = minetest.setting_get("static_spawnpoint")
	local spawn1 = minetest.setting_get("static_spawnpoint_1")
	local spawn2 = minetest.setting_get("static_spawnpoint_2")
	local spawn3 = minetest.setting_get("static_spawnpoint_3")
	local spawn4 = minetest.setting_get("static_spawnpoint_4")
	local spawn5 = minetest.setting_get("static_spawnpoint_5")

	if server_tools.interact_spawn == false then
		spawn1 = spawn
	end

	if server_tools.load_spawn_cmd == true then --set in the settings.txt

		minetest.register_chatcommand("spawn", {
			params = "0/1/2/3/4/5/<blank>",
			description = "Teleport to spawn",
			privs = {shout=true},
			func = function(name, param)
				local player = minetest.get_player_by_name(name)
				if not minetest.get_player_privs(name).interact then
					player:setpos(minetest.string_to_pos(spawn))
					return true, "Teleporting to basic spawn ..."	
				elseif param == "0" or param == "1" or param == "" and spawn1 ~= nil then
					player:setpos(minetest.string_to_pos(spawn1))
					return true, "Teleporting to spawn ..."	
				elseif param == "2" and spawn2 ~= nil then
					player:setpos(minetest.string_to_pos(spawn2))
					return true, "Teleporting to spawn 2..."	
				elseif param == "3" and spawn3 ~= nil then
					player:setpos(minetest.string_to_pos(spawn3))
					return true, "Teleporting to spawn 3..."
				elseif param == "4" and spawn4 ~= nil then
					player:setpos(minetest.string_to_pos(spawn4))
					return true, "Teleporting to spawn 4..."	
				elseif param == "5" and spawn5 ~= nil then
					player:setpos(minetest.string_to_pos(spawn5))
					return true, "Teleporting to spawn 5..."
				else
					minetest.log("action", "[MOD ERROR] \"Spawn\" /spawn"..param.." not set!!!")
					return false, "Invalid use of comand or spawn"..param..
						" not set, please try the comand again or contact an admin!"
				end
			end,
		})

		minetest.register_chatcommand("set_spawn", {
			params = "<1-5> | <alt> | blank for derfault",
			description = "Sets the spawn point to your current position",
			privs = {server=true},
			func = function(name, param)
				local player = minetest.get_player_by_name(name)
				if not player then
					return false
				end
				local pos = minetest.pos_to_string(player:getpos())
				if not param then
					minetest.setting_set("static_spawnpoint",pos)
				else
					if param == "0" or param == "alt" then
						param = "1"
					end
					minetest.setting_set("static_spawnpoint_"..param,pos)
				end
				minetest.setting_save()
				if not param then 
					local param = "" 
				else 
					param = param.." "
				end
				return true, "Spawn "..param.."set to "..pos
			end,
		})

		minetest.register_chatcommand("update_spawn", {
			description = "Updates the spawn(s) positions.",
			privs = {server=true},
			func = function(name, param)
				--if load_spawns() then
					--return true, "Spawn updated"
				--else
					return false, "[ERROR]Spawn(s) not updated!!!"
				--end
			end,
		})

		if spawn or spawn1 or spawn2 or spawn3 or spawn4 or spawn5 then
			local s,s1,s2,s3,s4,s5
			if spawn  then s  = "default"  else s  = "" end
			if spawn1 then s1 = " 1"       else s1 = "" end
			if spawn2 then s2 = " 2"       else s2 = "" end
			if spawn3 then s3 = " 3"       else s3 = "" end
			if spawn4 then s4 = " 4"       else s4 = "" end
			if spawn5 then s5 = " 5"       else s5 = "" end
			table.insert(server_tools.print_out, "\t>>>> \"/spawn("..s..s1..s2..s3..s4..s5..")\" Loaded!")
		else
			table.insert(server_tools.print_out, "\t>>>> \"/spawn not loaded!")
		end
	else
		table.insert(server_tools.print_out, "\t>>>> \"/spawn not loaded!")
	end	
end
