local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;

core.inventoriesStore = core.inventoriesStore or {
	/*
		[inv_id] = {weight_max, owner}
	*/
};

function core:inv_invCreate(entity, weight)
	if (!entity or !IsValid(entity)) then return false; end;
	if (entity._angel_sensei_invID) then return false; end;
	weight = weight or core.config["default_weight"];

	local id = table.insert(core.inventoriesStore, {
		weight_max = weight,
		owner = entity
	})
	entity._angel_sensei_invID = id;
	return id;
end;

function core:inv_invExists(inv_id)
	if (!inv_id) then return; end;
	if (IsEntity(inv_id)) then 
		if (!core.inventoriesStore[inv_id._angel_sensei_invID]) then return false; end;
		return true;
	end;
	if (!core.inventoriesStore[inv_id]) then return false; end;
	return true;
end;

function core:inv_invGetID(entity)
	if (!entity) then return; end;
	if (!IsEntity(entity) or !IsValid(entity)) then return false; end;
	if (!core.inventoriesStore[entity._angel_sensei_invID]) then return false; end;
	return entity._angel_sensei_invID;
end;

function core:inv_invSendClientSide(entity)	-- Обновление клиентского инвенторя, если появился новый предмет или что-то забрали
	if (!entity or !IsValid(entity) or !entity:IsPlayer()) then return false; end;
	local inv_id = core:inv_invGetID(entity);

	netstream.Start(entity, "_angel_sensei.inventory.syncData", {"self", core.inventoriesStore[inv_id]});

	local items = core:inv_itemGetAllByInv(inv_id);
	netstream.Start(entity, "_angel_sensei.inventory.syncInventory", items);

	return true;
end;

function core:inv_invIsBusy(inv_id)
	if (!inv_id) then return false; end;
	if (!self:inv_invExists(inv_id)) then return false; end;
	local inv_meta = core.inventoriesStore[inv_id];
	inv_meta._busy = inv_meta._busy or false;
	inv_meta._busy_ent = inv_meta._busy_ent or nil;
	inv_meta._busy_ent_pos = inv_meta._busy_ent_pos or nil;

	if (inv_meta._busy) then
		if (inv_meta._busy_ent and IsValid(inv_meta._busy_ent) and inv_meta._busy_ent:IsPlayer() and inv_meta._busy_ent:Alive() and inv_meta._busy_ent:GetPos():Distance(inv_meta._busy_ent_pos) < core.actionDistance/2 and inv_meta._busy_ent:GetPos():Distance(inv_meta.owner:GetPos()) <= core.actionDistance) then
			return true;
		else
			inv_meta._busy = false;
			inv_meta._busy_ent = nil;
			inv_meta._busy_ent_pos = nil;
		end;
	end;
	return false;
end;

function core:inv_invSetBusy(inv_id, entity)
	if (!inv_id) then return; end;
	if (!self:inv_invExists(inv_id)) then return; end;

	local inv_meta = core.inventoriesStore[inv_id];
	if (!entity or !IsValid(entity) or !entity:IsPlayer() or !entity:Alive() or entity:GetPos():Distance(inv_meta.owner:GetPos()) > core.actionDistance) then return false; end;

	inv_meta._busy = true;
	inv_meta._busy_ent = entity;
	inv_meta._busy_ent_pos = entity:GetPos();

	return true;
end;

function core:inv_invSync(caller, entity_store)
	if (!caller or !IsValid(caller) or !caller:IsPlayer() or !caller:Alive()) then return; end;
	if (!entity_store or !IsValid(entity_store) or entity_store:IsWorld()) then return; end;

	local inv_id = self:inv_invGetID(entity_store);
	local inv_meta = core.inventoriesStore[inv_id];
	if (!inv_id) then return; end;
	if (!self:inv_invExists(inv_id)) then return; end;
	if (self:inv_invIsBusy(inv_id) and inv_meta._busy_ent != caller) then return; end;
	if (!self:inv_invIsBusy(inv_id)) then
		local tryBusy = self:inv_invSetBusy(inv_id, caller);
		if (!tryBusy) then return; end;
	end;

	local inv_meta = core.inventoriesStore[inv_id];
	netstream.Start(caller, "_angel_sensei.inventory.openSyncInv", {
		{
			maxWeight = inv_meta.weight_max,
			action = "safe",
			name = inv_meta.owner:GetNWString("inv_name", "box")
		},
		core:inv_itemGetAllByInv(inv_id),
		true
	});
	caller._angel_sensei_inv_action = "safe";
	caller._angel_sensei_inv_action_id = inv_id;
end;

netstream.Hook("_angel_sensei.inventory.openSyncInv", function(ply, action)
	if (isstring(action)) then
		if (action == "storage") then
			netstream.Start(ply, "_angel_sensei.inventory.openSyncInv", {
				{
					maxWeight = core.config["storage_weight"],
					action = "storage",
					name = "Items bank"
				},
				core:inv_itemGetAllByInvInStore(core:inv_invGetID(ply)),
				true
			});
			ply._angel_sensei_inv_action = "storage";
		end;
	else
		// to be continue...
	end;
end);

netstream.Hook("_angel_sensei_inventory_unSync", function(ply)
	netstream.Start(ply, "_angel_sensei.inventory.openSyncInv", {
		{
			maxWeight = 0,
			action = false,
			name = "unsynced"
		},
		{},
	});
	ply._angel_sensei_inv_action = false;
end);