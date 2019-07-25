
-------------------------------------
-- generate new key & move data in table
-------------------------------------
local function bot_rekey(bot_key,meta)
    local new_key = vbots.get_key()
    vbots.bot_info[new_key] = vbots.bot_info[bot_key]
    vbots.bot_info[bot_key] = nil
    meta:set_string("key", new_key)
    return new_key
end

minetest.register_on_player_receive_fields(function(player, bot_key, fields)
    local bot_data = vbots.bot_info[bot_key]
    if bot_data then
        local meta = minetest.get_meta(bot_data.pos)
        local meta_bot_key = meta:get_string("key")
        --print(bot_key.." vs "..meta_bot_key)
        if bot_key == meta_bot_key then
            bot_key = bot_rekey(bot_key,meta)
            if fields.quit=="true" then
                return
            end
            if not fields.exit and not fields.run then
                if fields.commands then
                    meta:set_int("panel", 0)
                end
                if fields.player_inv then
                    meta:set_int("panel", 1)
                end
                for f,v in pairs(fields) do
                    local nametable=string.split(f, "_")
                    if #nametable>=2 then
                        if nametable[1]=="sub" then
                            meta:set_int("program", nametable[2])
                        end
                        if nametable[1]=="move" or
                                nametable[1]=="turn" or
                                nametable[1]=="number" or
                                nametable[1]=="climb" or
                                nametable[1]=="mode" or
                                nametable[1]=="case" or
                                nametable[1]=="run" then
                            --print("COMMAND!!!!!!!")
                            local inv=minetest.get_inventory({
                                type="node",
                                pos=bot_data.pos
                            })
                            local leftover = inv:add_item("p0", ItemStack("vbots:"..f))
                        end
                    end
                end
                --print(dump( fields))
                minetest.after(0, vbots.show_formspec, player, bot_data.pos)
            end
        end
    end
end)
