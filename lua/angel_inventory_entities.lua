/*-Умный?-*/	local _angel_sensei = _angel_sensei or {};
/*-Умный?-*/	_angel_sensei.inventory = _angel_sensei.inventory or {};
/*-Умный?-*/	local core = _angel_sensei.inventory;

/*---------------------------------------------------------------------------
Примеры
---------------------------------------------------------------------------*/

--core:inv_regItem("money_printer", {
--	name 			= "Money printer",
--	description 	= "Money printer",
--	category		= "Test",
--	model 			= "models/props_c17/consolebox01a.mdl",
--	weight 			= 3.0,
--	canUse 			= false,
--	initCallback = function(ent, ply, data)
--		if (!IsValid(ply) or !IsValid(ent)) then return; end;
--		ent:Setowning_ent(ply);
--	end
--});

--core:inv_regItem("drug", {
--	name 			= "Drug",
--	description 	= "Drug are illegal item!",
--	category		= "Test",
--	model 			= "models/props_lab/jar01a.mdl",
--	weight 			= 0.35,
--});     


core:inv_regItem("item_ammo_ar2_large", {
	name 			= "Штурмовые патроны",
	description 	= "Тут тип описание",
	category		= "Патроны",
	model 			= "models/Items/combine_rifle_cartridge01.mdl",
	weight 			= 3.0,
	canUse 			= false,
});

core:inv_regItem("item_ammo_smg1_large", {
	name 			= "Ящик с припасами",
	description 	= "",
	category		= "Предметы",
	model 			= "models/Items/item_item_crate_dynamic.mdl",
	weight 			= 7.0,
	canUse 			= false,
});

core:inv_regItem("item_suit", {
	name 			= "HEV Костюм",
	description 	= "",
	category		= "Костюм",
	model 			= "models/Items/hevsuit.mdl",
	weight 			= 5.0,
	canUse 			= false,
});