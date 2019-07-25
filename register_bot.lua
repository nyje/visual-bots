
local STEPTIME = 1
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
	meta:set_int("PC", 0)
	meta:set_int("PR", 0)
	meta:set_string("stack","")
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

local function bot_fly(pos)
    local node = minetest.get_node(pos)
    if node.name == "vbots:off" or node.name == "vbots:on" then
        minetest.swap_node(pos,{name=node.name.."_fly",param2=node.param2})
        local meta = minetest.get_meta(pos)
        meta:set_int("fly", 1)
    end
end

local function bot_walk(pos)
    local node = minetest.get_node(pos)
    if node.name == "vbots:off_fly" or node.name == "vbots:on_fly" then
        minetest.swap_node(pos,{name=string.split(node.name,"_")[1],param2=node.param2})
        local meta = minetest.get_meta(pos)
        meta:set_int("fly", 0)
        minetest.check_for_falling(pos)
    end
end


local function move_bot(pos,direction)
    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)
    local fly = meta:get_int("fly")
    local dir = minetest.facedir_to_dir(node.param2)
    local newpos
    if direction == "u" and fly == 1 then
        newpos = {x = pos.x, y = pos.y+1, z = pos.z}
    elseif direction == "d"  and fly == 1 then
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
    local bot_owner = meta:get_string("owner")
    if not minetest.is_protected(newpos, bot_owner) then
        if newpos then
            local moveto_node = minetest.get_node(newpos)
            if moveto_node.name == "air" then
                local hold = meta:to_table()
                local elapsed = minetest.get_node_timer(pos):get_elapsed()
                minetest.set_node(pos,{name="air"})
                minetest.set_node(newpos,{name=node.name, param2=node.param2})
                minetest.get_node_timer(newpos):set(STEPTIME,0)
                if hold then
                    minetest.get_meta(newpos):from_table(hold)
                end
            else
                minetest.sound_play("error",{pos = newpos, gain = 10})
            end
            print(dump(minetest.check_for_falling(newpos)))
        end
    end
end

local function bot_dig(pos,digy)
    local meta = minetest.get_meta(pos)
    local bot_owner = meta:get_string("owner")
    local node = minetest.get_node(pos)
    local dir = minetest.facedir_to_dir(node.param2)
    local newpos = {x = pos.x-dir.x, y = pos.y+digy, z = pos.z-dir.z}
    if not minetest.is_protected(newpos, bot_owner) then
        local newnode = minetest.get_node(newpos)
        if newnode.name ~= "air" then
            local inv=minetest.get_inventory({
                                    type="node",
                                    pos=pos
                                })
            local leftover = inv:add_item("main", ItemStack(newnode.name))
            minetest.set_node(newpos,{name="air"})
        end
    end
end

local function bot_togglestate(pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)
    local timer = minetest.get_node_timer(pos)
    local newname = "nope"
    if node.name == "vbots:off" or node.name == "vbots:off_fly" then
        newname = string.gsub(node.name,"off","on")
        timer:start(1)
        meta:set_int("PC",STEPTIME)
        meta:set_int("PR",0)
        meta:set_string("stack","")
    elseif node.name == "vbots:on" or node.name == "vbots:on_fly" then
        newname = string.gsub(node.name, "on","off")
        timer:stop()
        bot_walk(pos)
        meta:set_int("PC",0)
        meta:set_int("PR",0)
        meta:set_string("stack","")
    end
    --print(node.name.." "..newname)
    minetest.swap_node(pos,{name=newname, param2=node.param2})
end

local function punch_bot(pos,player)
    local meta = minetest.get_meta(pos)
    local bot_owner = meta:get_string("owner")
    if bot_owner == player:get_player_name() then
        local item = player:get_wielded_item():get_name()
        print(item)
        if item == "" then
            bot_togglestate(pos)
        elseif item == "vbots:move_forward" then
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
        elseif item == "vbots:mode_fly" then
            bot_fly(pos)
        elseif item == "vbots:mode_walk" then
            bot_walk(pos)
        elseif item == "vbots:mode_dig" then
            bot_dig(pos,0)
        elseif item == "vbots:mode_dig_down" then
            bot_dig(pos,-1)
        elseif item == "vbots:mode_dig_up" then
            bot_dig(pos,1)
        elseif item == "vbots:mode_build" then
            bot_build(pos,0)
        elseif item == "vbots:mode_build_down" then
            bot_build(pos,-1)
        elseif item == "vbots:mode_build_up" then
            bot_build(pos,1)
        end
    end
