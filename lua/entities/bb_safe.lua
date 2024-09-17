AddCSLuaFile();

local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
 
DEFINE_BASECLASS( "base_anim" );
ENT.PrintName = "[INV] Хранилище";
ENT.Author = "sensei_This";
ENT.Information = "Хранилище";
ENT.Category = "AngelicInventory";

ENT.Spawnable = false;
ENT.AdminOnly = true;
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT;

function ENT:Initialize()
	if (CLIENT) then return false; end;

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

function ENT:OnTakeDamage(dmgInfo)
	local dmgVal = dmgInfo:GetDamage();
	local attacker = dmgInfo:GetAttacker();
	if (!attacker or !IsValid(attacker) or !attacker:IsPlayer()) then return; end;
	if (dmgVal > 100) then dmgVal = 100; end;
	self:SetNWString("inv_health",math.Clamp(self:GetNWString("inv_health","0") - dmgVal, 0, self:GetNWString("inv_maxHealth","100")));

	if (self:GetNWString("inv_health","0") <= 0) then
		self:Remove();
		self:EmitSound("physics/metal/metal_box_break"..math.random(1,2)..".wav");
	else
		self:EmitSound("physics/metal/metal_barrel_impact_hard"..math.random(1,7)..".wav");
	end;
end;

function ENT:Use(activator)
	if (!activator:IsPlayer()) then return false; end;

	core:inv_invSync(activator, self);
end;

function ENT:OnRemove() // Remove inventory
	local inv_id = core:inv_invGetID(self);

	for k, v in pairs(core.itemsStore) do
		if (v["inv_id"] != inv_id) then continue; end;
		//core.itemsStore[k] = nil;
		core:inv_itemDrop(self, k);
	end;

	for k,v in pairs(core.inventoriesStore) do
		if (k == inv_id) then
			core.inventoriesStore[k] = nil;
		end;
	end;
end;