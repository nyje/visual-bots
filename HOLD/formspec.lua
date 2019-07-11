

local function highlight(item,line,w,h,r,g,b)
    local item = item - 0.09
    local line = line - 0.07
    return "box[" .. item .. "," .. line .. ";" .. w .. "," .. h .. ";#" ..
            r..r .. g..g .. b..b .."90]"
end

local function button(x,y,image,name,exit)
    if not exit then
        return "image_button["..x..","..y..";1,1;"..image..";"..name..";]"
    else
        return "image_button_exit["..x..","..y..";1,1;"..image..";"..name..";]"
    end
end

local function cbutton(x,y,name)
    return "image_button["..x..","..y..";1,1;vbots_"..name..".png;"..name..";]"
end

local function panel_playerinv()
    return "list[current_player;main;0,5;8,4;]"
           .."listring[current_player;main]"
           --..highlight(0,5,8,4,"a","f","a")
end

local function panel_botinv(pos)
    return "list[nodemeta:" .. pos .. ";main;0,1;8,4;]"
           .."listring[nodemeta:" .. pos .. ";main]"
           ..highlight(0,1,8,4,"a","a","f")
end

local function panel_commands()
    return   cbutton(0,1,"move_forward")
           ..cbutton(1,1,"move_backward")
           ..cbutton(2,1,"move_left")
           ..cbutton(3,1,"move_right")
           ..cbutton(4,1,"move_up")
           ..cbutton(5,1,"move_down")

           ..cbutton(0,2,"turn_clockwise")
           ..cbutton(1,2,"turn_anticlockwise")
           ..cbutton(2,2,"turn_random")
           ..cbutton(3,2,"climb_up")
           ..cbutton(4,2,"climb_down")

           ..cbutton(0,3,"number_1")
           ..cbutton(1,3,"number_2")
           ..cbutton(2,3,"number_3")
           ..cbutton(3,3,"number_4")
           ..cbutton(4,3,"number_5")
           ..cbutton(5,3,"number_6")

           ..cbutton(0,4,"case_repeat")
           ..cbutton(1,4,"case_test")
           ..cbutton(2,4,"case_yes")
           ..cbutton(3,4,"case_no")
           ..cbutton(4,4,"case_success")
           ..cbutton(5,4,"case_failure")
           ..cbutton(6,4,"case_end")

           ..cbutton(0,5,"mode_pause")
           ..cbutton(1,5,"mode_wait")
           ..cbutton(2,5,"mode_dig")
           ..cbutton(3,5,"mode_build")
           ..cbutton(4,5,"mode_examine")
           ..cbutton(5,5,"mode_walk")
           ..cbutton(6,5,"mode_fly")

           ..cbutton(0,8,"run_1")
           ..cbutton(1,8,"run_2")
           ..cbutton(2,8,"run_3")
           ..cbutton(3,8,"run_4")
           ..cbutton(4,8,"run_5")
           ..cbutton(5,8,"run_6")

           ..highlight(0,1,7,8,"a","a","f")
end

local function panel_main(pos,mode)
    local panel
    if mode == 0 then
        panel = panel_commands()
    else
        panel = panel_playerinv()
                ..panel_botinv(pos)
    end
    return panel
           ..button(0.5,0,"vbots_gui_commands.png","commands")
           ..button(1.5,0,"vbots_location_inventory.png","player_inv")
           ..highlight(0.5+mode,0,1,1,"a","a","f")
end

local function panel_code(pos,program)
    return button(8,0,"vbots_gui_run.png","run",true)
           ..button(9,0,"vbots_gui_check.png","check")
           ..button(10,0,"vbots_gui_load.png","load")
           ..button(11,0,"vbots_gui_save.png","save")
           ..highlight(8,0,4,1,"5","5","f")

           ..button(15,0,"vbots_gui_exit.png","exit",true)
           ..highlight(15,0,1,1,"f","0","0")

           .."list[nodemeta:" .. pos .. ";p"..program..";8,1;7,8;]"
           ..highlight(8,1,7,8,"f","a","f")
           ..highlight(8,1,1,1,"f","f","f")
           .."listring[nodemeta:" .. pos .. ";p"..program.."]"

           ..button(15,1.5,"vbots_program_0.png","sub_0")
           ..button(15,2.5,"vbots_program_1.png","sub_1")
           ..button(15,3.5,"vbots_program_2.png","sub_2")
           ..button(15,4.5,"vbots_program_3.png","sub_3")
           ..button(15,5.5,"vbots_program_4.png","sub_4")
           ..button(15,6.5,"vbots_program_5.png","sub_5")
           ..button(15,7.5,"vbots_program_6.png","sub_6")
           ..highlight(15,1.5+program,1,1,"f","a","f")
end

function vbots.get_formspec(pos,meta)
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
                     .."label[3,0;\"" .. bot_name .. "\" (" .. bot_owner .. ")]"
                     ..panel_main(bot_pos,fs_panel)
                     ..panel_code(bot_pos,fs_program)
	return formspec
end
