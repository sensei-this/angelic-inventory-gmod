local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;

if (core.config["save_type"] != "sv.db") then return false; end;
local empty_func = function() end;

function core:inv_sql_init(callback)
	callback = (callback and isfunction(callback)) and callback or empty_func;

	sql.Query([[CREATE TABLE IF NOT EXISTS `angel_inventories` (
					`id` INTEGER PRIMARY KEY,
					`steamid` TEXT,
					`items` TEXT
				);]]);
	callback();
end;

function core:inv_sql_dropTable()	// Console: lua_run _angel_sensei.inventory:inv_sql_dropTable();
	sql.Query([[DELETE FROM `angel_inventories`]]);
	_angel_sensei:Alert("[AngelicInventory] [MySQL] Database cleared...");
end;

function core:inv_sql_create(ply, callback)
	callback = (callback and isfunction(callback)) and callback or empty_func;
	local steamid = ply:SteamID64();

	local query_string = [[INSERT INTO `angel_inventories` (`steamid`, `items`) VALUES (
			]]..sql.SQLStr(steamid)..[[,
			]]..sql.SQLStr(util.TableToJSON({}))..[[
		);]];

	sql.Query(query_string);
	callback();

	return true;
end;

function core:inv_sql_load(ply, callback)
	callback = (callback and isfunction(callback)) and callback or empty_func;
	local steamid = ply:SteamID64();

	local query = sql.Query([[SELECT * FROM `angel_inventories` WHERE `steamid` = ']]..steamid..[[' LIMIT 1;]]);
	if (!istable(query) or #query < 1) then	
		callback(false);
		return;
	end
	callback(query[1]);
	_angel_sensei:Notify("[AngelicInventory] Loaded for "..ply:Name().." ("..steamid..")");

	return true;
end;

function core:inv_sql_find(ply, callback)
	if (!ply or !ply:IsPlayer()) then return false; end;
	callback = (callback and isfunction(callback)) and callback or empty_func;
	local steamid = ply:SteamID64();

	local query = sql.Query([[SELECT * FROM `angel_inventories` WHERE `steamid` = ']]..steamid..[[' LIMIT 1;]]);

	if (!istable(query) or #query < 1) then	callback(false); return; end;
	callback(true);
	return true;
end;

function core:inv_sql_unload(inv_id, callback)
	callback = (callback and isfunction(callback)) and callback or empty_func;
	local field = !IsEntity(inv_id) and "inv_id" or "owner";

	for k, v in pairs(core.itemsStore) do
		if (v[field] != inv_id) then continue; end;
		core.itemsStore[k] = nil;	// Remove item from inventory
	end;

	for k,v in pairs(core.inventoriesStore) do
		if (field == "inv_id" and k == inv_id) then
			core.inventoriesStore[k] = nil;
		elseif (field == "owner" and v.owner == inv_id) then
			core.inventoriesStore[k] = nil;
		end;
	end;
	
	callback();

	return true;
end;

function core:inv_sql_save(ply, callback) // 76561199076211461
	callback = (callback and isfunction(callback)) and callback or empty_func;
	local steamid = ply:SteamID64();

	local query_string = [[UPDATE `angel_inventories` SET `items` = ]]..sql.SQLStr(core:inv_itemGetAllByInvSQL(ply))..[[ WHERE `steamid` = "]]..steamid..[["]];

	sql.Query(query_string);
	callback();

	return true;
end;