end

local function bot_parsecommand(pos,item)
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
    elseif item == "vbots:mode_fly" then
        bot_fly(pos)
    elseif item == "vbots:mode_walk" then
        bot_walk(pos)
    elseif item == "vbots:mode_dig" then
        bot_dig(pos,0)
    elseif item == "vbots:mode_dig_down" then
        bot_dig(pos,-1)
    elseif item == "vbots:mode_dig_up" then
        bot_dig(pos,1)
    elseif item == "vbots:mode_build" then
        bot_build(pos,0)
    elseif item == "vbots:mode_build_down" then
        bot_build(pos,-1)
    elseif item == "vbots:mode_build_up" then
        bot_build(pos,1)
    end
end

local function bot_handletimer(pos)

end


-------------------------------------
-- Bot definitions
-------------------------------------
local function register_bot(node_name,node_desc,node_tiles,node_groups)
    minetest.register_node(node_name, {
        description = node_desc,
        tiles = node_tiles,
        stack_max = 1,
        is_ground_content = false,
        paramtype2 = "facedir",
        legacy_facedir_simple = true,
        groups = node_groups,
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
        on_timer = function(pos, elapsed)
             local inv=minetest.get_inventory({
                                            type="node",
                                            pos=pos
                                        })
            local meta = minetest.get_meta(pos)
            local PC = meta:get_int("PC")
            local PR = meta:get_int("PR")
            local invname = "p"..PR
            local stack = meta:get_string("stack")

            local taken = inv:get_stack(invname, PC)
            local command = taken:get_name()
            PC=PC+1
            while(command == "" and PC<57) do
                taken = inv:get_stack(invname, PC)
                command = taken:get_name()
                PC=PC+1
            end
            print( PC.." "..dump(taken:get_name()))
            meta:set_int("PC",PC)
            meta:set_int("PR",PR)
            meta:set_string("stack",stack)
            if PC<56 then
                bot_parsecommand(pos, command)
                return true
            else
                bot_togglestate(pos)
                return false
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
            },
            {cracky = 1,
             snappy = 1,
             crumbly = 1,
             oddly_breakable_by_hand = 1,
             falling_node = 1}
)
register_bot("vbots:off_fly", "Inactive Flying Vbot", {
            "vbots_turtle_top.png",
            "vbots_turtle_bottom.png",
            "vbots_turtle_right_fly.png",
            "vbots_turtle_left_fly.png",
            "vbots_turtle_tail.png",
            "vbots_turtle_face.png",
            },
            {cracky = 1,
             snappy = 1,
             crumbly = 1,
             oddly_breakable_by_hand = 1,
             not_in_creative_inventory = 1
            }
)
register_bot("vbots:on", "Live Vbot", {
            "vbots_turtle_top4.png",
            "vbots_turtle_bottom.png",
            "vbots_turtle_right.png",
            "vbots_turtle_left.png",
            "vbots_turtle_tail.png",
            "vbots_turtle_face.png",
            },
            {cracky = 1,
             snappy = 1,
             crumbly = 1,
             oddly_breakable_by_hand = 1,
             not_in_creative_inventory = 1,
             falling_node = 1}
)
register_bot("vbots:on_fly", "Live Flying Vbot", {
            "vbots_turtle_top4.png",
            "vbots_turtle_bottom.png",
            "vbots_turtle_right_fly.png",
            "vbots_turtle_left_fly.png",
            "vbots_turtle_tail.png",
            "vbots_turtle_face.png",
            },
            {cracky = 1,
             snappy = 1,
             crumbly = 1,
             not_in_creative_inventory = 1,
             oddly_breakable_by_hand = 1,
            }
)
