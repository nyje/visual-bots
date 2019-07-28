
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
    --print(dump( fields))
    local bot_data = vbots.bot_info[bot_key]
    if bot_data then
        local inv=minetest.get_inventory({type="node", pos=bot_data.pos})
        local meta = minetest.get_meta(bot_data.pos)
        local meta_bot_key = meta:get_string("key")
        -- print(bot_key.." vs "..meta_bot_key)
        if bot_key == meta_bot_key then
            bot_key = bot_rekey(bot_key,meta)
            if fields.run then
                minetest.after(0, vbots.bot_togglestate, bot_data.pos, "on")
            end
            if fields.quit=="true" then
                return
            end
            if fields.commands then
                meta:set_int("panel", 0)
            end
            if fields.player_inv then
                meta:set_int("panel", 1)
            end
            if fields.trash then
                local last = 0
                local content = inv:get_list("p"..meta:get_int("program"))
                for a = 1,56 do
                    if not content[a]:is_empty() then last=a end
                end
                if last>0 then
                    inv:set_stack("p"..meta:get_int("program"), last, ItemStack(nil))
                end
            end
            if not fields.exit and not fields.run then
                for f,v in pairs(fields) do
                    local nametable=string.split(f, "_")
                    if #nametable>=2 then
                        if nametable[1]=="sub" then
                            meta:set_int("program", nametable[2])
                            -- print(dump(
                        end
                        if nametable[1]=="move" or
                                nametable[1]=="turn" or
                                nametable[1]=="number" or
                                nametable[1]=="climb" or
                                nametable[1]=="mode" or
                                nametable[1]=="case" or
                                nametable[1]=="run" then
                            --print("COMMAND!!!!!!!")
                            local leftover = inv:add_item("p"..meta:get_int("program"), ItemStack("vbots:"..f))
                        end
                    end
                end
                minetest.after(0, vbots.show_formspec, player, bot_data.pos)
            end
        end
    end
end)
