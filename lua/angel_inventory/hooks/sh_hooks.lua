local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {}; 
local core = _angel_sensei.inventory;
core.inventoriesStore = core.inventoriesStore or {};

/*---------------------------------------------------------------------------
Загрузка инвентаря
---------------------------------------------------------------------------*/
local function PlayerInitialSpawn(ply)
	local weight = core.config["default_weight"];
	if (core.config["inv_usergroup_weight"][ply:GetUserGroup()]) then
		weight = core.config["inv_usergroup_weight"][ply:GetUserGroup()];
	end;
	local inv_id = core:inv_invCreate(ply, weight);
	netstream.Start(ply, "_angel_sensei.inventory.syncData", {"self", core.inventoriesStore[inv_id]});

	/*---------------------------------------------------------------------------
	Загрузка MySQL
	---------------------------------------------------------------------------*/
	core:inv_sql_init(function()
		core:inv_sql_find(ply, function(finded)
			if (!finded) then
				core:inv_sql_create(ply);
			else
				core:inv_sql_load(ply, function(data)
					if (!data) then return; end;
					if (isstring(data["items"])) then data["items"] = util.JSONToTable(data["items"]); end;

					for k, v in pairs(data["items"]) do
						local item_class = v[3];
						local item_base = core:inv_itemGetBase(item_class);
						if (!item_base and !table.HasValue(core.externalItems,item_class)) then continue; end;
						local weight =  item_base and item_base.weight
										or item_class == "spawned_weapon" and core.config["def_weight_weapon"]
										or item_class == "spawned_shipment" and core.config["def_weight_shipment"]
										or item_class == "spawned_ammo" and core.config["def_weight_ammo"]
										or item_class == "spawned_food" and core.config["def_weight_food"]
										or false;
						local category = item_base and item_base.category
										or item_class == "spawned_weapon" and core.config["category_names"]["spawned_weapon"]
										or item_class == "spawned_shipment" and core.config["category_names"]["spawned_shipment"]
										or item_class == "spawned_ammo" and core.config["category_names"]["spawned_ammo"]
										or item_class == "spawned_food" and core.config["category_names"]["spawned_food"]
										or "";
						item_id = table.insert(core.itemsStore, {
							name = v[1] or "...",
							description = v[2] or "...",
							data = v[5] or {},
							model = v[5]._model or item_base.model or "",
							weight = v[6] or weight or core.config["def_weight_unknown"],
							inv_id = core:inv_invGetID(ply) or false,
							owner = ply or false,
							in_store = v[4] or false,
							base_id = item_class or false,
							category = category
						});
					end;

					core:inv_invSendClientSide(ply);
				end);
			end
		end);
	end);
end;
local function PlayerDisconnect(ply)
	core:inv_sql_save(ply, function()	/* сохранение инвентаря */
		core:inv_sql_unload(ply);
	end);
end;

if (CLIENT) then
	netstream.Hook("_angel_sensei.inventory.syncData", function(data)	-- Inv data
		local action = data[1];
		local inventory_data = data[2];
		if (action == "self") then
			core.storeSelfInventoryData = inventory_data;
		end;
	end);

	netstream.Hook("_angel_sensei.inventory.syncInventory", function(data)	-- Inv store
		core.storeSelfInventory = data;
	end);
end;

hook.Add("PlayerInitialSpawn", "_angel_sensei.inventory.inventoryInitialize", PlayerInitialSpawn);
hook.Add("PlayerDisconnected", "_angel_sensei.inventory.inventorySave", PlayerDisconnect);


