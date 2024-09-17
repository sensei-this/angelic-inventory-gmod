local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;

if (core.config["save_type"] != "mysqloo") then return false; end;
local empty_func = function() end;
require("mysqloo");

function core:inv_sql_createConnection()
	return mysqloo.connect(self.config["mysql_host"], self.config["mysql_user"], self.config["mysql_password"], self.config["mysql_database"], self.config["mysql_port"]);
end;

function core:inv_sql_init(callback)
	callback = (callback and isfunction(callback)) and callback or empty_func;

	local db = self:inv_sql_createConnection();

	function db:onConnected()	// 76561199076211461
		local q = self:query([[CREATE TABLE IF NOT EXISTS `angel_inventories` (
								`id` INT(11) NOT NULL AUTO_INCREMENT,
								`steamid` TEXT,
								`items` LONGTEXT,
								PRIMARY KEY (`id`)
							);
							]]);

		function q:onSuccess(data)
			callback();
		end;
		function q:onError(err, sql)
			print("Error:", err);
		end;

		q:start();
	end;

	function db:onConnectionFailed(err)
		_angel_sensei:Error("[AngelicInventory] [MySQL] Connection to database failed!");
		print("Error:", err);
	end;

	db:connect();
end;

function core:inv_sql_dropTable()	// Console: lua_run _angel_sensei.inventory:inv_sql_dropTable();
	local db = self:inv_sql_createConnection();

	function db:onConnected()
		local q = self:query([[DELETE FROM `angel_inventories`]]);

		function q:onSuccess(data)
			_angel_sensei:Alert("[AngelicInventory] [MySQL] Database cleared...");
		end;
		function q:onError(err, sql)
			print("Error:", err);
		end;

		q:start();
	end;

	function db:onConnectionFailed(err)
		_angel_sensei:Error("[AngelicInventory] [MySQL] Connection to database failed!");
		print("Error:", err);
	end;

	db:connect();
end;

function core:inv_sql_create(ply, callback)
	callback = (callback and isfunction(callback)) and callback or empty_func;
	local steamid = ply:SteamID64();

	local query_string = [[INSERT INTO `angel_inventories` (`steamid`, `items`) VALUES (
			]]..sql.SQLStr(steamid)..[[,
			]]..sql.SQLStr(util.TableToJSON({}))..[[
		);]];

	local db = self:inv_sql_createConnection();
	function db:onConnected()
		local q = self:query(query_string);

		function q:onSuccess(data)
			_angel_sensei:Notify("[AngelicInventory] New empty inventory for "..ply:Name().." ("..steamid..") was created!");
			
			callback();
		end;
		function q:onError(err, sql)
			print("Error:", err);
		end;

		q:start();
	end;

	function db:onConnectionFailed(err)
		_angel_sensei:Error("[AngelicInventory] [MySQL] Connection to database failed!");
		print("Error:", err);
	end;
	db:connect();

	return true;
end;

function core:inv_sql_load(ply, callback)
	callback = (callback and isfunction(callback)) and callback or empty_func;
	local steamid = ply:SteamID64();

	local db = self:inv_sql_createConnection();

	function db:onConnected()
		local q = self:query([[SELECT * FROM `angel_inventories` WHERE `steamid` = ']]..steamid..[[' LIMIT 1;]]);

		function q:onSuccess(data)
			if (#data == 0) then
				callback(false);
				return;
			end;
			callback(data[1]);
			_angel_sensei:Notify("[AngelicInventory] Loaded for "..ply:Name().." ("..steamid..")");
		end;

		function q:onError(err, sql)
			print("Error:", err);
		end;

		q:start();
	end;

	function db:onConnectionFailed(err)
		_angel_sensei:Error("[AngelicInventory] [MySQL] Connection to database failed!");
		print("Error:", err);
	end;

	db:connect();

	return true;
end;

function core:inv_sql_find(ply, callback)
	if (!ply or !ply:IsPlayer()) then return false; end;
	callback = (callback and isfunction(callback)) and callback or empty_func;
	local steamid = ply:SteamID64();

	local db = self:inv_sql_createConnection();

	function db:onConnected()
		local q = self:query([[SELECT * FROM `angel_inventories` WHERE `steamid` = ']]..steamid..[[' LIMIT 1;]]);

		function q:onSuccess(data)
			if (#data == 0) then
				_angel_sensei:Alert("[AngelicInventory] [MySQL] Inventory for "..ply:Name().." ("..steamid..") doesn't exists!");
				callback(false);
				return;
			end;
			_angel_sensei:Notify("[AngelicInventory] [MySQL] Character finded in database");
			callback(true);
		end;

		function q:onError(err, sql)
			print("Error:", err);
		end;

		q:start();
	end;

	function db:onConnectionFailed(err)
		_angel_sensei:Error("[AngelicInventory] [MySQL] Connection to database failed!");
		print("Error:", err);
	end;

	db:connect();

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

function core:inv_sql_save(ply, callback)
	callback = (callback and isfunction(callback)) and callback or empty_func;
	local steamid = ply:SteamID64();

	local query_string = [[UPDATE `angel_inventories` SET `items` = ]]..sql.SQLStr(core:inv_itemGetAllByInvSQL(ply))..[[ WHERE `steamid` = "]]..steamid..[["]];

	local db = self:inv_sql_createConnection();
	function db:onConnected()
		local q = self:query(query_string);

		function q:onSuccess(data)
			callback();
		end;
		function q:onError(err, sql)
			print("Error:", err);
		end;

		q:start();
	end;

	function db:onConnectionFailed(err)
		_angel_sensei:Error("[AngelicInventory] [MySQL] Connection to database failed!");
		print("Error:", err);
	end;
	db:connect();

	return true;
end;