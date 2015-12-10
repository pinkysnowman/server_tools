--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- GUI Player info feature -----------------------------------------------------------------
--------------------------------------------------------------------------------------------

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
				"label[6.9, 5.48;wielded item]",
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

if server_tools.ui_loaded then
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
	table.insert(server_tools.print_out, "\t>>>> unified_inventory button for player information is available!")
end

table.insert(server_tools.print_out, "\t>>>> GUI for player information is available!")
