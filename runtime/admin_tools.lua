--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Admin tools and nodes -------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- minetest.register_node("server_tools:light", {
-- 	description = "Light node",
-- 	drawtype = "airlike",
-- 	walkable = false,
-- 	pointable = false,
-- 	light_source = 14,
-- 	paramtype = "light",
-- 	buildable_to = true,
-- 	sunlight_propagates = true,
-- 	groups = {not_in_creative_inventory=1},
-- })

-- minetest.register_tool("server_tools:pick", {
-- 	description = "Admin pick",
-- 	inventory_image = "server_tools_pick.png",
-- 	groups = {not_in_creative_inventory=1},
-- 	range = 10,
-- 	tool_capabilities = {
-- 		full_punch_interval = 0,
-- 		max_drop_level=3,
-- 	},
-- })

-- minetest.register_on_punchnode(function(pos, node, puncher)
-- 	local plname = puncher:get_player_name()
-- 	if puncher:get_wielded_item():get_name() == "server_tools:pick" and minetest.env: get_node(pos).name ~= "air" then
-- 		--if minetest.check_player_privs(puncher:get_player_name(), {admin=true}) then -- too slow atm
-- 			minetest.env:remove_node(pos)
-- 			minetest.log("action", plname.." digs ".. node.name.." at "..minetest.pos_to_string(pos))
-- 		--else
-- 			--minetest.chat_send_player(plname, "This tool requires the admin privilege!")
-- 			--minetest.log("action", plname.." trys digging ".. node.name.." at "..minetest.pos_to_string(pos))
-- 		--end
-- 	end
-- end)

--table.insert(server_tools.print_out,)
