-- GUI
-- Adds commands for GUI 
-- Author: Sachbir Dhanota
-- Github: https://github.com/Sachbir
-- Heavily inspired (stolen) from: 
-- Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ============================================================= -- 

GUI = {}

-- Toggle element visibility
--	@element		Element whose visibility to toggle
-- 	@subElement1	(optional) Element to hide
-- 	@subElement2	(optional) Element to hide
-- 	@subElement3	(optional) Element to hide
function GUI.toggle_element(element, subElement1, subElement2, subElement3)
	
	subElement1 = subElement1 or nil
	subElement2 = subElement2 or nil

	if element ~= nil then
		if element.style.visible == false then
			element.style.visible = true
		else
			element.style.visible = false
		end
	end
	GUI.hide_element(subElement1)
	GUI.hide_element(subElement2)
	GUI.hide_element(subElement3)
end

function GUI.hide_element(element)

	element = element or nil

	if element ~= nil then
		element.style.visible = false
	end
end

return GUI