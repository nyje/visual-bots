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
local mod_storage = minetest.get_mod_storage()


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

vbots.load = function(pos,player)
    local data = mod_storage:to_table().fields
    local bot_list = ""
    for n,d in pairs(data) do
        bot_list = bot_list..n..","
    end
    bot_list = bot_list:sub(1,#bot_list-1)
    local formspec = "size[5,9;]"..
                     "textlist[0,0;5,9;saved;"..bot_list.."]"
    local formname = "loadbot,"..pos.x..","..pos.y..","..pos.z
    minetest.show_formspec(player:get_player_name(), formname, formspec)
end

minetest.register_on_player_receive_fields(function(player, key, fields)
    local form_pos = string.split(key,",")
    if #form_pos == 4 and form_pos[1] == "loadbot" then
        local pos={ x = form_pos[2], y = form_pos[3], z = form_pos[4] }
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()

        local data = mod_storage:to_table().fields
        local bot_list = {}
        for n,d in pairs(data) do
            bot_list[#bot_list+1] = n
        end
        minetest.close_formspec(player:get_player_name(), key)
        if fields.saved then
            local bot_name = bot_list[tonumber(string.split(fields.saved,":")[2])]
            local inv_list = minetest.deserialize(data[bot_name])
            local inv_involved = {}
            if inv_list then
                for _,v in pairs(inv_list) do
                    local parts = string.split(v," ")
                    if #parts == 3 then
                        inv_involved[parts[1]]=true
                    end
                end
                -- print(dump(inv_involved))
                for i,_ in pairs(inv_involved) do
                    size = inv:get_size(i)
                    for a=1,size do
                        inv:set_stack(i,a, "")
                    end
                end
                for _,v in pairs(inv_list) do
                    local parts = string.split(v," ")
                    if #parts == 3 then
                        inv:add_item(parts[1],parts[2].." "..parts[3])
                    end
                end
            end
        end
    end
end)

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
