
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
    local my_bot_info = {}
    for bot_key,bot_data in pairs( vbots.bot_info) do
        if bot_data.owner == name then
            local pos = vbots.bot_info[bot_key].pos
            local meta = minetest.get_meta(pos)
            local bot_name = meta:get_string("name")
            if bot_name~="" then
                my_bot_info[bot_key] = vbots.bot_info[bot_key]
                local bot_owner = meta:get_string("owner")
                meta:set_string("infotext", "Sleeping Vbot " ..
                                            bot_name .. " (" .. bot_owner .. ")")
                meta:set_int("running",-1)
            end
            vbots.bot_info[bot_key] = nil
        end
    end
    print(name.." leaves game")
    print(dump(vbots.bot_info))
    vbots.storage:set_string(name, minetest.serialize(my_bot_info))
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
    local data = vbots.storage:get_string(name)
    local storetable = minetest.deserialize( vbots.storage:get_string(name))
    local my_bot_info = {}
    if storetable then
        for bot_key,bot_data in pairs( storetable) do
            local pos = bot_data.pos
            local meta = minetest.get_meta(pos)
            local bot_name = meta:get_string("name")
            if bot_name~="" then
                vbots.bot_info[bot_key] = bot_data
                my_bot_info[bot_key] = bot_data
                local bot_owner = meta:get_string("owner")
                print("Loading "..dump(bot_name))
                meta:set_string("infotext", "Vbot " ..
                                            bot_name .. " owned by " .. bot_owner)
                meta:set_int("running",0)
            else
                vbots.bot_info[bot_key] = nil
            end
        end
        vbots.storage:set_string(name, minetest.serialize(my_bot_info))
    end
    print(name.." joins game")
    print(dump(vbots.bot_info))
end)

