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

function core:inv_itemGive(entity_store, entity_item)
	if (!entity_store or !IsValid(entity_store)) then return false; end;
	if (!entity_item or !IsValid(entity_item)) then return false; end;
	if (!self:inv_itemIsPickable(entity_item)) then return false; end;

	/*if (entity_item:GetClass() == "spawned_ammo") then
		local ent_data = getDTVars(entity_item);
		PrintTable(ent_data);
		return
		//local content_data = CustomShipments[ent_data.contents];
	end;*/

	local entity_item_class = entity_item:GetClass();
	local item_base = self:inv_itemGetBase(entity_item_class);
	local inv_id = core:inv_invGetID(entity_store);
	local item_id;
	if (!table.HasValue(core.externalItems, entity_item_class)) then
		item_id = table.insert(core.itemsStore, {
			inv_id = inv_id,
			owner = entity_store,
			in_store = false,
			weight = item_base.weight,
			model = item_base.model,
			name = item_base.name,
			category = item_base.category,
			description = item_base.description,
			data = item_base.saveCallback(entity_item),
			base_id = entity_item_class
		});
	else 
		item_id = table.insert(core.itemsStore, {
			inv_id = inv_id,
			owner = entity_store,
			in_store = false,
			weight = 0,
			model = "",
			name = "",
			category = "",
			description = "",
			data = {},
			base_id = ""
		});
	end;

	if (entity_item_class == "spawned_shipment") then
		local ent_data = getDTVars(entity_item);
		local content_data = CustomShipments[ent_data.contents];
		core.itemsStore[item_id].name = "Shipment "..content_data.name;
		core.itemsStore[item_id].data["storeID"] = ent_data.contents;
		core.itemsStore[item_id].data["count"] = ent_data.count;
		core.itemsStore[item_id].data["_model"] = entity_item:GetModel();
		core.itemsStore[item_id].model = content_data.model;
		core.itemsStore[item_id].base_id = "spawned_shipment";
		core.itemsStore[item_id].weight = core.config["def_weight_shipment"];
		core.itemsStore[item_id].category = core.config["category_names"]["spawned_shipment"];
		core.itemsStore[item_id].description = "Count: "..ent_data.count..", category: "..content_data.category.."";
	elseif (entity_item_class == "spawned_weapon") then
		local ent_data = getDTVars(entity_item);
		local content_data = weapons.Get(ent_data.WeaponClass);
		local config_data = core.config["inv_weapon_descriptions"][ent_data.WeaponClass] or {};
		core.itemsStore[item_id].name = config_data[1] or ent_data.WeaponClass;
		core.itemsStore[item_id].data["weapon_class"] = ent_data.WeaponClass;
		core.itemsStore[item_id].data["amount"] = ent_data.amount;
		core.itemsStore[item_id].data["_model"] = content_data.WorldModel;
		core.itemsStore[item_id].model = content_data.WorldModel;
		core.itemsStore[item_id].base_id = "spawned_weapon";
		core.itemsStore[item_id].weight = core.config["inv_weapon_descriptions"][ent_data.WeaponClass][3] and core.config["inv_weapon_descriptions"][ent_data.WeaponClass][3] or self.config["def_weight_weapon"];
		core.itemsStore[item_id].category = core.config["category_names"]["spawned_weapon"];
		core.itemsStore[item_id].description = "Count: "..ent_data.amount.." - "..(config_data[2] or "");
	elseif (entity_item_class == "spawned_ammo") then
		core.itemsStore[item_id].data["ammo_type"] = entity_item.ammoType;
		core.itemsStore[item_id].data["ammo_count"] = entity_item.amountGiven;
		core.itemsStore[item_id].data["_model"] = entity_item:GetModel();
		core.itemsStore[item_id].model = entity_item:GetModel();

		core.itemsStore[item_id].name = "Ammo "..entity_item.ammoType;
		core.itemsStore[item_id].base_id = "spawned_ammo";
		core.itemsStore[item_id].weight = core.config["def_weight_ammo"];
		core.itemsStore[item_id].category = core.config["category_names"]["spawned_ammo"];
		core.itemsStore[item_id].description = "Count: "..entity_item.amountGiven;
	elseif (entity_item_class == "spawned_food") then
		core.itemsStore[item_id].data["FoodName"] = entity_item.FoodName;
		core.itemsStore[item_id].data["FoodEnergy"] = entity_item.FoodEnergy;
		core.itemsStore[item_id].data["FoodPrice"] = entity_item.FoodPrice;
		core.itemsStore[item_id].data["_model"] = entity_item:GetModel();

		core.itemsStore[item_id].model = entity_item:GetModel();

		core.itemsStore[item_id].name = entity_item.FoodName;
		core.itemsStore[item_id].base_id = "spawned_food";
		core.itemsStore[item_id].weight = core.config["def_weight_food"];
		core.itemsStore[item_id].category = core.config["category_names"]["spawned_food"];
		core.itemsStore[item_id].description = "Энергия: "..entity_item.FoodEnergy;
	end;

	if (IsValid(entity_item)) then
		entity_item:Remove();
	end;

	if (entity_store:IsPlayer()) then
		self:inv_invSendClientSide(entity_store);
		core:inv_sql_save(entity_store);
	end;

	return item_id;
end;
