local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.itemRegStore = core.itemRegStore or {};

function core:inv_regItem(unique_id, data)
	if (!unique_id or !data or !istable(data)) then
		_angel_sensei:Error("[AngelicInventory] Неизвестный предмет - невозможно зарегистрировать. Неверный вызов inv_regItem");
		return false;
	end;
	if (core.itemRegStore[unique_id]) then _angel_sensei:Alert("[AngelicInventory] Предмет "..unique_id.." уже зарегистрирован!"); end;

	if (data.canUse == nil) then data.canUse = true; end;
	if (data.canDestroy == nil) then data.canDestroy = true; end;

	core.itemRegStore[unique_id] = {
		name = data.name or unique_id,
		description = data.description or "...",
		category = data.category or "Other",
		model = data.model or "models/error.mdl",
		weight = data.weight or core.config["def_weight_unknown"],
		initCallback = data.initCallback or function(ent) end,
		saveCallback = data.saveCallback or function(ent) return {} end,
		saveCustomcheck = data.saveCustomcheck or function(ply, ent) return true; end,
		canUse = data.canUse,
		canDestroy = data.canDestroy,
	};

	return true;
end;

function core:inv_itemIsRegistred(class)
	if (!self.itemRegStore[class]) then return false; end;
	return true;
end;
function core:inv_itemGetBase(class)
	if (!self.itemRegStore[class]) then return false; end;
	return self.itemRegStore[class];
end; 