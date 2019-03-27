-- Unsorted Functions
-- A collection of functions that don't go anywhere else
-- Author: Sachbir Dhanota
-- Github: https://github.com/Sachbir
-- ============================================================= -- 

-- Flips a variables value between true and fale
-- 	@param variable		The variable to be flipped
function ifTrueThenFalseElseTrue(variable)

	local tempBoolean
	if variable == true then
		tempBoolean = false
	else
		tempBoolean = true
	end
	return tempBoolean
end

-- Reloads global variables 
--  Taken from this suggestion: https://www.reddit.com/r/factorio/comments/7qc8sy/creative_mode_without_mod/dstveh3/?context=3&st=jcjl14oa&sh=68bbdeda
--  Seems to prevent multiplayer desyncing issues
function reloadGlobalTable() 
    for k,v in next,global do 
        _G[k]=v 
    end 
end