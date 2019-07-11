
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
-- callback from bot node can_dig
-------------------------------------
local function interact(player,pos)
    local meta = minetest.get_meta(pos)
    if minetest.check_player_privs(player, "server") or
            meta:get_string("owner")==player:get_player_name() then
        return true
    end
    return false
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
        bot_restore(pos)
        local name = clicker:get_player_name()
        if name == "" then
            return 0
        end
        if interact(clicker,pos) then
            minetest.after(0, vbots.show_formspec, clicker, pos)
        end
    end,
    on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
        local bot_key = meta:get_string("key")
        vbots.bot_info[bot_key] = nil
    end
})

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
    for bot_key,bot_data in pairs( vbots.bot_info) do
        if bot_data.owner == name then
            minetest.remove_node(bot_data.pos)
            vbots.bot_info[bot_key] = nil
        end
    end
end)

local register_command = function(itemname,description,image)
    minetest.register_craftitem("vbots:"..itemname, {
        description = description,
        inventory_image = image,
        wield_image = "wieldhand.png",
        stack_max = 1,
        groups = { bot_commands = 1 },
        on_place = function(itemstack, placer, pointed_thing)
            return nil
        end,
        on_drop = function(itemstack, dropper, pos)
            return nil
        end,
        on_use = function(itemstack, user, pointed_thing)
            return nil
        end
    })
end

register_command("move_forward","Move bot forward","vbots_move_forward.png")
register_command("move_backward","Move bot backward","vbots_move_backward.png")
register_command("move_left","Move bot to it's left","vbots_move_left.png")
register_command("move_right","Move bot to it's right","vbots_move_right.png")
register_command("move_up","Move bot up","vbots_move_up.png")
register_command("move_down","Move bot down","vbots_move_down.png")

register_command("climb_up","Climb up","vbots_climb_up.png")
register_command("climb_down","Climb down","vbots_climb_down.png")

register_command("turn_clockwise","Turn bot 90° clockwise","vbots_turn_clockwise.png")
register_command("turn_anticlockwise","Move bot 90° anti-clockwise","vbots_turn_anticlockwise.png")
register_command("turn_random","Move bot 90° in a random direction","vbots_turn_random.png")

register_command("case_end","End section","vbots_case_end.png")
register_command("case_failure","Last action failed","vbots_case_failure.png")
register_command("case_success","Last action succeeded","vbots_case_success.png")
register_command("case_yes","Yes","vbots_case_yes.png")
register_command("case_no","No","vbots_case_no.png")
register_command("case_test","Test","vbots_case_test.png")
register_command("case_repeat","Repeat","vbots_case_repeat.png")

register_command("mode_build","Place a block in the direction of the next command","vbots_mode_build.png")
register_command("mode_dig","Dig a block in the direction of the next command","vbots_mode_dig.png")
register_command("mode_examine","Examine the block in the direction of the next command","vbots_mode_examine.png")
register_command("mode_fly","Enter fly mode","vbots_mode_fly.png")
register_command("mode_pause","Wait for a few seconds","vbots_mode_pause.png")
register_command("mode_wait","Wait until next event","vbots_mode_wait.png")
register_command("mode_walk","Leave fly mode","vbots_mode_walk.png")

register_command("number_1","1","vbots_number_1.png")
register_command("number_2","2","vbots_number_2.png")
register_command("number_3","3","vbots_number_3.png")
register_command("number_4","4","vbots_number_4.png")
register_command("number_5","5","vbots_number_5.png")
register_command("number_6","6","vbots_number_6.png")

register_command("run_1","Run sub-program 1","vbots_run_1.png")
register_command("run_2","Run sub-program 2","vbots_run_2.png")
register_command("run_3","Run sub-program 3","vbots_run_3.png")
register_command("run_4","Run sub-program 4","vbots_run_4.png")
register_command("run_5","Run sub-program 5","vbots_run_5.png")
register_command("run_6","Run sub-program 6","vbots_run_6.png")

