-- Trash Button
-- Adds a button to delete items
-- Author: Sachbir Dhanota
-- Github: https://github.com/Sachbir
-- ============================================================= -- 

trashButton = {}

function trashButton.on_player_joined_game(player)
	
	trashButton.drawButton(player)
end

function trashButton.on_player_left_game(player)
	
	if player.gui.top.trashButton then
		player.gui.top.trashButton.destroy()
	end
end

function trashButton.on_gui_click(event)

	if event.element.name == "trashButton" then
		game.players[event.player_index].cursor_stack.clear()
	end
end

function trashButton.drawButton(player)
	
	if player.gui.top.trashButton == nil then
		player.gui.top.add{ type="button", name="trashButton", caption="Trash" }
	end
end

return trashButton