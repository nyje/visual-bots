-- Visual Bots v0.3
-- (c)2019 Nigel Garnett.
--
-- see licence.txt
--

vbots={}
vbots.modpath = minetest.get_modpath("vbots")
vbots.storage = minetest.get_mod_storage()
vbots.bot_info = {}

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
-- Clean up bot table and bot storage for player
-------------------------------------
function vbots.clean_bots_for(name)
    local my_bot_info = {}
    for bot_key,bot_data in pairs( vbots.bot_info) do
        if bot_data.owner == name then
            local pos = vbots.bot_info[bot_key].pos
            local meta = minetest.get_meta(pos)
            local bot_name = meta:get_string("name")
            if bot_name~="" then
                my_bot_info[bot_key] = vbots.bot_info[bot_key]
            else
                vbots.bot_info[bot_key] = nil
            end
        end
    end
    print(name.." cleaned")
    print(dump(vbots.bot_info))
    vbots.storage:set_string(name, minetest.serialize(my_bot_info))
end

dofile(vbots.modpath.."/formspec.lua")
dofile(vbots.modpath.."/formspec_handler.lua")
dofile(vbots.modpath.."/register_bot.lua")
dofile(vbots.modpath.."/register_commands.lua")
dofile(vbots.modpath.."/register_joinleave.lua")
