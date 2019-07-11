
-------------------------------------
-- callback from bot node can_dig
-------------------------------------
local function interact(player,pos,isempty)
    local name = player:get_player_name()
    local meta = minetest.get_meta(pos)
    local player_is_owner = ( name == meta:get_string("owner") )
    local has_server_priv = minetest.check_player_privs(player, "server")
    if has_server_priv or player_is_owner then
        return true
    end
    return false
end


-------------------------------------
-- Cute 'unique' bot name generator
-------------------------------------
local function bot_namer()
    local first = {
        "A", "An", "Ba", "Bi", "Bo", "Bom", "Bon", "Da", "Dan",
        "Dar", "De", "Do", "Du", "Due", "Duer", "Dwa", "Fa", "Fal", "Fi",
        "Fre", "Fun", "Ga", "Gal", "Gar", "Gam", "Gim", "Glo", "Go", "Gom",
        "Gro", "Gwar", "Ib", "Jor", "Ka", "Ki", "Kil", "Lo", "Mar", "Na",
        "Nal", "O", "Ras", "Ren", "Ro", "Ta", "Tar", "Tel", "Thi", "Tho",
        "Thon", "Thra", "Tor", "Von", "We", "Wer", "Yen", "Yur"
    }
    local after = {
        "bil", "bin", "bur", "char", "den", "dir", "dur", "fri", "fur", "in",
        "li", "lin", "mil", "mur", "ni", "nur", "ran", "ri", "ril", "rimm", "rin",
        "thur", "tri", "ulf", "un", "ur", "vi", "vil", "vim", "vin", "vri"
    }
    return first[math.random(#first)] ..
           after[math.random(#after)] ..
           after[math.random(#after)]
end


-------------------------------------
-- callback from bot node on_rightclick
-------------------------------------
local function bot_restore(pos)
    local meta = minetest.get_meta(pos)
    local bot_key = meta:get_string("key")
    local bot_owner = meta:get_string("owner")
    local bot_name = meta:get_string("name")
    if not vbots.bot_info[bot_key] then
        vbots.bot_info[bot_key] = { owner = bot_owner, pos = pos, name = bot_name}
        print("Unknown bot restored for "..bot_owner)
        print(dump(vbots.bot_info))
    end
end


-------------------------------------
-- callback from bot node after_place_node
-------------------------------------
local function bot_init(pos, placer)
    local bot_key = vbots.get_key()
    local bot_owner = placer:get_player_name()
    local bot_name = bot_namer()
    vbots.bot_info[bot_key] = { owner = bot_owner, pos = pos, name = bot_name}
    local meta = minetest.get_meta(pos)
    meta:set_string("key", bot_key)
	meta:set_string("owner", bot_owner)
	meta:set_string("infotext", "Vbot " .. bot_name .. " owned by " .. bot_owner)
	meta:set_string("name", bot_name)
    meta:set_int("running",0)
	meta:set_int("panel", 0)
	meta:set_int("program", 0)
    local inv = meta:get_inventory()
    inv:set_size("p0", 56)
    inv:set_size("p1", 56)
    inv:set_size("p2", 56)
    inv:set_size("p3", 56)
    inv:set_size("p4", 56)
    inv:set_size("p5", 56)
    inv:set_size("p6", 56)
    inv:set_size("main", 32)
    print(bot_owner.." places bot")
    print(dump(vbots.bot_info))
end


minetest.register_node("vbots:bot", {
	description = "A vbots bot node",
    tiles = {
		"vbots_gui_up.png",
		"vbots_types_node.png",
		"vbots_types_node.png",
		"vbots_types_node.png",
		"vbots_types_node.png",
		"vbots_types_node.png",
	},
    stack_max = 1,
    is_ground_content = false,
    paramtype2 = "facedir",
    legacy_facedir_simple = true,
	groups = {cracky = 3, snappy = 3, crumbly = 3, oddly_breakable_by_hand = 2},
    on_blast = function() end,
    can_dig = function(pos,player)
        return interact(player,pos)
    end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
        bot_init(pos, placer)
    end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local name = clicker:get_player_name()
        if name == "" then
            return 0
        end
        if interact(clicker,pos) then
            bot_restore(pos)
            minetest.after(0, vbots.show_formspec, clicker, pos)
        end
    end,
    on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
        local bot_key = meta:get_string("key")
        vbots.bot_info[bot_key] = nil
        local name = meta:get_string("owner")
        vbots.clean_bots_for(name)
        print(name.."'s bots cleaned")
        print(dump(vbots.bot_info))
    end
})

