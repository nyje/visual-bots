
-------------------------------------
-- Formspec colored boxes
-------------------------------------
local function highlight(item,line,w,h,r,g,b)
    local item = item - 0.09
    local line = line - 0.06
    return "box[" .. item .. "," .. line .. ";" .. w .. "," .. h .. ";#" ..
           r..r .. g..g .. b..b .."90]"
end


-------------------------------------
-- Formspec button generators
-------------------------------------
local function button(x,y,image,name,exit)
    if not exit then
        return  "image_button["..x..","..y..";1,1;"..image..";"..name..";]"..
                "tooltip["..x..","..y..";1,1;"..name.."]"
    else
        return "image_button_exit["..x..","..y..";1,1;"..image..";"..name..";]"..
                "tooltip["..x..","..y..";1,1;"..name.."]"
    end
end

local function cbutton(x,y,name)
    return "image_button["..x..","..y..";1,1;vbots_"..name..".png;"..name..";]"..
           "tooltip["..x..","..y..";1,1;"..name.."]"
end

local function button_row(x,y,nametable)
    local row = ""
    for i,name in pairs(nametable) do
        row = row .. cbutton(x+i-1,y,name)
    end
    return row
end

-------------------------------------
-- Main panel generators
-------------------------------------
local function panel_commands()
    local commands = {
        {"move_forward","move_backward","move_up","move_down","move_home"},
        {"turn_clockwise","turn_anticlockwise","turn_random"},
        {"mode_dig_up","mode_dig","mode_dig_down"},
        {"mode_build_up","mode_build","mode_build_down"},
        --{"case_repeat","case_test","case_end","case_success","case_failure","case_yes","case_no" },
        --{"mode_examine","mode_pause","mode_wait"},
        {"mode_speed"},
        {"number_2","number_3","number_4","number_5"},
        {"number_6","number_7","number_8","number_9"},
        {"run_1","run_2","run_3","run_4","run_5","run_6"}
    }
    local panel = highlight(0,1,7,8,"a","a","f")
    for row,namelist in pairs(commands) do
        panel = panel .. button_row(0,row,namelist)
    end
    return panel
end

local function panel_main(pos,mode)
    local panel
    if mode == 0 then
        panel = panel_commands()
    else
        panel = "list[current_player;main;0,5;8,4;]"..
                "list[nodemeta:" .. pos .. ";main;0,1;8,4;]"..
                "listring[current_player;main]"..
                "listring[nodemeta:" .. pos .. ";main]"..
                highlight(0,1,8,4,"a","a","f")
    end
    return panel
           ..button(0.5,0,"vbots_gui_commands.png","commands")
           ..button(1.5,0,"vbots_location_inventory.png","player_inv")
           ..highlight(0.5+mode,0,1,1,"a","a","f")
end


-------------------------------------
-- Main panel generator
-------------------------------------
local function panel_code(pos,program)
    return button(9,0,"vbots_gui_run.png","run",true)
           --..button(11,0,"vbots_gui_check.png","check")
           ..button(14,0,"vbots_gui_nuke.png","reset")
           ..button(11,0,"vbots_gui_load.png","load",true)
           ..button(12,0,"vbots_gui_save.png","save",true)
           ..highlight(9,0,1,1,"5","5","f")
           ..highlight(14,0,1,1,"5","5","f")
           ..highlight(11,0,2,1,"5","5","f")

           ..button(15,0,"vbots_gui_exit.png","exit",true)
           ..highlight(15,0,1,1,"f","0","0")

           ..button(6.5,0,"vbots_gui_trash.png","trash")
           .."list[detached:bottrash;main;7.5,0;1,1;]"
--           .."listring[nodemeta:" .. pos .. ";p"..program.."]"
           ..highlight(6.5,0,2,1,"0","0","0")

           .."list[nodemeta:" .. pos .. ";p"..program..";8,1;7,8;]"
--           .."listring[detached:bottrash;main]"
           ..highlight(8,1,7,8,"f","a","f")

           ..button(15,1.5,"vbots_program_0.png","sub_0")
           ..button(15,2.5,"vbots_program_1.png","sub_1")
           ..button(15,3.5,"vbots_program_2.png","sub_2")
           ..button(15,4.5,"vbots_program_3.png","sub_3")
           ..button(15,5.5,"vbots_program_4.png","sub_4")
           ..button(15,6.5,"vbots_program_5.png","sub_5")
           ..button(15,7.5,"vbots_program_6.png","sub_6")
           ..highlight(15,1.5+program,1,1,"f","a","f")

           ..highlight(8,1,1,1,"f","f","f")

end


-------------------------------------
-- Formspec generator
-------------------------------------
local function get_formspec(pos,meta)
    local bot_key = meta:get_string("key")
    local bot_owner = meta:get_string("owner")
    local bot_name = meta:get_string("name")
	local bot_pos = pos.x .. "," .. pos.y .. "," .. pos.z
    local fs_panel = meta:get_int("panel")
    local fs_program = meta:get_int("program")
    --print(dump(meta:to_table().fields))
	--print("Panel:"..fs_panel)
	--print("Program:"..fs_program)
    local formspec = "size[16,9]"
                     .."label[3,0;\"" ..bot_name.. "\" (" ..bot_owner.. ")]"
                     ..panel_main(bot_pos,fs_panel)
                     ..panel_code(bot_pos,fs_program)
	return formspec
end


-------------------------------------
-- callback from bot node on_rightclick
-------------------------------------
function vbots.show_formspec(clicker,pos)
    local meta = minetest.get_meta(pos)
    local bot_key = meta:get_string("key")
    minetest.show_formspec( clicker:get_player_name(),
                            bot_key ,
                            get_formspec(pos,meta)
    )
end

