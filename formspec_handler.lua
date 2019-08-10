
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
    -- Bot main formspec
    if bot_data then
        -- print("Main Bot formspec received:")
        local inv=minetest.get_inventory({type="node", pos=bot_data.pos})
        local meta = minetest.get_meta(bot_data.pos)
        local meta_bot_key = meta:get_string("key")
        -- print(bot_key.." vs "..meta_bot_key)
        if bot_key == meta_bot_key then
            bot_key = bot_rekey(bot_key,meta)
            if fields.run then
                minetest.after(0, vbots.bot_togglestate, bot_data.pos, "on")
            end
            if fields.save then
                vbots.save(bot_data.pos)
            end
            if fields.load then
                vbots.load(bot_data.pos,player)
            end
            if fields.reset then
                vbots.wipe_programs(bot_data.pos)
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
                                nametable[1]=="mode" or
                                nametable[1]=="run" then
                            --print("COMMAND!!!!!!!")
                            local leftover = inv:add_item("p"..meta:get_int("program"), ItemStack("vbots:"..f))
                        end
                    end
                end
                minetest.after(0, vbots.show_formspec, player, bot_data.pos)
            end
        end
    else
        local form_parts = string.split(bot_key,",")
        local data = mod_storage:to_table()
        local bot_list = {}
        for n,d in pairs(data.fields) do
            bot_list[#bot_list+1] = n
        end
        if #form_parts == 2 and form_parts[1] == "loadbot" then
            -- print("Load Bot formspec received")
            local bot_data = vbots.bot_info[form_parts[2]]
            local pos=bot_data.pos
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()

            minetest.close_formspec(player:get_player_name(), bot_key)
            if fields.delete then
                vbots.load(pos,player,"delete")
            end
            if fields.rename then
                vbots.load(pos,player,"rename")
            end
            if fields.saved then
                local bot_name = bot_list[tonumber(string.split(fields.saved,":")[2])]
                -- print('Loadbot '..bot_name)
                local inv_list = minetest.deserialize(data.fields[bot_name])
                local inv_involved = {}
                if inv_list then
                    for _,v in pairs(inv_list) do
                        local parts = string.split(v," ")
                        if #parts == 3 then
                            inv_involved[parts[1]]=true
                        end
                    end
                    -- print(dump(inv_involved))
                    local size
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
        elseif #form_parts == 2 and form_parts[1] == "delete" then
            -- print("Delete Bot formspec received")
            local bot_data = vbots.bot_info[form_parts[2]]
            local pos=bot_data.pos
            minetest.close_formspec(player:get_player_name(), bot_key)
            if fields.saved then
                local bot_name = bot_list[tonumber(string.split(fields.saved,":")[2])]
                data.fields[bot_name]=nil
                mod_storage:from_table(data)
                --print(dump(mod_storage:to_table()))
            end
        elseif #form_parts == 2 and form_parts[1] == "rename" then
            -- print("Rename Bot formspec received")
            local bot_data = vbots.bot_info[form_parts[2]]
            local pos=bot_data.pos
            minetest.close_formspec(player:get_player_name(), bot_key)
            if fields.saved then
                local bot_name = bot_list[tonumber(string.split(fields.saved,":")[2])]
                -- print("renamefrom_"..bot_name)
                local parts = string.split(bot_name,",vbotsep,")
                if #parts == 2 and parts[1] == player:get_player_name() then
                    bot_name = parts[2]
                    -- print("renamefrom_"..bot_name)

                    vbots.load(pos,player,"renamefrom_"..bot_name)
                end

            end
        elseif #form_parts == 2 and form_parts[1] == "renamefrom" then
            -- print("Renameto formspec received")
            local bot_data = vbots.bot_info[form_parts[2]]
            local pos=bot_data.pos
            local pname = player:get_player_name()
            minetest.close_formspec(pname, bot_key)
            local oldname = fields.oldname
            local newname = fields.newname
            if newname and oldname then
                local hold = data.fields[pname..",vbotsep,"..oldname]
                data.fields[pname..",vbotsep,"..oldname] = nil
                data.fields[pname..",vbotsep,"..newname] = hold
                mod_storage:from_table(data)
                -- print("renamed "..pname..",vbotsep,"..oldname.." to "..pname..",vbotsep,"..newname)
            end
        end
    end
end)
