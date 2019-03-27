-- Main Menu
-- This cheat panel is getting too big (and is drifting away from the "cheat panel" angle) so this is a menu to manage the components
-- Author: Sachbir Dhanota
-- Github: https://github.com/Sachbir
-- ============================================================= -- 

require("locale/FSM-core/util/GUI")

mainMenu = {}

function mainMenu.on_player_joined_game(player)

	mainMenu.drawButton(player)
end

function mainMenu.on_player_left_game(player)
	
	if player.gui.top.mainMenuButton then
		player.gui.top.mainMenuButton.destroy()
	end
	if player.gui.left.leftFlow then
		player.gui.left.leftFlow.destroy()
	end
end

function mainMenu.on_gui_click(event)

	player = game.players[event.player_index]

	-- 'Structural' Buttons
	if event.element.name == "mainMenuButton" then
		
		if player.gui.left.leftFlow == nil then
			player.gui.left.add{ type="flow", name="leftFlow", direction="horizontal" }
		end
		if player.gui.left.leftFlow.mainMenuPanel then
			player.gui.left.leftFlow.clear()	
		else
			player.gui.left.leftFlow.clear()
			mainMenu.drawMain(player)
		end
	elseif event.element.name == "mainMenuSettings" then
		if player.gui.left.leftFlow.mainMenuSettings then
			GUI.toggle_element(player.gui.left.leftFlow.mainMenuSettings, player.gui.left.leftFlow.mainMenuServerDefaults)
		else
			mainMenu.drawSettings(player)
			if player.gui.left.leftFlow.mainMenuServerDefaults then
				player.gui.left.leftFlow.mainMenuServerDefaults.style.visible = false
			end
		end
	elseif event.element.name == "mainMenuServerDefaults" then
		if player.gui.left.leftFlow.mainMenuServerDefaults then
			GUI.toggle_element(player.gui.left.leftFlow.mainMenuServerDefaults, player.gui.left.leftFlow.mainMenuSettings)
		else
			mainMenu.drawServerDefaults(player)
			if player.gui.left.leftFlow.mainMenuSettings then
				player.gui.left.leftFlow.mainMenuSettings.style.visible = false
			end
		end
	-- 'Functional' Buttons
	elseif event.element.name == "localToggleTrashButton" then
		if player.gui.top.trashButton then
			GUI.toggle_element(player.gui.top.trashButton)
		else
			trashButton.drawButton(player)
		end
	elseif event.element.name == "localToggleCheatMenu" then
		if player.gui.top.cheat_button then
			GUI.toggle_element(player.gui.top.cheat_button)
		else
			draw_cheat_button(player)
		end
	elseif event.element.name == "serverDefaultsToggleTrashButton" then
		global.Spaghetti.trashButton = ifTrueThenFalseElseTrue(global.Spaghetti.trashButton)
		player.print("Trash Button Default has been set to " .. tostring(global.Spaghetti.trashButton))
	elseif event.element.name == "serverDefaultsToggleCheatModeAccess" then
		global.Spaghetti.Cheat_Panel = ifTrueThenFalseElseTrue(global.Spaghetti.Cheat_Panel)
		player.print("Cheat Panel Default has been set to " .. tostring(global.Spaghetti.Cheat_Panel))
	elseif event.element.name == "serverDefaultsToggleDeathMarkers" then
		global.Spaghetti.deathMarkers = ifTrueThenFalseElseTrue(global.Spaghetti.deathMarkers)
		player.print("Death Markers Default has been set to " .. tostring(global.Spaghetti.deathMarkers))
		if not global.Spaghetti.deathMarkers then
			player.print("No new markers will be placed")
		end
	end
end

function mainMenu.drawButton(player)

	if player.gui.top.mainMenuButton == nil then
		player.gui.top.add{ type="sprite-button", name="mainMenuButton", sprite="item/blueprint-book"}
		player.gui.top.mainMenuButton.style.height = 42
	end
	if player.gui.left.leftFlow == nil then
		player.gui.left.add{ type="flow", name="leftFlow" }
	end
end

function mainMenu.drawMain(player)

	if player.gui.left.leftFlow.mainMenuPanel == nil then
		player.gui.left.leftFlow.add{ type="frame", name="mainMenuPanel", direction="vertical" }
	else
		player.gui.left.leftFlow.mainMenuPanel.clear()
	end
	local mainMenuPanel = player.gui.left.leftFlow.mainMenuPanel

	mainMenuPanel.add{ type="label", name="heading", caption="Main Menu" }
		mainMenuPanel.heading.style.font = "default-large-bold"
	mainMenuPanel.add{ type="button", name="mainMenuSettings", caption="Settings" }
	if player == game.players[1] then
		mainMenuPanel.add{ type="button", name="mainMenuServerDefaults", caption="Server Defaults" }
	end
end

function mainMenu.drawSettings(player)
	
	if player.gui.left.leftFlow.mainMenuSettings == nil then
		player.gui.left.leftFlow.add{ type="frame", name="mainMenuSettings", direction="vertical" }
	else
		player.gui.left.leftFlow.mainMenuSettings.clear()
	end
	local mainMenuSettings = player.gui.left.leftFlow.mainMenuSettings

	mainMenuSettings.add{ type="label", name="heading", caption="Settings" }
		mainMenuSettings.heading.style.font = "default-large-bold"
	mainMenuSettings.add{ type="button", name="localToggleTrashButton", caption="Toggle Trash Button" }
	if player == game.players[1] then
		mainMenuSettings.add{ type="button", name="localToggleCheatMenu", caption="Toggle Cheat Menu" }
	end
end

function mainMenu.drawServerDefaults(player)
	
	if player.gui.left.leftFlow.mainMenuServerDefaults == nil then
		player.gui.left.leftFlow.add{ type="frame", name="mainMenuServerDefaults", direction="vertical" }
	else
		player.gui.left.leftFlow.mainMenuServerDefaults.clear()
	end
	local ServerDefaults = player.gui.left.leftFlow.mainMenuServerDefaults

	ServerDefaults.add{ type="label", name="heading", caption="Server Defaults" }
		ServerDefaults.heading.style.font = "default-large-bold"
	ServerDefaults.add{ type="button", name="serverDefaultsToggleTrashButton", caption="Toggle Trash Button" }
	ServerDefaults.add{ type="button", name="serverDefaultsToggleCheatModeAccess", caption="Toggle Cheat Mode Access" }
	ServerDefaults.add{ type="button", name="serverDefaultsToggleDeathMarkers", caption="Toggle Death Markers" }
end

return mainMenu