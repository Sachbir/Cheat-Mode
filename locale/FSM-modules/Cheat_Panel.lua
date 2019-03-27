-- Cheat Panel
-- Adds a sidepanel for a better cheat mode experience
-- Author: Sachbir Dhanota
-- Github: https://github.com/Sachbir
-- ============================================================= -- 

require("locale/FSM-core/util/GUI")

global.Cheat_Mode_Check = ""
global.Global_Cheat_Mode_Check = "false"
global.All_Research_Unlocked = ""
global.Auto_Trash = {}
global.Auto_Logistics_Fill = {}

-- Functions to run every N ticks
--  This is run within "events.on_nth_tick" in "control.lua"
function Cheat_Panel_On_60th_Tick()
    for i,players in ipairs(game.connected_players) do
        -- Clear trash slots
        if global.Auto_Trash[players.name] == "Yes" then
            players.get_inventory(defines.inventory.player_trash).clear()
        end
        -- Fill logistics requests
		if global.Auto_Logistics_Fill[players.name] == "Yes" then
			if players.character then
				for i=1,(players.character.request_slot_count) do
					local item = players.character.get_request_slot(i)
					if item then
						local item_difference = item.count - players.get_item_count(item.name)
						if item_difference > 0 then
							players.insert{name=item.name, count=item_difference}
						end
					end
				end
			end
        end
    end
end

