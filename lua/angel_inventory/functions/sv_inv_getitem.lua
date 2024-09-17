local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.itemRegStore = core.itemRegStore or {};

function core:inv_getItem(unique_id)
	local item = core.itemRegStore[unique_id];	
	if (!unique_id) then return false; end;		
	if (item) then return item; end;			
	return false;								
end;
