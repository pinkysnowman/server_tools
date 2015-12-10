--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

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
			local ent = minetest.add_entity(pos, "server_tools:pvpbar")
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

	if server_tools.ui_loaded then
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
		table.insert(server_tools.print_out, "\t>>>> unified_inventory PvP toggle button is available!")
	end
end
