local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.inventoriesStore = core.inventoriesStore or {};

function core:inv_invGetStoreMaxWeight(entity)
	if (!entity:IsPlayer()) then return 0; end;
	return core.config["storage_weight"];
end;

function core:inv_invGetStoreWeight(entity)
	if (!entity:IsPlayer()) then return 0; end;
	if (!self:inv_invExists(entity)) then return 0; end;
	local inv_id = self:inv_invGetID(entity);

	local weight = 0;
	for k,v in pairs(self:inv_itemGetAllByInvInStore(inv_id)) do
		weight = weight + v.weight;
	end;

	return weight; 
end;

function core:inv_invIsAvaliableStoreWeight(entity, weight)
	if (!self:inv_invExists(entity)) then return false; end;

	local max = self:inv_invGetStoreMaxWeight(entity);
	local stored = self:inv_invGetStoreWeight(entity);
	
	return (max - stored) >= weight and true or false;
end;

function core:inv_invGetMaxWeight(entity)
	if (!self:inv_invExists(entity)) then return 0; end;
	local inv_id = self:inv_invGetID(entity);

	return core.inventoriesStore[inv_id].weight_max;
end;

function core:inv_invGetWeight(entity)
	if (!self:inv_invExists(entity)) then return 0; end;
	local inv_id = self:inv_invGetID(entity);

	local weight = 0;
	for k,v in pairs(self:inv_itemGetAllByInv(inv_id)) do
		weight = weight + v.weight;
	end;

	return weight; 
end;

function core:inv_invIsAvaliableWeight(entity, weight)
	if (!self:inv_invExists(entity)) then return false; end;
	local inv_id = self:inv_invGetID(entity);
	local max = self:inv_invGetMaxWeight(entity);
	local stored = self:inv_invGetWeight(entity);
	
	return (max - stored) >= weight and true or false;
end;

if (CLIENT) then
	function core:inv_invGetSelfWeight()
		local weight = 0;

		for k, v in pairs(self.storeSelfInventory) do
			weight = weight + v.weight;
		end

		return weight; 
	end;
	function core:inv_invGetSyncWeight()
		local weight = 0;

		for k, v in pairs(self.storeSyncInventory) do
			weight = weight + v.weight;
		end

		return weight; 
	end;
end;