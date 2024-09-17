local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.itemsStore = core.itemsStore or {};

function core:inv_itemPickup(entity_store, entity_item)
	local entity_item_class = entity_item:GetClass();
	if (!self:inv_itemCanPickup(entity_store, entity_item)) then return false; end;
	
	if (!table.HasValue(core.externalItems, entity_item_class)) then
		local item_base = self:inv_itemGetBase(entity_item_class);
		local customCheck = item_base.saveCustomcheck(entity_store, entity_item);
		if (!customCheck) then return false; end;
	end;

	local item_id = self:inv_itemGive(entity_store, entity_item);
	if (entity_store:IsPlayer()) then
		entity_store:EmitSound("items/ammo_pickup.wav");
	end;
	
	return true;
end;

function core:inv_itemTake(entity_store, item_id)
	if (self:inv_itemGetOwner(item_id) != entity_store) then return false; end;

	self.itemsStore[item_id] = nil;

	if (entity_store:IsPlayer()) then
		self:inv_invSendClientSide(entity_store);
		core:inv_sql_save(entity_store);
	end;
end;

function core:inv_itemDrop(entity_store, item_id)
	if (self:inv_itemGetOwner(item_id) != entity_store) then return false; end;

	local item_store = self:inv_itemGet(item_id);
	local item_base = self:inv_itemGetBase(item_store.base_id);

	self:inv_itemTake(entity_store, item_id);

	local item_entity = ents.Create(item_store.base_id);
	item_entity:SetPos(entity_store:GetPos() + entity_store:GetForward()*45 + entity_store:GetUp()*35);
	item_entity:SetModel(item_store.model);

	if (item_store.base_id == "spawned_shipment") then
		item_entity:Setowning_ent(entity_store);
		item_entity:SetgunModel(item_store.model);
		item_entity:Setcount(item_store.data.count);
		item_entity:Setcontents(item_store.data.storeID);
    	local contents = CustomShipments[item_store.data.storeID];
    	item_entity:SetModel(contents and contents.shipmodel or "models/Items/item_item_crate.mdl");
		
		item_entity:Spawn();
		item_entity:Activate();
	elseif (item_store.base_id == "spawned_weapon") then
		item_entity:SetWeaponClass(item_store.data.weapon_class);
		item_entity:Setamount(item_store.data.amount);
    	item_entity:SetModel(item_store.model);
		
		item_entity:Spawn();
		item_entity:Activate();
	elseif (item_store.base_id == "spawned_ammo") then
		item_entity.ammoType = item_store.data["ammo_type"];
		item_entity.amountGiven = item_store.data["ammo_count"];
    	item_entity:SetModel(item_store.model);
		
		item_entity:Spawn();
		item_entity:Activate();
	elseif (item_store.base_id == "spawned_food") then
		item_entity.FoodName = item_store.data["FoodName"];
		item_entity.FoodEnergy = item_store.data["FoodEnergy"];
		item_entity.FoodPrice = item_store.data["FoodPrice"];
		item_entity.foodItem = {};
		
    	item_entity:SetModel(item_store.model);
		
		item_entity:Spawn();
		item_entity:Activate();
	else
		item_entity:Spawn();
		item_entity:Activate();
		item_base.initCallback(item_entity, entity_store, item_store.data);
	end;

	return item_entity;
end;


function core:inv_itemUse(entity_store, item_id)
	if (self:inv_itemGetOwner(item_id) != entity_store) then return false; end;

	local entity = self:inv_itemDrop(entity_store, item_id);
	entity:Use(entity_store, entity_store, 1, 1);
end;

function core:inv_itemDestroy(entity_store, item_id)
	if (self:inv_itemGetOwner(item_id) != entity_store) then return false; end;

	self:inv_itemTake(entity_store, item_id);
end;

function core:inv_itemStoreAction(entity_store, item_id)
	if (self:inv_itemGetOwner(item_id) != entity_store) then return false; end;
	local item = self.itemsStore[item_id];
	item.in_store = item.in_store or false;

	if (!item.in_store) then
		if (!self:inv_invIsAvaliableStoreWeight(entity_store, item.weight)) then return false; end;
	else
		if (!self:inv_invIsAvaliableWeight(entity_store, item.weight)) then return false; end;
	end;
	item.in_store = !item.in_store;
	
	self:inv_invSendClientSide(entity_store);
	netstream.Start(entity_store, "_angel_sensei.inventory.openSyncInv", {
		{
			maxWeight = core.config["storage_weight"],
			action = "storage",
			name = "Items bank"
		},
		core:inv_itemGetAllByInvInStore(core:inv_invGetID(entity_store))
	});
