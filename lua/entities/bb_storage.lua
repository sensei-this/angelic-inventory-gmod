AddCSLuaFile();

local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
 
DEFINE_BASECLASS( "base_anim" );
ENT.PrintName = "[INV] Хранилище";
ENT.Author = "sensei_this";
ENT.Information = "Хранилище";
ENT.Category = "AngelicInventory";

ENT.Spawnable = true;
ENT.AdminOnly = true;
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT;

function ENT:SpawnFunction(client, trace)
	local angles = (client:GetPos() - trace.HitPos):Angle();
	angles.p = 0;
	angles.r = 0;
	angles:RotateAroundAxis(angles:Up(), 0);

	local entity = ents.Create("bb_storage");
	entity:SetPos(trace.HitPos + Vector(0, 0, 45));
	entity:SetAngles(angles:SnapTo("y", 45));
	entity:Spawn();

	return entity;
end

function ENT:Initialize()
	if (CLIENT) then return false; end;

	self:SetModel(core.config["storage_model"] or "models/props_wasteland/controlroom_storagecloset001a.mdl");
	
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(USE_TOGGLE);

	local physObj = self:GetPhysicsObject()

	if (IsValid(physObj)) then
		physObj:EnableMotion(false);
		physObj:Sleep();
	end;

	self:SetMoveType(MOVETYPE_NOCLIP);
	self:SetMoveType(MOVETYPE_PUSH);
end;

function ENT:Use(activator)
	if (!activator:IsPlayer()) then return false; end;

	netstream.Start(activator, "_angel_sensei.inventory.openSyncInv", {
		{
			maxWeight = core.config["storage_weight"],
			action = "Хранилище",
			name = "Хранение предметов"
		},
		core:inv_itemGetAllByInvInStore(core:inv_invGetID(activator)),
		true
	});
	activator._angel_sensei_inv_action = "storage";
end;

if (SERVER) then
	concommand.Add("bb_inventory_storageSave", function(ply)
		if (!ply:IsSuperAdmin()) then return; end;
		local data = {};

		for k,v in pairs(ents.GetAll()) do
			if (v:GetClass() != "bb_storage") then continue; end;

			local ent_data = {
				pos = v:GetPos(),
				ang = v:GetAngles(),
				model = v:GetModel()
			};
			table.insert(data, 1, ent_data);
		end;
		if (!file.IsDir("angel_inventories", "DATA")) then
			file.CreateDir("angel_inventories");
		end;

		file.Write("angel_inventories/"..game.GetMap()..".txt", util.TableToJSON(data));
		DarkRP.notify(ply, 0, 5, #data.." хранилище сохранено");
	end);

	local function loadStorage()
		if (!file.IsDir("angel_inventories", "DATA")) then
			file.CreateDir("angel_inventories");
		end;
		if (!file.Exists("angel_inventories/"..game.GetMap()..".txt", "DATA")) then return; end;
		local data = file.Read("angel_inventories/"..game.GetMap()..".txt", "DATA");
		data = util.JSONToTable(data);
		for k, v in pairs(data) do
			local ent = ents.Create("bb_storage");
			ent:SetModel(v.model);
			ent:SetPos(v.pos);
			ent:SetAngles(v.ang);
			ent:Spawn(); 
			ent:Activate();
		end;
	end;

	hook.Add("InitPostEntity", "bb_inventory_storageLoad", loadStorage);
end;