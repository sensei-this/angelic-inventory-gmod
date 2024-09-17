// Global vars
local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {}; 
local core = _angel_sensei.inventory;

core.externalItems = {"spawned_weapon", "spawned_shipment", "spawned_food", "spawned_ammo"};
core.actionDistance = 100; 

if (CLIENT) then
	core.storeSelfInventory = core.storeSelfInventory or {};
	core.storeSelfInventoryData = core.storeSelfInventoryData or {};
	core.storeSyncInventory = core.storeSyncInventory or {};
	core.syncInfo = core.syncInfo or {};

	CreateClientConVar("_angel_sensei_inventory_size", "S", true, false);
	CreateClientConVar("_angel_sensei_inventory_showCats", "1", true, false);
	CreateClientConVar("_angel_sensei_inventory_closeOnUse", "0", true, false);
	CreateClientConVar("_angel_sensei_inventory_itemsDouble", "1", true, false);
end;

/*---------------------------------------------------------------------------
Название файлов
---------------------------------------------------------------------------*/

core:folder_include("libs");
core:sh_include(_, "config.lua");
core:folder_include("functions");
core:folder_include("derma");
core:folder_include("hooks");

if (core.config["save_type"] == "sv.db") then
	core:sv_include("db_modules", "sv_db.lua");
else
	core:sv_include("db_modules", "mysqloo.lua");
end

/*---------------------------------------------------------------------------
Список предметов
---------------------------------------------------------------------------*/
if (SERVER) then AddCSLuaFile("angel_inventory_entities.lua"); end;
include("angel_inventory_entities.lua");