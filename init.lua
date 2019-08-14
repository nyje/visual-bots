-- Visual Bots v0.3
-- (c)2019 Nigel Garnett.
--
-- see licence.txt
--

vbots={}
vbots.modpath = minetest.get_modpath("vbots")
vbots.bot_info = {}

local trashInv = minetest.create_detached_inventory(
                    "bottrash",
                    {
                       on_put = function(inv, toList, toIndex, stack, player)
                          inv:set_stack(toList, toIndex, ItemStack(nil))
                       end
                    })
trashInv:set_size("main", 1)
mod_storage = minetest.get_mod_storage()

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
-- Generate 32 bit key for formspec identification
-------------------------------------
function vbots.get_key()
    math.randomseed(minetest.get_us_time())
    local w = math.random()
    local key = tostring( math.random(255) +
            math.random(255) * 256 +
            math.random(255) * 256*256 +
            math.random(255) * 256*256*256 )
    return key
end

-------------------------------------
-- callback from bot node on_rightclick
-------------------------------------
vbots.bot_restore = function(pos)
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
-- callback from bot node after_place_node
-------------------------------------
vbots.bot_init = function(pos, placer)
    local bot_owner = placer:get_player_name()
    local bot_name = bot_namer()
    local bot_key = vbots.get_key()
    vbots.bot_info[bot_key] = { owner = bot_owner, pos = pos, name = bot_name}
    local meta = minetest.get_meta(pos)
	meta:set_string("infotext", bot_name .. " (" .. bot_owner .. ")")
    local inv = meta:get_inventory()
    inv:set_size("p0", 56)
    inv:set_size("p1", 56)
    inv:set_size("p2", 56)
    inv:set_size("p3", 56)
    inv:set_size("p4", 56)
    inv:set_size("p5", 56)
    inv:set_size("p6", 56)
    inv:set_size("main", 32)
    inv:set_size("trash", 1)

    meta:set_int("program",0)
    meta:mark_as_private("program")
    meta:set_string("home",minetest.serialize(pos))
    meta:mark_as_private("home")
    meta:set_int("panel",0)
    meta:mark_as_private("panel")
    meta:set_int("steptime",1)
    meta:mark_as_private("steptime")
    meta:set_string("key", bot_key)
    meta:mark_as_private("key")
	meta:set_string("owner", bot_owner)
    meta:mark_as_private("owner")
	meta:set_string("name", bot_name)
    meta:mark_as_private("name")
	meta:set_int("PC", 0)
    meta:mark_as_private("PC")
	meta:set_int("PR", 0)
    meta:mark_as_private("PR")
	meta:set_string("stack","")
    meta:mark_as_private("stack")
end

vbots.wipe_programs = function(pos)
    local meta = minetest.get_meta(pos)
    local meta_table = meta:to_table()
    local inv = meta:get_inventory()
    local inv_list = {}
    for i,t in pairs(meta_table.inventory) do
        if i ~= "main" then
            size = inv:get_size(i)
            for a=1,size do
                inv:set_stack(i,a, "")
            end
        end
    end
end

vbots.save = function(pos)
    vbots.bot_restore(pos)
    local meta = minetest.get_meta(pos)
    local meta_table = meta:to_table()
    local botname = meta:get_string("name")
    local name = meta:get_string("owner")
    local inv_list = {}
    for i,t in pairs(meta_table.inventory) do
        if i ~= "main" then
            for _,s in pairs(t) do
                local itemname = s:get_name()
                if s and s:get_count()>0 and itemname:sub(1,5)=="vbots" then
                    inv_list[#inv_list+1] = i.." "..s:get_name().." "..s:get_count()
                end
            end
        end
    end
    mod_storage:set_string(name..",vbotsep,"..botname,minetest.serialize(inv_list))
end

vbots.load = function(pos,player,mode)
    vbots.bot_restore(pos)
    local meta = minetest.get_meta(pos)
    local key = meta:get_string("key")
    local data = mod_storage:to_table().fields
    local bot_list = ""
    local parts
    for n,d in pairs(data) do
        parts = string.split(n,",vbotsep,")
        if #parts == 2 and parts[1] == player:get_player_name() then
            bot_list = bot_list..parts[2]..","
        end
    end
    bot_list = bot_list:sub(1,#bot_list-1)
    local formspec
    local formname
    if not mode then
        formspec = "size[5,9]"..
                 "image_button_exit[4,8;1,1;vbots_gui_check.png;ok;]"..
                 "image_button_exit[4,0;1,1;vbots_gui_delete.png;delete;]"..
                 "tooltip[4,0;1,1;delete]"..
                 "image_button_exit[4,1;1,1;vbots_gui_rename.png;rename;]"..
                 "tooltip[4,1;1,1;rename]"..
                 "textlist[0,0;4,9;saved;"..bot_list.."]"
        formname = "loadbot,"..key
    elseif mode == "delete" then
        formspec = "size[5,9]no_prepend[]"..
                 "image_button_exit[4,8;1,1;vbots_gui_check.png;ok;]"..
                 "bgcolor[#F00]"..
                 "textlist[0,0;4,9;saved;"..bot_list.."]"
        formname = "delete,"..key
    elseif mode == "rename" then
        formspec = "size[5,9]no_prepend[]"..
                 "image_button_exit[4,8;1,1;vbots_gui_check.png;ok;]"..
                 "bgcolor[#0F0]"..
                 "textlist[0,0;4,9;saved;"..bot_list.."]"
        formname = "rename,"..key
    elseif mode:sub(1,10) == "renamefrom" then
        local fromname = mode:sub(12)
        formspec = "size[6,6]no_prepend[]"..
                 "image_button_exit[5,5;1,1;vbots_gui_check.png;ok;]"..
                 "bgcolor[#00F]"..
                 "field[0,0;5,2;oldname;Old Name;"..fromname.."]"..
                 "field[0,1;5,4;newname;New Name;]"
        formname = "renamefrom,"..key
    end
    minetest.after(0.2, minetest.show_formspec, player:get_player_name(), formname, formspec)
end




vbots.bot_togglestate = function(pos,mode)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)
    local timer = minetest.get_node_timer(pos)
    local newname
    if not mode then
        if node.name == "vbots:off" then
            mode = "on"
        elseif node.name == "vbots:on" then
            mode = "off"
        end
    end
    if mode == "on" then
        newname = "vbots:on"
        timer:start(1/meta:get_int("steptime"))
        meta:set_int("PC",0)
        meta:set_int("PR",0)
        meta:set_string("stack","")
        meta:set_string("home",minetest.serialize(pos))
    elseif mode == "off" then
        newname = "vbots:off"
        timer:stop()
        meta:set_int("PC",0)
        meta:set_int("PR",0)
        meta:set_string("stack","")
    end
    --print(node.name.." "..newname)
    if newname then
        minetest.swap_node(pos,{name=newname, param2=node.param2})
    end
end


dofile(vbots.modpath.."/formspec.lua")
dofile(vbots.modpath.."/formspec_handler.lua")
dofile(vbots.modpath.."/register_bot.lua")
dofile(vbots.modpath.."/register_commands.lua")
dofile(vbots.modpath.."/register_joinleave.lua")