-- Functions to run when a player first enters a game
--  For player 1, do cheat mode initialization (if we haven't already)
--  Enable the cheat panel for all players for whom it is permissible
--  This is run within "events.on_player_joined_game" in "control.lua"
--  @param event    luaEvent for "events.on_gui_click"
function Cheat_Panel_On_Player_Joined_Game(event)
    -- global.reload() 
    local player = game.players[event.player_index]
    if global.Cheat_Mode_Check == "" then
        if event.player_index == 1 then
            cheat_mode_initiation(player)
        end
    elseif global.Cheat_Mode_Check == "enable" then
        if event.player_index == 1 then
            draw_cheat_button(player)
            draw_cheat_panel(player)
        elseif global.Global_Cheat_Mode_Check == "true" then
            draw_cheat_button(player)
            draw_cheat_panel(player)
        end
    end
    if player.gui.left.leftFlow == nil then
		player.gui.left.add{ type="flow", name="leftFlow", direction="horizontal" }
	end
end

-- Functions to run when a player exit the game
--  Destroys all extant gui elements
--  This is run within "events.on_player_left_game" in "control.lua"
--  @param event    luaEvent for "events.on_gui_click"
function Cheat_Panel_On_Player_Left_Game(event)
    local player = game.players[event.player_index]
    if player.gui.top["cheat_button"] ~= nil then
        player.gui.top["cheat_button"].destroy()
    end
    if player.gui.left.leftFlow ~= nil then
        player.gui.left.leftFlow.destroy()
    end 
    if player.gui.center["cheat_mode_initiation"] ~= nil then
        player.gui.center["cheat_mode_initiation"].destroy()
    end 
end

-- Functions to run when a gui element is clicked
--  This is run within "events.on_gui_click" in "control.lua"
--  @param event    luaEvent for "events.on_gui_click"
function Cheat_Panel_On_Gui_Click(event)
    local player = game.players[event.player_index]
    if     event.element.name == "enable-cheat-mode" then
        global.Cheat_Mode_Check = "enable"
        player.gui.center.cheat_mode_initiation.destroy()
        draw_cheat_button(player)
        -- draw_cheat_panel(player)
    elseif event.element.name == "disable-cheat-mode" then
        global.Cheat_Mode_Check = "disable"
        player.gui.center.cheat_mode_initiation.destroy()
    elseif event.element.name == "global_cheat_mode_toggle" then
        if event.element.caption == "False" then
            global.Global_Cheat_Mode_Check = "true"
            for i,players in ipairs(game.connected_players) do
                draw_cheat_button(players)
                draw_cheat_panel(players)
            end
            game.print("Access to cheat mode has been enabled for all")
        else
            global.Global_Cheat_Mode_Check = "false"
            for i,players in ipairs(game.connected_players) do
                if i ~= 1 then
                    if players.gui.top["cheat_button"] ~= nil then
                        players.gui.top["cheat_button"].destroy()
                    end
                    if players.gui.left.leftFlow["cheat_frame"] ~= nil then
                        players.gui.left.leftFlow["cheat_frame"].destroy()
                    end
                    players.cheat_mode=false
                end
            end
            draw_cheat_panel(player)
            game.print("Access to cheat mode has been disabled for all")
            player.print("(Except you, Player 1)")
        end
    elseif event.element.name == "cheat_mode_toggle" then
        if event.element.caption == "False" then
            player.cheat_mode=true
            event.element.caption = "True"
            player.print("Cheat mode has been enabled")
        else
            player.cheat_mode=false
            event.element.caption = "False"
            player.print("Cheat mode has been disabled")
        end
    elseif event.element.name == "research_toggle" then
        if player.gui.left.leftFlow.cheat_frame.table_one.research_header.caption == "Unlock all research?" then
            player.force.research_all_technologies()
            player.force.enable_all_recipes()
            global.All_Research_Unlocked = "true"
            draw_cheat_panel_for_1_or_all(player)
            game.print("All research has been unlocked")
        else
            for _, tech in pairs(player.force.technologies) do 
                tech.researched=false
                player.force.set_saved_technology_progress(tech, 0)
            end
            player.force.reset_technology_effects()
            global.All_Research_Unlocked = "false"
            draw_cheat_panel_for_1_or_all(player)
            game.print("All research has been reset")
        end
    elseif event.element.name == "daytime_toggle" then
        if event.element.caption == "False" then
            player.surface.always_day=true
            draw_cheat_panel_for_1_or_all(player)
            game.print("Eternal Daytime Enabled")
        else
            player.surface.always_day=false
            draw_cheat_panel_for_1_or_all(player)
            game.print("Eternal Daytime Disabled")
        end
    elseif event.element.name == "infinity-chest" then
        player.insert{name=event.element.name, count=10}
    elseif event.element.name == "electric-energy-interface" then
        player.insert{name=event.element.name, count=50}
    elseif event.element.name == "loader" then
        player.insert{name=event.element.name, count=50}
    elseif event.element.name == "fast-loader" then
        player.insert{name=event.element.name, count=50}
    elseif event.element.name == "express-loader" then
        player.insert{name=event.element.name, count=50}
    elseif event.element.name == "gear-up" then
        player.insert{name="power-armor-mk2", count=1}
        local p_armor = player.get_inventory(5)[1].grid
        p_armor.put({name="fusion-reactor-equipment"})
        p_armor.put({name="fusion-reactor-equipment"})
        p_armor.put({name="fusion-reactor-equipment"})
        p_armor.put({name="personal-roboport-mk2-equipment"})
        p_armor.put({name="personal-roboport-mk2-equipment"})
        p_armor.put({name="personal-roboport-mk2-equipment"})
        p_armor.put({name="personal-roboport-mk2-equipment"})
        p_armor.put({name="personal-roboport-mk2-equipment"})
        p_armor.put({name="personal-roboport-mk2-equipment"})
        p_armor.put({name="personal-roboport-mk2-equipment"})
        p_armor.put({name="personal-roboport-mk2-equipment"})
        p_armor.put({name="energy-shield-mk2-equipment"})
        p_armor.put({name="energy-shield-mk2-equipment"})
        p_armor.put({name="energy-shield-mk2-equipment"})
        p_armor.put({name="energy-shield-mk2-equipment"})
        p_armor.put({name="night-vision-equipment"})
        player.insert{name="construction-robot", count=100}
	elseif event.element.name == "robot-speed-level-99" then
		player.force.technologies['worker-robots-speed-6'].level = 99
		player.print("Worker robot speed set to lvl 99")
	elseif event.element.name == "crafting-speed-ok" then
        apply_modifier(player, "crafting-speed-input", "character_crafting_speed_modifier")
    elseif event.element.name == "mining-speed-ok" then
        apply_modifier(player, "mining-speed-input", "character_mining_speed_modifier")
    elseif event.element.name == "running-speed-ok" then
        apply_modifier(player, "running-speed-input", "character_running_speed_modifier")
    elseif event.element.name == "build-reach-ok" then
        apply_modifier(player, "build-reach-input", "character_build_distance_bonus")
    elseif event.element.name == "entity-reach-ok" then
        apply_modifier(player, "entity-reach-input", "character_reach_distance_bonus")
    elseif event.element.name == "resource-reach-ok" then
        apply_modifier(player, "resource-reach-input", "character_resource_reach_distance_bonus")
    elseif event.element.name == "auto-fill-yes" then
		global.Auto_Logistics_Fill[player.name] = "Yes"
		player.print("Auto-fill has been set to true")
    elseif event.element.name == "auto-fill-no" then
		global.Auto_Logistics_Fill[player.name] = "No"
		player.print("Auto-fill has been set to false")
    elseif event.element.name == "auto-delete-yes" then
		global.Auto_Trash[player.name] = "Yes"
		player.print("Auto-trash has been set to true")
    elseif event.element.name == "auto-delete-no" then
		global.Auto_Trash[player.name] = "No"
		player.print("Auto-trash has been set to false")
    elseif event.element.name == "peaceful-mode-yes" then
        player.surface.peaceful_mode = true
    elseif event.element.name == "peaceful-mode-no" then
        player.surface.peaceful_mode = false
	elseif event.element.name == "cheat_button" then
		if player.gui.left.leftFlow == nil then
			player.gui.left.add{ type="flow", name="leftFlow", direction="horizontal" }
		end
		if player.gui.left.leftFlow.cheat_frame then
			player.gui.left.leftFlow.clear()
		else
			player.gui.left.leftFlow.clear()
			draw_cheat_panel(player)
		end
    elseif event.element.name == "cheat_panel_2_button" then
        if player.gui.left.leftFlow.cheat_frame_2 then
            GUI.toggle_element(player.gui.left.leftFlow.cheat_frame_2)
        else
            draw_cheat_panel_2(player)
        end
    elseif event.element.name == "cheat_panel_3_button" then
        if player.gui.left.leftFlow.cheat_frame_3 then
            GUI.toggle_element(player.gui.left.leftFlow.cheat_frame_3)
        else
            draw_cheat_panel_3(player)
        end
    elseif event.element.name == "complete-current-research" then
        if player.force.current_research then
            player.force.current_research.researched = true
		end
    end
end

-- If initialization has not occurred, this checks whether Player 1 wants cheat mode enabled for the save
-- @param player    luaPlayer of Player 1, the only player who should see the initiation window
function cheat_mode_initiation(player)
    player.gui.center.add{ type="frame", name="cheat_mode_initiation", direction="vertical" }
    player.gui.center.cheat_mode_initiation.add{ type="label", caption="Enable Cheat Mode?" }
    player.gui.center.cheat_mode_initiation.add{ type="table", name="table", column_count=2 }
    player.gui.center.cheat_mode_initiation.table.add{ type="button", name="enable-cheat-mode", caption="Yes" }
    player.gui.center.cheat_mode_initiation.table.add{ type="button", name="disable-cheat-mode", caption="No" }
end

-- Creates a gui button to toggle the presence of the Cheat Panel
-- @param player    luaPlayer for whom button is drawn
function draw_cheat_button(player)
    if player.gui.top.cheat_button == nil then
        player.gui.top.add{ type="button", name="cheat_button", caption="Cheat Panel" }
    end
end

-- Creates the Cheat Panel
-- @param player    luaPlayer for whom panel is drawn
function draw_cheat_panel(player)
    if player.gui.left.leftFlow.cheat_frame == nil then
        player.gui.left.leftFlow.add{ type="frame", name="cheat_frame", caption="Cheat Commands", direction="vertical" }
    else
        player.gui.left.leftFlow.cheat_frame.clear()
    end
    cheat_frame = player.gui.left.leftFlow.cheat_frame
	cheat_frame.add{ type="table", name="table_one", column_count=2 }
    if player == game.players[1] then
        cheat_frame.table_one.add{ type="label", caption="Enable cheats for all?" }
        if global.Global_Cheat_Mode_Check == "true" then
            cheat_frame.table_one.add{ type="button", name="global_cheat_mode_toggle", caption="True" }
        else
            cheat_frame.table_one.add{ type="button", name="global_cheat_mode_toggle", caption="False" }
        end
    end
    cheat_frame.table_one.add{ type="label", caption="Toggle cheat mode?" }
    if player.cheat_mode == false then
        cheat_frame.table_one.add{ type="button", name="cheat_mode_toggle", caption="False" }
    else
        cheat_frame.table_one.add{ type="button", name="cheat_mode_toggle", caption="True" }
    end
    if global.All_Research_Unlocked == "true" then
        cheat_frame.table_one.add{ type="label", name="research_header", caption="Reset research?" }
    else
        cheat_frame.table_one.add{ type="label", name="research_header", caption="Unlock all research?" }
    end
    cheat_frame.table_one.add{ type="button", name="research_toggle", caption="Yes" }
    cheat_frame.table_one.add{ type="label", caption="Eternal daytime?" }
    if player.surface.always_day == false then
        cheat_frame.table_one.add{ type="button", name="daytime_toggle", caption="False" }
    else
        cheat_frame.table_one.add{ type="button", name="daytime_toggle", caption="True" }
    end
    cheat_frame.add{ type="label", name="header2", caption="Special Items" }
        cheat_frame.header2.style.font = "default-large-bold"
	cheat_frame.add{ type="table", name="table_two", column_count=5 }
    cheat_frame.table_two.add{ type="sprite-button", name="infinity-chest", sprite="item/infinity-chest" }
    cheat_frame.table_two["infinity-chest"].tooltip = "Infinity Chest\nUsed to spawn or destroy items"
    cheat_frame.table_two.add{ type="sprite-button", name="electric-energy-interface", sprite="item/electric-energy-interface" }
    cheat_frame.table_two["electric-energy-interface"].tooltip = "Electric Energy Interface\nA configurable energy producer/consumer/storage"
    cheat_frame.table_two.add{ type="sprite-button", name="loader", sprite="item/loader" }
    cheat_frame.table_two["loader"].tooltip = "Loader\nTransfers items between a belt and a chest at the speed of a yellow belt"
    cheat_frame.table_two.add{ type="sprite-button", name="fast-loader", sprite="item/fast-loader" }
    cheat_frame.table_two["fast-loader"].tooltip = "Fast Loader\nTransfers items between a belt and a chest at the speed of a red belt"
    cheat_frame.table_two.add{ type="sprite-button", name="express-loader", sprite="item/express-loader" }
    cheat_frame.table_two["express-loader"].tooltip = "Express Loader\nTransfers items between a belt and a chest at the speed of a blue belt"
    cheat_frame.add{ type="button", name="cheat_panel_2_button", caption="More" }
	-- cheat_frame.add{ type="button", name="cheat_panel_3_button", caption="Even More (test)" }
end

-- Creates an additional cheat panel with more buttons
-- @param player    luaPlayer for whom panel is drawn
function draw_cheat_panel_2(player)
    if player.gui.left.leftFlow.cheat_frame_2 == nil then
        player.gui.left.leftFlow.add{ type="frame", name="cheat_frame_2", caption="Additional Options", direction="vertical" }
    else
        player.gui.left.leftFlow.cheat_frame_2.clear()
    end
    frame = player.gui.left.leftFlow.cheat_frame_2
    frame.add{ type="table", name="table", column_count=3 }
	frame.table.add{ type="label", caption="Crafting Speed" }
		frame.table.style.vertical_spacing = 2
		frame.table.style.horizontal_spacing = 2
        frame.table.add{ type="textfield", name="crafting-speed-input", text=player.character_crafting_speed_modifier }
		frame.table.add{ type="button", name="crafting-speed-ok", caption="OK" }
    frame.table.add{ type="label", caption="Mining Speed" }
        frame.table.add{ type="textfield", name="mining-speed-input", text=player.character_mining_speed_modifier }
		frame.table.add{ type="button", name="mining-speed-ok", caption="OK" }
    frame.table.add{ type="label", caption="Running Speed" }
        frame.table.add{ type="textfield", name="running-speed-input", text=player.character_running_speed_modifier }
		frame.table.add{ type="button", name="running-speed-ok", caption="OK" }
    frame.table.add{ type="label", caption="Build Distance" }
        frame.table.add{ type="textfield", name="build-reach-input", text=player.character_build_distance_bonus }
        frame.table.add{ type="button", name="build-reach-ok", caption="OK" }
    frame.table.add{ type="label", caption="Entity Reach" }
        frame.table.add{ type="textfield", name="entity-reach-input", text=player.character_reach_distance_bonus }
        frame.table.add{ type="button", name="entity-reach-ok", caption="OK" }
    frame.table.add{ type="label", caption="Resource Reach" }
        frame.table.add{ type="textfield", name="resource-reach-input", text=player.character_resource_reach_distance_bonus }
        frame.table.add{ type="button", name="resource-reach-ok", caption="OK" }
    frame.table.add{ type="label", caption="Auto-fill Requests?" }
        frame.table.add{ type="button", name="auto-fill-yes", caption="Yes" }
        frame.table.add{ type="button", name="auto-fill-no", caption="No" }
    frame.table.add{ type="label", caption="Auto-delete Trash?" }
        frame.table.add{ type="button", name="auto-delete-yes", caption="Yes" }
        frame.table.add{ type="button", name="auto-delete-no", caption="No" }
    frame.table.add{ type="label", caption="Gear up" }
		frame.table.add{ type="sprite-button", name="gear-up", sprite="item/power-armor-mk2" }
		frame.table.add{ type="label", caption="" }
	frame.table.add{ type="label", caption="Robot Speed lvl 99" }
		frame.table.add{ type="sprite-button", name="robot-speed-level-99", sprite="item/logistic-robot" }
		frame.table.add{ type="label", caption="" }
	frame.add{ type="button", name="complete-current-research", caption="Complete Current Research" }
	
	-- Apply styles to elements
	for i,v in ipairs(frame.table.children) do
		if (type ~= "table") then
			style = v.style
			style.height = 30
			style.font = "default-small-semibold"
			style.vertical_align = "center"
			if (v.type == "label") then
				style.font = "default"
				style.right_padding = 5
			end
			if (v.type == "textfield" or v.caption == "Yes") then
				style.width = 43
			end
		end
	end
end

function draw_cheat_panel_3(player)
    if player.gui.left.leftFlow.cheat_frame_3 == nil then
        player.gui.left.leftFlow.add{ type="frame", name="cheat_frame_3", caption="Biter Commands", direction="vertical" }
    else
        player.gui.left.leftFlow.cheat_frame_3.clear()
    end
    cheat_frame_3 = player.gui.left.leftFlow.cheat_frame_3
    cheat_frame_3.add{ type="table", name="table", column_count=3 }
    cheat_frame_3.table.add{ type="label", caption="Enable Peaceful Mode?" }
    cheat_frame_3.table.add{ type="button", name="peaceful-mode-yes", caption="Yes" }
    cheat_frame_3.table.add{ type="button", name="peaceful-mode-no", caption="No" }
end

-- Draws the cheat panel for all connected players
function draw_cheat_panel_for_all()
    for i,players in ipairs(game.connected_players) do
        draw_cheat_panel(players)
    end
end

-- Decides if the cheat panel should be drawn for all players, or just player 1
-- @param player    luaPlayer that pressed the button that triggered this function
function draw_cheat_panel_for_1_or_all(player)
    if global.Global_Cheat_Mode_Check == "true" then
        draw_cheat_panel_for_all()
    else
        draw_cheat_panel(player)
    end 
end 

-- Modifies character modifiers based on an input value
-- @param player        luaPlayer for whom the modifer is applied
-- @param element_name  luaGuiElement from which new modifer value is to be extracted
-- @param modifer_name  luaControl to identify the modifier to be acted on
function apply_modifier(player, element_name, modifier_name)
    local input_value = tonumber(player.gui.left.leftFlow.cheat_frame_2.table[element_name].text)
    if input_value then
        if input_value < 0 then
            player[modifier_name] = 0
        else
            player[modifier_name] = input_value
        end
    end
    draw_cheat_panel_2(player)
end