/*---------------------------------------------------------------------------
Нарисовать предметы в интерфейсе
---------------------------------------------------------------------------*/
if (CLIENT) then
	bb_local_inv_entsStore = {};
	local entsToTrace = {
		"prop_physics", "bb_safe", "bb_storage"
	};
	local function isView(ent)
		local viewEnt = LocalPlayer():GetEyeTrace().Entity;
		return viewEnt == ent;
	end;

	local function DrawStorageHUD()
		for k,v in pairs(bb_local_inv_entsStore) do
			if (v == nil) then continue; end;
			if (v:GetClass() != "bb_storage") then continue; end;
			v._bb_inv_alpha = v._bb_inv_alpha or 0;
			v._bb_inv_lastTime = v._bb_inv_lastTime or 0;
			if (LocalPlayer():GetPos():Distance(v:GetPos()) < 200 and isView(v)) then
				v._bb_inv_alpha = Lerp(FrameTime()*3, v._bb_inv_alpha, 1);
				v._bb_inv_lastTime = CurTime();
			end;

			if ((LocalPlayer():GetPos():Distance(v:GetPos()) > 200 or !isView(v)) and v._bb_inv_lastTime + 5 > CurTime()) then
				v._bb_inv_alpha = Lerp(FrameTime()*6, v._bb_inv_alpha, 0);
			end;

			local pos = v:GetPos():ToScreen();
			-- Draw info


			draw.SimpleTextOutlined("Хранилище", "Raleway Bold 21", pos.x, pos.y, ColorAlpha(core.config["main_color"], 255*v._bb_inv_alpha), 1, 1, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
			draw.SimpleTextOutlined("Здесь вы можете хранить вещи", "Raleway Bold 15", pos.x, pos.y+19, Color(255, 255, 255, 255*v._bb_inv_alpha), 1, 1, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
		end;
	end;

	local function DrawStoragePropHUD()
		for k,v in pairs(bb_local_inv_entsStore) do
			if (v == nil) then continue; end;
			if (v:GetClass() != "prop_physics") then continue; end;
			v._bb_inv_alpha = v._bb_inv_alpha or 0;
			v._bb_inv_lastTime = v._bb_inv_lastTime or 0;
			if (LocalPlayer():GetPos():Distance(v:GetPos()) < 200 and isView(v)) then
				v._bb_inv_alpha = Lerp(FrameTime()*3, v._bb_inv_alpha, 1);
				v._bb_inv_lastTime = CurTime();
			end;

			if ((LocalPlayer():GetPos():Distance(v:GetPos()) > 200 or !isView(v)) and v._bb_inv_lastTime + 5 > CurTime()) then
				v._bb_inv_alpha = Lerp(FrameTime()*6, v._bb_inv_alpha, 0);
			end;

			local pos = v:GetPos():ToScreen();
			-- Draw info

			local cfgItem = (core.config["inv_storage_props"][v:GetModel()] or {});
			draw.SimpleTextOutlined("Хранилище", "Raleway Bold 15", pos.x, pos.y, ColorAlpha(core.config["main_color"], 255*v._bb_inv_alpha), 1, 1, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
			draw.SimpleTextOutlined("Вы можете сохранить это в хранилище, нажмите `ALT+E`", "Raleway 13", pos.x, pos.y+17, Color(255, 255, 255, 255*v._bb_inv_alpha), 1, 1, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
			draw.SimpleTextOutlined("Цена "..cfgItem.price.."$, максимальный вес "..cfgItem.weight.." кг", "Raleway 13", pos.x, pos.y+17+14, Color(255, 255, 255, 255*v._bb_inv_alpha), 1, 1, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
		end;
	end;

	local function DrawStoragePlayersHUD()
		for k,v in pairs(bb_local_inv_entsStore) do
			if (v == nil) then continue; end;
			if (v:GetClass() != "bb_safe") then continue; end;
			v._bb_inv_alpha = v._bb_inv_alpha or 0;
			v._bb_inv_lastTime = v._bb_inv_lastTime or 0;
			if (LocalPlayer():GetPos():Distance(v:GetPos()) < 200 and isView(v)) then
				v._bb_inv_alpha = Lerp(FrameTime()*3, v._bb_inv_alpha, 1);
				v._bb_inv_lastTime = CurTime();
			end;

			if ((LocalPlayer():GetPos():Distance(v:GetPos()) > 200 or !isView(v)) and v._bb_inv_lastTime + 5 > CurTime()) then
				v._bb_inv_alpha = Lerp(FrameTime()*6, v._bb_inv_alpha, 0);
			end;

			local pos = v:GetPos():ToScreen();
			-- Draw info
		/*storage:SetNWString("inv_owner_name", ent:Name());
		storage:SetNWString("inv_owner_id", ent:SteamID());*/

			draw.SimpleTextOutlined(v:GetNWString("inv_owner_name", "Неизвестный владелец").." ("..v:GetNWString("inv_owner_id", "STEAM_0:0:000")..")", "Raleway Bold 15", pos.x, pos.y, ColorAlpha(core.config["main_color"], 255*v._bb_inv_alpha), 1, 0, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
			draw.SimpleTextOutlined(v:GetNWString("inv_name", "box").." / "..v:GetNWString("inv_maxWeight", "0").." кг", "Raleway 19", pos.x, pos.y, Color(255, 255, 255, 255*v._bb_inv_alpha), 1, 4, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
			
			draw.SimpleTextOutlined("ЗДОРОВЬЕ", "Raleway 13", pos.x-75, pos.y+17+19, Color(255, 255, 255, 255*v._bb_inv_alpha), 0, 0, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
			draw.SimpleTextOutlined(v:GetNWString("inv_health", "0").."/"..v:GetNWString("inv_maxHealth", v:GetNWString("inv_health", "0")), "Raleway 13", pos.x+75, pos.y+17+19, Color(255, 255, 255, 255*v._bb_inv_alpha), 2, 0, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
			draw.RoundedBox(0, pos.x-75, pos.y+17+19+15, 150, 2, Color(0, 0, 0, 150*v._bb_inv_alpha)); 
			draw.RoundedBox(0, pos.x-75, pos.y+17+19+15, 150/v:GetNWString("inv_maxHealth", v:GetNWString("inv_health", "0"))*v:GetNWString("inv_health", "0"), 2, ColorAlpha(core.config["main_color"], 150*v._bb_inv_alpha)); 

			if (v:GetNWBool("inv_protected", false)) then
				draw.SimpleTextOutlined("*ТРЕБУЕТСЯ ПАРОЛЬ*", "Raleway Bold 13", pos.x, pos.y+17+19+13+15, Color(255, 36, 0, 255*v._bb_inv_alpha), 1, 0, 1, Color(0, 0, 0, 255*v._bb_inv_alpha));
			end;
		end;
	end;


	hook.Add("HUDPaint", "_angel_sensei.inventory.hud", function()
		for k,v in pairs(bb_local_inv_entsStore) do
			if (!v or !IsValid(v) or !IsEntity(v) or v:IsWorld()) then bb_local_inv_entsStore[k] = nil; continue; end;
		end;
		local viewEnt = LocalPlayer():GetEyeTrace().Entity;
		if (viewEnt and IsValid(viewEnt) and !viewEnt:IsWorld() and !viewEnt:IsPlayer() and table.HasValue(entsToTrace, viewEnt:GetClass()) and !table.HasValue(bb_local_inv_entsStore, viewEnt)) then
			if (viewEnt:GetClass() == "prop_physics" and core.config["inv_storage_props"][viewEnt:GetModel()] and FPP.entGetOwner(viewEnt) == LocalPlayer()) then table.insert(bb_local_inv_entsStore, viewEnt); end;
			if (viewEnt:GetClass() != "prop_physics") then table.insert(bb_local_inv_entsStore, viewEnt); end;
		end;

		DrawStorageHUD();
		DrawStoragePropHUD();
		DrawStoragePlayersHUD();
	end);

	//////////////////////////////////////////////////////////////
	// CreateStorage
	local toggled = false;
	hook.Add("Think", "_angel_sensei.inventory.createStorage", function()
		local keys = {}; 
		for k, v in pairs({KEY_LALT, KEY_E}) do
			keys[v] = false;
		end;
		for k, v in pairs(keys) do
			keys[k] = input.IsKeyDown(k);
		end;

		allPressed = true;
		for k, v in pairs(keys) do
			if (!v) then
				allPressed = false;
			end;
		end;

		if (allPressed and !toggled) then
			toggled = true;
			local entity_item = LocalPlayer():GetEyeTrace().Entity;

			if (entity_item and IsValid(entity_item) and !entity_item:IsPlayer() and entity_item:GetPos():Distance(LocalPlayer():GetPos()) <= core.actionDistance and entity_item:GetClass() == "prop_physics" and core.config["inv_storage_props"][entity_item:GetModel()] and FPP.entGetOwner(entity_item) == LocalPlayer()) then
				if (LocalPlayer():canAfford(core.config["inv_storage_props"][entity_item:GetModel()].price)) then
					netstream.Start("_angel_sensei.inventory.create", entity_item);
					surface.PlaySound(table.Random({"items/ammocrate_close.wav", "items/ammocrate_open.wav"}));
				else
					chat.AddText(Color(255, 255, 0), "[AngelicInventory system] - ", Color(255, 255, 255), "У вас недостаточно денег для этого действия!");
					surface.PlaySound("npc/roller/mine/combine_mine_deploy1.wav");
				end
			end;
		elseif (!allPressed and toggled) then
			toggled = false;
		end;
	end);
else
	netstream.Hook("_angel_sensei.inventory.create", function(ply, ent)
		if (!ent or !IsValid(ent) or ent:IsWorld() or ent:IsPlayer() or ent:GetClass() != "prop_physics" or !core.config["inv_storage_props"][ent:GetModel()]) then
			return;
		end;

		local item = core.config["inv_storage_props"][ent:GetModel()];
		if (!ply:canAfford(item.price)) then
			return;
		end;
		ply:addMoney(-item.price);
		local pos = ent:GetPos();
		local ang = ent:GetAngles();
		local mdl = ent:GetModel();
		ent:Remove();

		local storage = ents.Create("bb_safe");
		storage:SetPos(pos);
		storage:SetAngles(ang);
		storage:SetModel(mdl);
		storage:Spawn();
		storage:Activate();
		storage:SetNWString("inv_maxWeight", item.weight);
		storage:SetNWString("inv_health", item.health);
		storage:SetNWString("inv_maxhealth", item.health);
		storage:SetNWString("inv_name", item.name);

		storage:SetNWString("inv_owner_name", ply:Name());
		storage:SetNWString("inv_owner_id", ply:SteamID());

		if (item.canDraggable) then
			local physObj = storage:GetPhysicsObject();

			if (IsValid(physObj)) then
				physObj:EnableMotion(true);
				//physObj:Sleep();
			end;

			storage:SetMoveType(MOVETYPE_VPHYSICS);
		end;

		core:inv_invCreate(storage, item.weight);
	end);
end;