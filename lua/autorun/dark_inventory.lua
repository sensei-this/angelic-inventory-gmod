_angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
_angel_sensei.inventory.dir = "angel_inventory";

_angel_sensei.inventory.itemRegStore = {};
_angel_sensei.inventory.itemsStore = _angel_sensei.inventory.itemsStore or {};


function _angel_sensei:Error(msg)
	MsgC("[AngelicInventory] ", Color(255, 0, 0), " // Ошибка ", Color(255,255,255), msg, "\n");
end;
function _angel_sensei:Notify(msg)
	MsgC("[AngelicInventory] ", Color(0, 255, 255), " // Проверка ", Color(255,255,255), msg, "\n");
end;
function _angel_sensei:Alert(msg)
	MsgC("[AngelicInventory] ", Color(255, 0, 255), " // Проблема ", Color(255,255,255), msg, "\n");
end;

if (SERVER) then
	resource.AddWorkshop("3220426705");
	AddCSLuaFile(_angel_sensei.inventory.dir.."/include.lua");
	AddCSLuaFile(_angel_sensei.inventory.dir.."/init.lua");
end
include(_angel_sensei.inventory.dir.."/include.lua");
include(_angel_sensei.inventory.dir.."/init.lua");