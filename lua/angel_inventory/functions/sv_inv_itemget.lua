local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.itemsStore = core.itemsStore or {
	/*
		[item_id] = {
			[inv_id], [owner], [in_store], [weight], [model], [name], [description], [data], [base_id]
		}
	*/
};

function core:inv_itemGet(item_id)
	return core.itemsStore[item_id] and core.itemsStore[item_id] or false;
end;

function core:inv_itemGetOwner(item_id)
	return core.itemsStore[item_id] and core.itemsStore[item_id].owner or false;
end;

function core:inv_itemGetInStore(item_id)
	return core.itemsStore[item_id] and core.itemsStore[item_id].in_store or false;
end;

function core:inv_itemGetWeight(item_id)
	return core.itemsStore[item_id] and core.itemsStore[item_id].weight or false;
end;

function core:inv_itemGetModel(item_id)
	return core.itemsStore[item_id] and core.itemsStore[item_id].model or false;
end;

function core:inv_itemGetName(item_id)
	return core.itemsStore[item_id] and core.itemsStore[item_id].name or false;
end;

function core:inv_itemGetDescription(item_id)
	return core.itemsStore[item_id] and core.itemsStore[item_id].description or false;
end;

function core:inv_itemCanUse(item_id)
	if (!self:inv_itemGet(item_id)) then return false; end;
	local base_id = self:inv_itemGetBaseID(item_id);
	local base = self:inv_itemGetBase(base_id);
	if (base_id == "spawned_weapon") then return true; end;
	if (base_id == "spawned_food") then return true; end;
	return base and base.canUse or false;
end;

function core:inv_itemCanDestroy(item_id)
	if (!self:inv_itemGet(item_id)) then return false; end;
	local base = core:inv_itemGetBase(self:inv_itemGetBaseID(item_id));
	
	return base and base.canDestroy or false;
end;

function core:inv_itemGetBaseID(item_id)
	return core.itemsStore[item_id] and core.itemsStore[item_id].base_id or false;
end;

function core:inv_itemGetAllByInv(inv_id)
	local items = {};
	for k, v in pairs(core.itemsStore) do
		if (v.inv_id != inv_id) then continue; end;
		if (v.in_store) then continue; end;
		items[k] = v;
	end;

	return items;
end;

function core:inv_itemGetAllByInvInStore(inv_id)
	local items = {};
	
	for k, v in pairs(core.itemsStore) do
		if (v.inv_id != inv_id) then continue; end;
		if (!v.in_store) then continue; end;
		items[k] = v;
	end;
	return items;
end; 

function core:inv_itemGetAllByInvSQL(entity)
	if (!entity or !entity:IsPlayer()) then return util.TableToJSON({}); end;
	local item_table = core:inv_itemGetAllByEntity(entity);
	local n_item_table = {};
	for k, v in pairs(item_table) do
		table.insert(n_item_table, {
			v.name,
			v.description,
			v.base_id,
			v.in_store,
			v.data,
			v.weight or false
		});
	end
	return util.TableToJSON(n_item_table);
end;

function core:inv_itemGetAllByEntity(entity)
	local items = {};
	for k, v in pairs(core.itemsStore) do
		if (v.owner != entity) then continue; end;
		items[k] = v;
	end;

	return items;
end;