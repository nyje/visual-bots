local register_command = function(itemname,description,image)
    minetest.register_craftitem("vbots:"..itemname, {
        description = description,
        inventory_image = image,
        wield_image = "wieldhand.png",
        stack_max = 1,
        groups = { bot_commands = 1, not_in_creative_inventory = 1},
        on_place = function(itemstack, placer, pointed_thing)
            return nil
        end,
        on_drop = function(itemstack, dropper, pos)
            return nil
        end,
        --on_use = function(itemstack, user, pointed_thing)
        --    return nil
        --end
    })
end

register_command("move_forward","Move bot forward","vbots_move_forward.png")
register_command("move_backward","Move bot backward","vbots_move_backward.png")
register_command("move_up","Move bot up","vbots_move_up.png")
register_command("move_down","Move bot down","vbots_move_down.png")
register_command("move_home","Move bot to start position","vbots_move_home.png")

register_command("turn_clockwise","Turn bot 90° clockwise","vbots_turn_clockwise.png")
register_command("turn_anticlockwise","Move bot 90° anti-clockwise","vbots_turn_anticlockwise.png")
register_command("turn_random","Move bot 90° in a random direction","vbots_turn_random.png")

-- register_command("case_end","End section","vbots_case_end.png")
-- register_command("case_failure","Last action failed","vbots_case_failure.png")
-- register_command("case_success","Last action succeeded","vbots_case_success.png")
-- register_command("case_yes","Yes","vbots_case_yes.png")
-- register_command("case_no","No","vbots_case_no.png")
-- register_command("case_test","Test","vbots_case_test.png")
-- register_command("case_repeat","Repeat","vbots_case_repeat.png")

register_command("mode_build","Place a block behind the bot","vbots_mode_build.png")
register_command("mode_build_up","Place a block above the block behind the bot","vbots_mode_build_up.png")
register_command("mode_build_down","Place a block below the block behind the bot","vbots_mode_build_down.png")

register_command("mode_speed","set bot speed","vbots_mode_speed.png")
register_command("mode_dig","Dig the block in front","vbots_mode_dig.png")
register_command("mode_dig_up","Dig the block above the block in front","vbots_mode_dig_up.png")
register_command("mode_dig_down","Dig the block below the block in front","vbots_mode_dig_down.png")

-- register_command("mode_examine","Examine the block in the direction of the next command","vbots_mode_examine.png")
-- register_command("mode_pause","Wait for a few seconds","vbots_mode_pause.png")
-- register_command("mode_wait","Wait until next event","vbots_mode_wait.png")

--register_command("number_1","1","vbots_number_1.png")
register_command("number_2","2","vbots_number_2.png")
register_command("number_3","3","vbots_number_3.png")
register_command("number_4","4","vbots_number_4.png")
register_command("number_5","5","vbots_number_5.png")
register_command("number_6","6","vbots_number_6.png")
register_command("number_7","7","vbots_number_7.png")
register_command("number_8","8","vbots_number_8.png")
register_command("number_9","9","vbots_number_9.png")
--register_command("number_0","0","vbots_number_0.png")

register_command("run_1","Run sub-program 1","vbots_run_1.png")
register_command("run_2","Run sub-program 2","vbots_run_2.png")
register_command("run_3","Run sub-program 3","vbots_run_3.png")
register_command("run_4","Run sub-program 4","vbots_run_4.png")
register_command("run_5","Run sub-program 5","vbots_run_5.png")
register_command("run_6","Run sub-program 6","vbots_run_6.png")