end;

function core:inv_itemStoreActionSafe(entity_store, entity_inv, item_id)
	if (self:inv_itemGetOwner(item_id) != entity_store and self:inv_itemGetOwner(item_id) != entity_inv) then return false; end;
	local item = self.itemsStore[item_id];

	local inv_id1 = self:inv_invGetID(entity_store);
	local inv_id2 = self:inv_invGetID(entity_inv);
	if (self:inv_itemGetOwner(item_id) == entity_store) then
		if (!self:inv_invIsAvaliableWeight(entity_inv, item.weight)) then return false; end;
		item.owner = entity_inv;
		item.inv_id = inv_id2;
		item.in_store = false;
	else
		if (!self:inv_invIsAvaliableWeight(entity_store, item.weight)) then return false; end;
		item.owner = entity_store;
		item.inv_id = inv_id1;
		item.in_store = false;
	end;

	local inv_meta = core.inventoriesStore[inv_id2];

	self:inv_invSendClientSide(entity_store);
	netstream.Start(entity_store, "_angel_sensei.inventory.openSyncInv", {
		{
			maxWeight = inv_meta.weight_max,
			action = "safe",
			name = inv_meta.owner:GetNWString("inv_name", "box")
		},
		core:inv_itemGetAllByInv(inv_id2)
	});
	entity_store._angel_sensei_inv_action = "safe";
	entity_store._angel_sensei_inv_action_id = inv_id2;
end;

if (SERVER) then
	netstream.Hook("_angel_sensei.inventory.pickUp", function(ply, item)
		if (!ply:Alive()) then return; end;
		if (!item or !IsValid(item)) then return; end;

		core:inv_itemPickup(ply, item);
	end);

	netstream.Hook("_angel_sensei.inventory.itemAction", function(ply, data)
		if (!istable(data)) then return false; end;
		local action = data[1];
		local item_id = data[2];
		local entity_store = ply;

		if (!isnumber(tonumber(item_id))) then return false; end;
		if (action == "store_action") then
			if (entity_store._angel_sensei_inv_action == "storage") then
				core:inv_itemStoreAction(entity_store, item_id);
				return true;
			elseif (entity_store._angel_sensei_inv_action == "safe") then
				local inv_id = entity_store._angel_sensei_inv_action_id;
				if (!inv_id) then entity_store._angel_sensei_inv_action = false; return; end;
				if (!core:inv_invExists(inv_id)) then entity_store._angel_sensei_inv_action = false; return; end;
				if (!core:inv_invIsBusy(inv_id)) then entity_store._angel_sensei_inv_action = false; return; end; 
				local inv_meta = core.inventoriesStore[inv_id];
				if (inv_meta._busy_ent != entity_store) then entity_store._angel_sensei_inv_action = false; return; end; 
				if (entity_store:GetPos():Distance(inv_meta._busy_ent_pos) > core.actionDistance/2) then entity_store._angel_sensei_inv_action = false; return; end; 
				
				core:inv_itemStoreActionSafe(entity_store, inv_meta.owner, item_id);
				return true;
			end;
			return;
		end;

		if (core:inv_itemGetOwner(item_id) != entity_store) then return false; end;

		if (action == "drop") then
			if (core:inv_itemGetInStore(item_id)) then return false; end;
			core:inv_itemDrop(entity_store, item_id);
			return true;
		elseif (action == "use") then
			if (core:inv_itemGetInStore(item_id)) then return false; end;
			if (!core:inv_itemCanUse(item_id)) then return false; end;
			core:inv_itemUse(entity_store, item_id);
			return true;
		elseif (action == "destroy") then
			if (core:inv_itemGetInStore(item_id)) then return false; end;
			if (!core:inv_itemCanDestroy(item_id)) then return false; end;
			core:inv_itemDestroy(entity_store, item_id);
			return true;
		end;

		return false;
	end);
end;
