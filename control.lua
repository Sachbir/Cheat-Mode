-- Cheat Mode Softmod
-- A softmod (server-side mod) that creates a better interface for some handy cheat commands
-- Author: Sachbir Dhanota 
-- Github: https://github.com/Sachbir
-- With much help from: 
-- Denis Zholob (DDDGamer) - https://github.com/DDDGamer
-- AngamaraOnline
-- /u/Tinnvec for the original inspiration - https://www.reddit.com/r/factorio/comments/7qc8sy/creative_mode_without_mod
-- ============================================================= --

-- Modifications to this document are to remain minimal and clear
--  This is to increase the ease of compatibility and further modification

global.Spaghetti = {}

require("config")
require("locale/FSM-core/util/Unsorted_Functions")

require("locale/FSM-modules/Main_Menu")
require("locale/FSM-modules/Cheat_Panel")
require("locale/FSM-modules/Trash_Button")
require("locale/FSM-modules/Death_Markers")

local silo_script = require("silo-script")
local version = 1

-- Modified to eliminate the intro message on startup
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
  -- if (#game.players <= 1) then
  --   game.show_message_dialog{text = {"msg-intro"}}
  -- else
  --   player.print({"msg-intro"})
  -- end
  silo_script.on_player_created(event)
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

-- Modified to add the Cheat Panel's gui click handling
script.on_event(defines.events.on_gui_click, function(event)
  trashButton.on_gui_click(event)
  mainMenu.on_gui_click(event)
  Cheat_Panel_On_Gui_Click(event)
  silo_script.on_gui_click(event)
end)

script.on_init(function()
  global.version = version
  silo_script.on_init()
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  silo_script.on_rocket_launched(event)
end)

script.on_configuration_changed(function(event)
  if global.version ~= version then
    global.version = version
  end
  silo_script.on_configuration_changed(event)
end)

silo_script.add_remote_interface()
silo_script.add_commands()

-- ============================================================= --
-- Additional Event Handlers
-- ============================================================= --

script.on_event(defines.events.on_player_joined_game, function(event)
	local player = game.players[event.player_index]
	reloadGlobalTable() 
	mainMenu.on_player_joined_game(player)
	if (global.Spaghetti.Cheat_Panel) then
		Cheat_Panel_On_Player_Joined_Game(event)
	end
	if (global.Spaghetti.trashButton) then
		trashButton.on_player_joined_game(player)
	end
end)

script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]
  mainMenu.on_player_left_game(player)
  Cheat_Panel_On_Player_Left_Game(event)
  trashButton.on_player_left_game(player)
end)

script.on_event(defines.events.on_pre_player_died, function(event)
	local player = game.players[event.player_index]
	deathMarkers.on_pre_player_died(player)
end)

script.on_nth_tick(60, function()
  Cheat_Panel_On_60th_Tick()
end)

script.on_nth_tick(3600, function()
	deathMarkers.on_3600th_tick()
end)