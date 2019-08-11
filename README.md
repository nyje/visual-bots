# visual-bots
## A minetest programmable bot 
### (c) 2019 Nigel Garnett
Vbots are single block "turtle" style bots, programmable in an entirely visual way.
They came into existence to amuse my 5 year old daughters, and teach them the basics
of computer programming, without too much writing.

## Basics
Punch an idle vbot with an empty hand to make it run it's program (or click the run icon in the menu [see below]).

Punch a running vbot with an empty hand to stop the program.

Right click (double tap on android) to open the menu (see below).

Dig the bot by hitting it with anything except an empty hand, but bear in mind the bot can only be 
dug out if it's inventory is empty.

## The Main menu

![Main Menu 1](/images/doc_menu1.png)

The icons ![commands](/textures/vbots_gui_commands.png) and ![inventory](/textures/vbots_location_inventory.png) are used to switch between the 2 panels shown here.

The panel above contains the commands for the bot, which can be added to the current sub-program (the red area on the right) simply by clicking on them.

The panel below shows the inventory panel, with the bot's inventory above, and the players inventory below.
This panel is used to add things to the bot's inventory (so it can build with them) or to remove things from the bot's inventory after it has been digging.


![Main Menu 2](/images/doc_menu2.png)

The trash ![Trash](/textures/vbots_gui_trash.png) icon, when pressed, deletes the last instruction on the current sub-program page. Next to this icon is another 1x1 inventory slot which works as a trash can, anything dropped into it is destroyed.

The run ![run](/textures/vbots_gui_run.png) icon, works like punching the bot with an open hand, It starts the program runnng.

The save ![save](/textures/vbots_gui_save.png) icon saves the current program & sub-programs under the name of the bot.

the load ![load](/textures/vbots_gui_load.png) icon allows you to choose and load a program into the bot. Also on this menu are icons which allow the deleting & renaming of programs. 

The reset ![reset](/textures/vbots_gui_nuke.png) icon clears the main program, and all subprograms, but NOT the bot's inventory.

The sub-program panel (the red one on the right) has 7 pages.
The ![Lion](/textures/vbots_program_0.png) icon is the page for the 'Main' program, execution starts here when the bot is activated.
The other 6 pages are sub-programs which can be called via the 6 'run sub program' icons at the bottom of the command panel.
![dinosaur](/textures/vbots_run_1.png)
![goat](/textures/vbots_run_2.png)
![horse](/textures/vbots_run_3.png)
![parrot](/textures/vbots_run_4.png)
![bear](/textures/vbots_run_5.png)
![rhino](/textures/vbots_run_6.png)

### Movement
![forward](/textures/vbots_move_forward.png)
![backward](/textures/vbots_move_backward.png)
![up](/textures/vbots_move_up.png)
![down](/textures/vbots_move_down.png)
Move the bot forward, backward, up or down. Movement will fail if the new position is not empty.

![home](/textures/vbots_move_home.png)
Move the bot back to the position where the bot was placed. Note: the facing of the bot is NOT restored to it's initial facing direction.

![clockwise](/textures/vbots_turn_clockwise.png)
![anticlockwise](/textures/vbots_turn_anticlockwise.png)
![random](/textures/vbots_turn_random.png)
These commands turn the bot clockwise, anticlockwise or in a random direction.

### Actions

![dig up](/textures/vbots_mode_dig_up.png)
![dig down](/textures/vbots_mode_dig_down.png)
![dig](/textures/vbots_mode_dig.png)
These commands make the bot dig the node in that direction, and then move into the place it dug from. Note: digging will fail if the node being dug has protection which the owner of the bot could not dig.

![build up](/textures/vbots_mode_build_up.png)
![build down](/textures/vbots_mode_build_down.png)
![build](/textures/vbots_mode_build.png)
These commands make the bot place a block in the noted position (if protection allows and the position is empty).
The node placed by the bot is the first thing found in the bot's inventory, starting from the first slot.

### Special

![speed](/textures/vbots_mode_speed.png)
This pseudo command chooses the speed that the bot runs the program. when followed by a number multiplier it will make the bot run that many times faster. When NOT followed by a number, it resets the bot to normal speed.

### Multipliers

![x2](/textures/vbots_number_2.png)
![x3](/textures/vbots_number_3.png)
![x4](/textures/vbots_number_4.png)
![x5](/textures/vbots_number_5.png)
![x6](/textures/vbots_number_6.png)
![x7](/textures/vbots_number_7.png)
![x8](/textures/vbots_number_8.png)
![x9](/textures/vbots_number_9.png)
The Multipliers work the same for all commands except speed (explained above). For all other commands (including call sub-program commands) they make that command run multiple times.

## Example1

![forward](/textures/vbots_move_forward.png)
![x4](/textures/vbots_number_4.png)
![clockwise](/textures/vbots_turn_clockwise.png)
![x2](/textures/vbots_number_2.png)
![forward](/textures/vbots_move_forward.png)
![x4](/textures/vbots_number_4.png)
![clockwise](/textures/vbots_turn_clockwise.png)
![x2](/textures/vbots_number_2.png)

This program makes the bot move 4 spaces forward (if possible) then turn 180 degrees, move 4 spaces forward (ie back to the start position) and then turn 180 degrees again to face the initial direction.

## Example2 
### (just example1 using a sub-program)

In the dinosaur ![dinosaur](/textures/vbots_program_1.png) sub program put the following:
![forward](/textures/vbots_move_forward.png)
![x4](/textures/vbots_number_4.png)
![clockwise](/textures/vbots_turn_clockwise.png)
![x2](/textures/vbots_number_2.png)


Then, in the main ![lion](/textures/vbots_program_0.png) program ( the lion), just call it twice like this:
![dinosaur](/textures/vbots_run_1.png)
![x2](/textures/vbots_number_2.png)






Have fun.
  Nigel
