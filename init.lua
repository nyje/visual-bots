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


vbots.save = function(pos)
    local meta = minetest.get_meta(pos)
    local meta_table = meta:to_table()
    local botname = meta:get_string("name")
    local inv_list = {}
    for i,t in pairs(meta_table.inventory) do
        for _,s in pairs(t) do
            if s and s:get_count()>0 then
                inv_list[#inv_list+1] = i.." "..s:get_name().." "..s:get_count()
            end
        end
    end
    mod_storage:set_string(botname,minetest.serialize(inv_list))
end

vbots.load = function(pos,player,mode)
    local meta = minetest.get_meta(pos)
    local key = meta:get_string("key")
    local data = mod_storage:to_table().fields
    local bot_list = ""
    for n,d in pairs(data) do
        bot_list = bot_list..n..","
    end
    bot_list = bot_list:sub(1,#bot_list-1)
    local formspec
    local formname
    if not mode then
        formspec = "size[5,9]"..
                 "image_button_exit[4,0;1,1;vbots_gui_delete.png;delete;]"..
                 "tooltip[4,0;1,1;delete]"..
                 "image_button_exit[4,1;1,1;vbots_gui_rename.png;rename;]"..
                 "tooltip[4,1;1,1;rename]"..
                 "textlist[0,0;4,9;saved;"..bot_list.."]"
        formname = "loadbot,"..key
    elseif mode == "delete" then
        formspec = "size[4,9]no_prepend[]"..
                 "bgcolor[#F00]"..
                 "textlist[0,0;4,9;saved;"..bot_list.."]"
        formname = "delete,"..key
    elseif mode == "rename" then
        formspec = "size[4,9]no_prepend[]"..
                 "bgcolor[#0F0]"..
                 "textlist[0,0;4,9;saved;"..bot_list.."]"
        formname = "rename,"..key
    elseif mode:sub(1,8) == "renameto" then
        local fromname = mode:sub(10)
        formspec = "size[5,5]no_prepend[]"..
                 "bgcolor[#00F]"..
                 "field[0,0;5,2;oldname;Old Name;"..fromname.."]"..
                 "field[0,1;5,4;newname;New Name;]"
        formname = "renameto,"..key
    end
    minetest.after(0.2, minetest.show_formspec, player:get_player_name(), formname, formspec)
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
