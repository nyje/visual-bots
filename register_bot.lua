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
	meta:set_string("infotext", bot_name .. " (" .. bot_owner .. ")")
	meta:set_string("name", bot_name)
	meta:set_int("fly", 0)
    local inv = meta:get_inventory()
    inv:set_size("p0", 56)
    inv:set_size("p1", 56)
    inv:set_size("p2", 56)
    inv:set_size("p3", 56)
    inv:set_size("p4", 56)
    inv:set_size("p5", 56)
    inv:set_size("p6", 56)
    inv:set_size("main", 32)
    --print(bot_owner.." places bot")
    --print(dump(vbots.bot_info))
end


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
-- callback from bot node on_rightclick
-------------------------------------
local function bot_restore(pos)
    local meta = minetest.get_meta(pos)
    local bot_key = meta:get_string("key")
    local bot_owner = meta:get_string("owner")
    local bot_name = meta:get_string("name")
    if not vbots.bot_info[bot_key] then
        vbots.bot_info[bot_key] = { owner = bot_owner, pos = pos, name = bot_name}
        meta:set_string("infotext", bot_name .. " (" .. bot_owner .. ")")
        --print(dump(vbots.bot_info))
    end
end

-------------------------------------
-- Clean up bot table and bot storage
-------------------------------------
local function clean_bot_table()
    for bot_key,bot_data in pairs( vbots.bot_info) do
        local meta = minetest.get_meta(bot_data.pos)
        local bot_name = meta:get_string("name")
        if bot_name=="" then
            vbots.bot_info[bot_key] = nil
        end
    end
    --print("Cleaned")
    --print(dump(vbots.bot_info))
end

-------------------------------------
-- Bot Action Handlers
-------------------------------------
local function facebot(facing,pos)
    local node = minetest.get_node(pos)
    minetest.swap_node(pos,{name=node.name, param2=facing})
end

local function bot_turn_clockwise(pos)
    local node = minetest.get_node(pos)
    local newface = (node.param2+1)%4
    facebot(newface,pos)
end

local function bot_turn_anticlockwise(pos)
    local node = minetest.get_node(pos)
    local newface = (node.param2-1)%4
    facebot(newface,pos)
end

local function bot_turn_random(pos)
    if math.random(2)==1 then
        bot_turn_clockwise(pos)
    else
        bot_turn_anticlockwise(pos)
    end
end

local function move_bot(pos,direction)
    local node = minetest.get_node(pos)
    local dir = minetest.facedir_to_dir(node.param2)
    local newpos
    if direction == "u" then
        newpos = {x = pos.x, y = pos.y+1, z = pos.z}
    elseif direction == "d" then
        newpos = {x = pos.x, y = pos.y-1, z = pos.z}
    elseif direction == "f" then
        newpos = {x = pos.x-dir.x, y = pos.y, z = pos.z-dir.z}
    elseif direction == "b" then
        newpos = {x = pos.x+dir.x, y = pos.y, z = pos.z+dir.z}
    elseif direction == "l" then
        dir = minetest.facedir_to_dir((node.param2+1)%4)
        newpos = {x = pos.x+dir.x, y = pos.y, z = pos.z+dir.z}
    elseif direction == "r" then
        dir = minetest.facedir_to_dir((node.param2-1)%4)
        newpos = {x = pos.x+dir.x, y = pos.y, z = pos.z+dir.z}
    end

    local moveto_node = minetest.get_node(newpos)
    if moveto_node.name == "air" then
        local hold = minetest.get_meta(pos):to_table()
        minetest.set_node(pos,{name="air"})
        minetest.set_node(newpos,{name=node.name, param2=node.param2})
        if hold then
            minetest.get_meta(newpos):from_table(hold)
        end
    else
        minetest.sound_play("error",{pos = newpos, gain = 10})
    end
end

local function punch_bot(pos,player)
    local meta = minetest.get_meta(pos)
    local bot_owner = meta:get_string("owner")
    if bot_owner == player:get_player_name() then
        local item = player:get_wielded_item():get_name()
        if item == "vbots:move_forward" then
            move_bot(pos,"f")
        elseif item == "vbots:move_backward" then
            move_bot(pos,"b")
        elseif item == "vbots:move_up" then
            move_bot(pos,"u")
        elseif item == "vbots:move_down" then
            move_bot(pos,"d")
        elseif item == "vbots:move_left" then
            move_bot(pos,"l")
        elseif item == "vbots:move_right" then
            move_bot(pos,"r")
        elseif item == "vbots:turn_clockwise" then
            bot_turn_clockwise(pos)
        elseif item == "vbots:turn_anticlockwise" then
            bot_turn_anticlockwise(pos)
        elseif item == "vbots:turn_random" then
            bot_turn_random(pos)
        end
    end
end

-------------------------------------
-- Bot definitions
-------------------------------------
local function register_bot(node_name,node_desc,node_tiles)
    minetest.register_node(node_name, {
        description = node_desc,
        tiles = node_tiles,
        stack_max = 1,
        is_ground_content = false,
        paramtype2 = "facedir",
        legacy_facedir_simple = true,
        groups = {cracky = 3, snappy = 3, crumbly = 3, oddly_breakable_by_hand = 2},
        on_blast = function() end,
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            bot_init(pos, placer)
            local facing = minetest.dir_to_facedir(placer:get_look_dir())
            facing = (facing+2)%4
            facebot(facing,pos)
        end,
        on_punch = function(pos, node, player, pointed_thing)
            punch_bot(pos,player)
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
        can_dig = function(pos,player)
            return interact(player,pos)
        end,
        on_destruct = function(pos)
            local meta = minetest.get_meta(pos)
            local bot_key = meta:get_string("key")
            vbots.bot_info[bot_key] = nil
            clean_bot_table()
        end
    })
end

register_bot("vbots:off", "Inactive Vbot", {
            "vbots_turtle_top.png",
            "vbots_turtle_bottom.png",
            "vbots_turtle_right.png",
            "vbots_turtle_left.png",
            "vbots_turtle_tail.png",
            "vbots_turtle_face.png",
})
register_bot("vbots:off_fly", "Inactive Flying Vbot", {
            "vbots_turtle_top.png",
            "vbots_turtle_bottom.png",
            "vbots_turtle_right_fly.png",
            "vbots_turtle_left_fly.png",
            "vbots_turtle_tail.png",
            "vbots_turtle_face.png",
})
register_bot("vbots:on", "Live Vbot", {
            "vbots_turtle_top4.png",
            "vbots_turtle_bottom.png",
            "vbots_turtle_right.png",
            "vbots_turtle_left.png",
            "vbots_turtle_tail.png",
            "vbots_turtle_face.png",
})
register_bot("vbots:on_fly", "Live Flying Vbot", {
            "vbots_turtle_top4.png",
            "vbots_turtle_bottom.png",
            "vbots_turtle_right_fly.png",
            "vbots_turtle_left_fly.png",
            "vbots_turtle_tail.png",
            "vbots_turtle_face.png",
})


--register_bot("vbots:active", "Active vbot", "vbots_turtle_top1.png")
--register_bot("vbots:running", "Running vbot", "vbots_turtle_top4.png")


