
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
    for bot_key,bot_data in pairs( vbots.bot_info) do
        local owner_present = minetest.get_player_by_name(bot_data.owner)
        if bot_data.owner == name  or not owner_present then
            local meta = minetest.get_meta(bot_data.pos)
            local bot_name = meta:get_string("name")
            if bot_name~="" then
                meta:set_string("infotext", bot_name .. " (" ..
                                            bot_data.owner .. ") [Inactive]")
            end
            vbots.bot_info[bot_key] = nil
        end
    end
    --print(dump(vbots.bot_info))
end)

minetest.register_on_joinplayer(function(player)
    --print(dump(vbots.bot_info))
end)

