// Global vars
local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.derma = core.derma or {};
core.derma.activeMenu = core.derma.activeMenu or nil;

local x, y = ScrW(), ScrH();
local align = 25;
local inv_size = 0.375; local inv_align = 0.0625;

local function getItemsCategories()
	local catergires = {};

	for k,v in pairs(core.storeSyncInventory) do
		if (!catergires[v.category or ""]) then
			catergires[v.category or ""] = true;
		end;
	end;

	return catergires;
end;

local function getCats()
	return GetConVar("_angel_sensei_inventory_showCats"):GetBool();
end;

function core.derma.createStorgateWindow()
	local anim = true;

	core.derma.createWindow();
	core.derma.createSelf(true);
	core.derma.createTransferIcons();
	
	local main_color = core.config["main_color"];
	local parent = core.derma.activeMenu;
	local anim = parent.anim;
	local sizex = x*inv_size;

	local _list = vgui.Create("DPanel", parent);
	_list:SetSize(sizex, y - align*2 - 36);
	_list:SetPos(x*0.5+x*inv_align or x*inv_align, align*1 + 36);
	_list.Paint = function(self, w, h) 
		if (!anim) then return; end;
		self.phase = self.phase or false;
		self.sizeH = Lerp(FrameTime()*(self.phase and 8 or 4), self.sizeH or 0, self.phase and 0 or 1.1);
		if (self.sizeH >= 1) then self.phase = true; end;

		draw.RoundedBox(0, 0, self.phase and h - h*self.sizeH or 0, w, h*self.sizeH, Color(255, 255, 255, 25*self.sizeH));
		draw.DashedLineVertical(0, self.phase and h - h*self.sizeH or 0, 1, h*self.sizeH, 1, 5, Color(255, 255, 255, 255));
		draw.DashedLineVertical(w-1, self.phase and h - h*self.sizeH or 0, 1, h*self.sizeH, 1, 5, Color(255, 255, 255, 255));
	end;

	local item_list = vgui.Create("DScrollPanel", _list);
	item_list:Dock(FILL);
	item_list:SetPos(align, align*2+36);
	item_list.parents = {};

	local sbar = item_list:GetVBar();
	sbar:SetWide(0);

	local items = vgui.Create("DIconLayout", item_list);
	items:Dock(FILL);
	items:SetSpaceX(10);
	items:SetSpaceY(10);
	if (anim) then
		items:SetAlpha(0);
		items:AlphaTo(255, 1);
	end;
	items.Paint = function(self, w, h)
	end;
	parent.transferListSync = items;

	local controllPanel = vgui.Create("DPanel", items);
	controllPanel.Paint = function() end;
	controllPanel:SetSize(sizex, 0);    

	local header = vgui.Create("DPanel", items);  
	header:SetSize(sizex, 50);
	header.Paint = function(self, w, h)
		draw.SimpleText("Хранилище", "Raleway 23", w/2, 25/2, Color(255, 255, 255, 150), 1, 1);
		draw.SimpleText(core.syncInfo.name, "Raleway Bold 15", w/2, 27, main_color, 1, 0);

		draw.DashedLine(w*0.1, h-1, w-w*0.2, 1, 1, 4, Color(255, 255, 255, 75));
	end;

	local weight = vgui.Create("DPanel", items);
	weight:SetSize(sizex, 70);
	weight.Paint = function(self, w, h)
		/*draw.SimpleText("Weight", "Raleway 17", 0, 0, Color(255, 255, 255, 150), 0, 0);
		draw.SimpleText("0 / 0 ", "Raleway 17", w-17, 0, Color(255, 255, 255, 150), 2, 0);
		draw.SimpleText("Kg", "Raleway Bold 15", w, 17, main_color, 2, 4);*/

		draw.RoundedBox(0, 0, 45, 2, 10, Color(255, 255, 255, 75));				// Bot
		draw.RoundedBox(0, w-2, 45, 2, 10, Color(255, 255, 255, 75));			// Bot
		draw.DashedLine(2, 45+10/2-1, w-4, 2, 4, 4, Color(255, 255, 255, 75));	// Bot
		draw.SimpleText("Максимальный вес: "..core.syncInfo.maxWeight.." кг", "Raleway Bold 15", w/2, 45+10/2+1, Color(255, 255, 255, 150), 1, 0);

		local currentWeightText = "Текущий: "..core:inv_invGetSyncWeight().." кг";
		surface.SetFont("Raleway Bold 15");
		local w1, _ = surface.GetTextSize(currentWeightText);
		local weightPos = math.Clamp((w/core.syncInfo.maxWeight*core:inv_invGetSyncWeight())/2, 0, w-w1);
		if (weightPos < w1/2) then 
			weightPos = w/2;
		end;
		local lineWidth = math.Clamp((w-2)/core.syncInfo.maxWeight*core:inv_invGetSyncWeight(), 0, w-2);
		draw.RoundedBox(0, 0, 20-10, 2, 10, Color(255, 255, 255, 75));			// Top
		draw.RoundedBox(0, lineWidth, 20-10, 2, 10, Color(255, 255, 255, 75));		// Top
		draw.RoundedBox(0, 2, 20-10/2-1, lineWidth-2, 2, Color(255, 255, 255, 75));		// Top
		draw.SimpleText(currentWeightText, "Raleway Bold 15", weightPos, 20-10/2-1, main_color, 1, 4);

		draw.RoundedBox(0, 0, 22, w, 21, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 0, 22, lineWidth+2, 21, draw.colorAlpha(main_color, 75));

		draw.SimpleText("ВЕС", "Raleway Bold 13", w/2, 20+25/2, Color(255, 255, 255, 150), 1, 1);
	end;

	function parent.BuildSyncPanel()
		for k,v in pairs(items:GetChildren()) do
			if (v._search) then
				v:Remove();
			end;
		end;
		for cat, _ in pairs(getItemsCategories()) do
			local category = vgui.Create("DPanel", items);
			category:SetSize(sizex, 17);
			category.category = cat;
			category._search = true;
			category.Paint = function(self, w, h)
				draw.SimpleText(self.category, "Raleway Bold 15", 0, h/2, Color(255, 255, 255, 25), 0, 1);
				surface.SetFont("Raleway Bold 17");
				local w1, _ = surface.GetTextSize(self.category);
				draw.RoundedBox(0, w1+5, h/2+1, w-w1-5, 1, Color(255, 255, 255, 5));
			end;
			local count = 0;
			for k, item in pairs(core.storeSyncInventory) do
				if ((item.category or "") != cat) then continue; end;

				count = count + 1;
				item._id = k;
				local ditem = core.derma:CreateItem(items, sizex, item, false, true);
				ditem._search = true;
			end;

			if (count == 0 or !getCats()) then
				category:Remove();
			end;
		end;
	end;
	parent.BuildSyncPanel();

	local category = vgui.Create("DPanel", items);
	category:SetSize(sizex, 17);
	category.Paint = function(self, w, h)
		draw.SimpleText("Ожидание", "Raleway Bold 15", 0, h/2, ColorAlpha(main_color, 150), 0, 1);
		surface.SetFont("Raleway Bold 17");
		local w1, _ = surface.GetTextSize("Ожидание");
		draw.DashedLine(w1+5, h/2+1, w-w1-5, 2, 3, 5, ColorAlpha(main_color, 150));
	end;
end;

hook.Add("_angel_sensei.inventory.itemAction", "cl_storage", function(data)
	if (!IsValid(core.derma.activeMenu)) then return false; end;
	if (!IsValid(core.derma.activeMenu.transferListSync)) then return false; end;
	if (!data[1]) then return; end;
	local ditem = core.derma:CreateItem(core.derma.activeMenu.transferListSync, x*inv_size, data[2], false, true, true);
	print(ditem:GetParent());
	timer.Simple(0.1, function()
		core.derma.activeMenu.transferListSync:GetParent():GetParent():Rebuild();
	end);
end);

netstream.Hook("_angel_sensei.inventory.openSyncInv", function(data)
	core.syncInfo = data[1];
	core.storeSyncInventory = data[2];
	if (data[3]) then
		core.derma.createStorgateWindow();
	end;
end); 