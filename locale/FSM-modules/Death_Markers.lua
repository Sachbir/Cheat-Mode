-- Main Menu
-- This cheat panel is getting too big (and is drifting away from the "cheat panel" angle) so this is a menu to manage the components
-- Author: Sachbir Dhanota
-- Github: https://github.com/Sachbir
-- ============================================================= -- 

require("locale/FSM-core/util/GUI")

deathMarkers = {}

-- Functions to run just before a player entity dies
--	Create a marker on a player's location on the map
--	@param player 	luaPlayer that is about to die
function deathMarkers.on_pre_player_died(player)

	if global.Spaghetti.deathMarkers then
		local markerTag = {
			position = player.position,
			text = "15 mins | " .. player.name .. "'s grave",
			last_user = player
		}
		player.force.add_chart_tag(player.surface, markerTag)
	end
end

-- Functions to run every minute
-- 	Parses all map markers and updates grave marker with time remaining
function deathMarkers.on_3600th_tick() 

	mapMarkerList = game.players[1].force.find_chart_tags(1)
	for i=1,#mapMarkerList do
		local marker = mapMarkerList[i]
		if string.match(marker.text, "grave") then
			local time = string.match(marker.text, "%d+") - 1
			if time == -1 then
				marker.destroy()
			else
				marker.text = string.gsub(marker.text, "%d+", time, 1)
			end
		end
	end
end

return deathMarkers