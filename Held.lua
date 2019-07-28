if PR>0 then
            local stack = meta:get_string("stack")
            if stack then
                local heap = string.split(stack,",")
                if #heap > 1 then
                    print("XXX:"..dump(heap))
                    PC = heap[1]
                    meta:set_string("stack",stack:sub(#heap[1]+2))

                    PR = heap[2]
                    meta:set_string("stack",stack:sub(#heap[2]+1))
                end
            else
                PC = 0
                PR = 0
            end
            meta:set_int("PC",PC)
            meta:set_int("PR",PR)

            print("Back from sub. PC:"..PC.." PR:"..PR..", stack:"..meta:get_string("stack"))
            return true
        else
        end

    local nametable=string.split(item, "_")
    -- print(dump(nametable))
    if nametable[1]=="vbots:run" then
        local meta = minetest.get_meta(pos)
        local PC = meta:get_int("PC")
        local PR = meta:get_int("PR")
        meta:set_int("PR", nametable[2])
        local stack = meta:get_string("stack")
        meta:set_string("stack",PR..","..stack)
        meta:set_string("stack",PC..","..stack)
        meta:set_int("PC", 0)
        print("Called"..nametable[2]..", stack:"..stack)

    end
