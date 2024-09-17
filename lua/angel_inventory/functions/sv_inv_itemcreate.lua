local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.itemsStore = core.itemsStore or {};

function core:inv_itemCreate(data)
	local arr = {
		name = data.name or "unknown_item",
		description = data.description or "...",
		data = data.data or {},
		category = data.category or "",
		model = data.model or "",
		weight = data.weight or core.config["def_weight_unknown"],
		inv_id = data.inv_id or false,
		owner = data.owner or false,
		in_store = data.in_store or false,
		base_id = data.base_id or false
	};
	if (arr.owner == false) then _angel_sensei:Error("[AngelicInventory] Недопустимый предмет – объект-владелец!"); return false; end;
	if (arr.inv_id == false) then _angel_sensei:Error("[AngelicInventory] Неверный предмет – идентификатор инвентаря!"); return false; end;
	if (arr.base_id == false) then _angel_sensei:Error("[AngelicInventory] Базовый предмет недействителен!"); return false; end;

	return table.insert(core.itemsStore, arr);
end;