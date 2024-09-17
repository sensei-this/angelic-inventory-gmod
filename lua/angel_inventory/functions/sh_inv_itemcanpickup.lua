local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.itemsStore = core.itemsStore or {};

local function getDTVars(ent)	/*by DarkRP Pocket code*/
    if not ent.GetNetworkVars then return nil end
    local name, value = debug.getupvalue(ent.GetNetworkVars, 1)
    if name ~= "datatable" then
        ErrorNoHalt("Warning: Таблицу данных невозможно правильно хранить в кармане. Расскажите разработчику!")
    end

    local res = {}

    for k,v in pairs(value) do
        res[k] = v.GetFunc(ent, v.index)
    end

    return res
end

function core:inv_itemIsPickable(entity_item)
	local item_class = entity_item:GetClass();
	if (!table.HasValue(self.externalItems,item_class) and !self:inv_itemIsRegistred(item_class)) then return false; end;
	if (entity_item:GetClass() == "spawned_weapon") then
		local weapon_class = entity_item:GetWeaponClass();
		if (!core.config["inv_weapon_descriptions"][weapon_class]) then
			return false;
		end;
	end;
	return true;
end;

function core:inv_itemCanPickup(entity_store, entity_item)
	local item_class = entity_item:GetClass();
	if (!self:inv_itemIsPickable(entity_item)) then return false; end;
	
	local workType = true;
	if (table.HasValue(self.externalItems,item_class)) then workType = false; end;

	if (workType) then
		local item_table = self:inv_itemGetBase(item_class);
		local item_weight = item_table.weight;
		if (!self:inv_invIsAvaliableWeight(entity_store, item_weight)) then
			return false;
		end;
		return true;
	else
		local ent_data = getDTVars(entity_item);
		if (item_class == "spawned_weapon") then
			if (!self:inv_invIsAvaliableWeight(entity_store, core.config["inv_weapon_descriptions"][ent_data.WeaponClass][3] and core.config["inv_weapon_descriptions"][ent_data.WeaponClass][3] or self.config["def_weight_weapon"])) then
				return false;
			end;
			return true;
		elseif (item_class == "spawned_shipment") then
			if (!self:inv_invIsAvaliableWeight(entity_store, self.config["def_weight_shipment"])) then
				return false;
			end;
			return true;
		elseif (item_class == "spawned_food") then	
			if (!self:inv_invIsAvaliableWeight(entity_store, self.config["def_weight_food"])) then
				return false;
			end;
			return true;
		elseif (item_class == "spawned_ammo") then	
			if (!self:inv_invIsAvaliableWeight(entity_store, self.config["def_weight_ammo"])) then
				return false;
			end;
			return true;
		end;
		return false;
	end;
	return false;
end;