
local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.config = core.config or {};

core.config["title"]				= "";		// Название окна
core.config["show_copyright"]		= true;
core.config["main_color"] 			= Color(255, 209, 55);		// Стандарт: Color(255, 209, 55)
core.config["default_weight"]		= 45.00;					// Вес персонажа по умолчанию в кг
core.config["storage_weight"]		= 100.00;					// Максимальный вес хранилища
core.config["storage_model"]		= "models/props_wasteland/controlroom_storagecloset001a.mdl";


-- Меню настройки
core.config["menu_commands"]		= {"!inv", ".inv", "/inv"};
core.config["menu_keybind"]			= {KEY_F6};
core.config["menu_closephrase"]		= "Нажмите F6 чтобы закрыть инвентарь";
core.config["pickup_keybind"]		= {KEY_R};
core.config["category_names"]		= {
											spawned_shipment 	= "Ящики",
											spawned_food		= "Еда",
											spawned_weapon		= "Оружие",
											spawned_ammo		= "Патроны",
									}

-- Вес объектов по умолчанию
core.config["def_weight_weapon"]	= 1;					
core.config["def_weight_shipment"] 	= 5;					
core.config["def_weight_ammo"] 		= 0;					
core.config["def_weight_food"]		= 0;					
core.config["def_weight_unknown"]	= 0;					

core.config["save_type"]			= "sv.db";				// Avaliable: "sv.db", "mysqloo"
/*---------------------------------------------------------------------------
Настройки MySQL - core.config["save_type"] = mysqloo
---------------------------------------------------------------------------*/
core.config["mysql_host"]           = "localhost";                          // host ip
core.config["mysql_database"]       = "bd_name";                            // database name
core.config["mysql_user"]           = "root";                               // user name
core.config["mysql_password"]       = "pass";                               // user password
core.config["mysql_port"]           = 3306;                                 // Port. default: 3306

/*---------------------------------------------------------------------------
веса групп пользователей
---------------------------------------------------------------------------*/

core.config["inv_usergroup_weight"] = {	// More space for some usergroups
}

/*---------------------------------------------------------------------------
Хранилища реквизита
---------------------------------------------------------------------------*/
core.config["inv_storage_passwordPrice"] = 250;
core.config["inv_storage_props"] = {
	["models/props_junk/wood_crate001a.mdl"] = {
		name = "Маленькая коробка",
		price = 250,
		weight = 5,
		health = 750
	},
	["models/props_junk/wood_crate002a.mdl"] = {
		name = "Большая коробка",
		price = 400,
		weight = 10,
		health = 1000
	}
}

/*---------------------------------------------------------------------------
Ассоциации с оружием
---------------------------------------------------------------------------*/
core.config["inv_weapon_descriptions"] = {	
	// EX: 	weapon_class = {name, description, weight} >> weapon_ak47 = {"AK47", "Типа описание", 3.5} // Пример кода
	tfa_mmod_smg 			= {"SMG", ""},
	tfa_mmod_pistol 		= {"9ММ Пистолет", ""},
	tfa_mmod_357 			= {"357 Револьвер", ""},
	tfa_mmod_shotgun 		= {"Дробовик", ""},
	tfa_cso2_mac10			= {"MAC-10", ""},
	tfa_mmod_ar2			= {"AR-2", ""},
    hacktool     			= {"Взломщик", ""},
    tfa_cso2_deserteagle	= {"Дигл", ""},
    tfa_mmod_grenade	    = {"Граната", ""},
    tfa_cso2_knife	        = {"Нож", ""},
    tfa_cso2_fiveseven	    = {"FiveSeven", ""},
    tfa_hl2b_sniperrifle	= {"Sniper Rifle", ""},
    tfa_cso2_crowbar	    = {"Монтировка", ""},
    tfa_cso2_flashbang	    = {"Флэшка", ""},
    tfa_cso2_smokegrenade	= {"Смоук", ""},
    tfa_cso2_glock18     	= {"Glock 18", ""},
    tfa_cso2_m3          	= {"M3", ""},
    tfa_cso2_dr200          = {"DR 200", ""},
    tfa_cso2_scout          = {"Scout", ""},
    tfa_hl2b_smg1           = {"SMG2", ""},
}