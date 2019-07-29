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
local STEPTIME = 0.3
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
        timer:start(1)
        meta:set_int("PC",STEPTIME)
        meta:set_int("PR",0)
        meta:set_string("stack","")
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
