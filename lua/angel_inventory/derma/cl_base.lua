// Global vars
local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.derma = core.derma or {};
core.derma.activeMenu = core.derma.activeMenu or nil;
core.derma.size = core.derma.size or GetConVar("_angel_sensei_inventory_size"):GetString();

local x, y = ScrW(), ScrH();
local align = 25;
local inv_size = 0.375; local inv_align = 0.0625;

local sizes = {
	["M"] = "Medium",
	["S"] = "Small"
}

function core.derma.createWindow()
	local main_color = core.config["main_color"];
	local anim = true;
	if (IsValid(core.derma.activeMenu)) then anim = false; end;
	if (IsValid(core.derma.activeMenu)) then
		core.derma.Close();
	end
	
	core.derma.activeMenu = vgui.Create("DFrame");
	local _frame = core.derma.activeMenu;
	_frame:SetSize(x, y);
	_frame:SetPos(0, 0);
	_frame:SetTitle("");
	_frame.anim = anim;
	_frame:SetDraggable(false);
	_frame:MakePopup();
	_frame:ShowCloseButton(false);
	_frame.startTime = SysTime();
	_frame.Paint = function(self, w, h)
		Derma_DrawBackgroundBlur(self, self.startTime);
		draw.SimpleText(core.config.title, "Raleway ExtraBold 36", w/2, align, main_color, 1, 2);
		draw.SimpleText(core.config["menu_closephrase"], "Raleway 15", w/2, align, Color(255, 255, 255, 150), 1, 4);
	end;
end;

local function getItemsCategories()
	local catergires = {};

	for k,v in pairs(core.storeSelfInventory) do
		if (!catergires[v.category or ""]) then
			catergires[v.category or ""] = true;
		end;
	end;

	return catergires;
end;

local function getCats()
	return GetConVar("_angel_sensei_inventory_showCats"):GetBool();
end;

function core.derma.createSelf(isTransfer, isRight)
	if (!IsValid(core.derma.activeMenu)) then return false; end;
	local main_color = core.config["main_color"];
	local parent = core.derma.activeMenu;
	local sizex = x*inv_size
	local _list = vgui.Create("DPanel", parent);
	_list:SetSize(sizex, y - align*2 - 36);
	_list:SetPos(isTransfer and (isRight and x*0.5+x*inv_align or x*inv_align) or x/2-sizex/2, align*1 + 36);
	_list.Paint = function(self, w, h) 
		if (!parent.anim) then return; end;
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
	if (parent.anim) then
		items:SetAlpha(0);
		items:AlphaTo(255, 1);
	end;
	items.Paint = function(self, w, h)
	end; 
	parent.transferList = items;

	local header = vgui.Create("DPanel", items);
	header:SetSize(sizex, 50);
	header.Paint = function(self, w, h)
		draw.SimpleText(LocalPlayer():Name(), "Raleway 23", w/2, 25/2, Color(255, 255, 255, 150), 1, 1);
		//surface.SetFont("Raleway 21");
		//local w1, _ = surface.GetTextSize(LocalPlayer():Name());
		//draw.RoundedBox(0, w/2-w1/4, 25-1, w1/2, 1, Color(255, 255, 255, 150));
		draw.SimpleText("Инвентарь", "Raleway Bold 15", w/2, 27, main_color, 1, 0);

		draw.DashedLine(w*0.1, h-1, w-w*0.2, 1, 1, 4, Color(255, 255, 255, 75));
	end;

	local weight = vgui.Create("DPanel", items);
	weight:SetSize(sizex, 70);
	weight.Paint = function(self, w, h)
		/*draw.SimpleText("Вес", "Raleway 17", 0, 0, Color(255, 255, 255, 150), 0, 0);
		draw.SimpleText("0 / 0 ", "Raleway 17", w-17, 0, Color(255, 255, 255, 150), 2, 0);
		draw.SimpleText("кг", "Raleway Bold 15", w, 17, main_color, 2, 4);*/

		draw.RoundedBox(0, 0, 45, 2, 10, Color(255, 255, 255, 75));				// Bot
		draw.RoundedBox(0, w-2, 45, 2, 10, Color(255, 255, 255, 75));			// Bot
		draw.DashedLine(2, 45+10/2-1, w-4, 2, 4, 4, Color(255, 255, 255, 75));	// Bot
		draw.SimpleText("Максимальный вес: "..core.storeSelfInventoryData.weight_max.." кг", "Raleway Bold 15", w/2, 45+10/2+1, Color(255, 255, 255, 150), 1, 0);

		local currentWeightText = "Сейчас: "..core:inv_invGetSelfWeight().." кг";
		surface.SetFont("Raleway Bold 15");
		local w1, _ = surface.GetTextSize(currentWeightText);
		local weightPos = math.Clamp((w/core.storeSelfInventoryData.weight_max*core:inv_invGetSelfWeight())/2, 0, w-w1);
		if (weightPos < w1/2) then
			weightPos = w/2;
		end;
		local lineWidth = math.Clamp((w-2)/core.storeSelfInventoryData.weight_max*core:inv_invGetSelfWeight(), 0, w-2);
		draw.RoundedBox(0, 0, 20-10, 2, 10, Color(255, 255, 255, 75));			// Top
		draw.RoundedBox(0, lineWidth, 20-10, 2, 10, Color(255, 255, 255, 75));		// Top
		draw.RoundedBox(0, 2, 20-10/2-1, lineWidth-2, 2, Color(255, 255, 255, 75));		// Top
		draw.SimpleText(currentWeightText, "Raleway Bold 15", weightPos, 20-10/2-1, main_color, 1, 4);

		draw.RoundedBox(0, 0, 22, w, 21, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 0, 22, lineWidth+2, 21, ColorAlpha(main_color, 75));

		draw.SimpleText("ВЕС", "Raleway Bold 13", w/2, 20+25/2, Color(255, 255, 255, 150), 1, 1);
	end;

	local controllPanel = vgui.Create("DPanel", items);
	controllPanel:SetSize(sizex, 40);
	controllPanel.Paint = function() end;
	if (isTransfer) then
		controllPanel:SetSize(sizex, 0);
	end;

	local searchField = vgui.Create("DTextEntry", controllPanel);
	searchField:SetSize(sizex-75, 40);
	searchField:SetPos(0, 0);
	searchField:SetText("");
	searchField.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);

		self.alpha = self.alpha or 0; 
		draw.RoundedBox(0, 0, 0, w, 25, Color(0, 0, 0, 100 + 105*self.lerp1));
		if (self:IsEditing()) then
			self.alpha = Lerp(FrameTime()*4, self.alpha, 1); 
		else
			self.alpha = Lerp(FrameTime()*2, self.alpha, 0); 
		end;
		draw.RoundedBox(0, 0, 0, w, 25, ColorAlpha(main_color, 75*self.alpha));
		if (self:GetText() == "") then
			draw.SimpleText("Поиск", "Raleway 15", 5, 25/2, Color(255, 255, 255, 100), 0, 1);
		end;
		draw.SimpleText(self:GetText(), "Raleway Bold 15", 5, 25/2, Color(255, 255, 255, 255), 0, 1);

		draw.SimpleText("Нажмите `enter` для поиска", "Raleway 11", 1, 27, Color(255, 255, 255, 150), 0, 0);
	end;
	searchField.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	searchField.OnCursorExited = function(self)
		self.Active = false;
	end;
	searchField.OnEnter = function()
		parent.BuildPanel();
	end

	local settings = vgui.Create("DButton", controllPanel);
	settings:SetSize(70, 40);
	settings:SetPos(sizex-70, 0);
	settings:SetText("");
	settings.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);

		draw.RoundedBox(0, 0, 0, w, 25, Color(0, 0, 0, 150 + 105*self.lerp1));

		draw.SimpleText("", "Raleway 11", w/2, 27, ColorAlpha(main_color, 255), 1, 0);
		draw.SimpleText("Настройки", "Raleway Bold 15", w/2, 25/2, ColorAlpha(main_color, 150 - 255*self.lerp1), 1, 1);
		draw.SimpleText("Открыть", "Raleway Bold 15", w/2, 25/2, Color(255, 255, 255, 255*self.lerp1), 1, 1);
	end;
	settings.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	settings.OnCursorExited = function(self)
		self.Active = false;
	end;
	settings.DoClick = function(self)
		core.derma.OpenSettingsMenu()
	end;

	function parent.BuildPanel()
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
			for k, item in pairs(core.storeSelfInventory) do
				if ((item.category or "") != cat) then continue; end;

				local txt_search = string.Replace(searchField:GetText():lower()," ","+.+");
				txt_search = txt_search or "";
				local find_res1, _, _ = string.find(item.name:lower(), txt_search);
				local find_res2, _, _ = string.find(cat:lower(), txt_search);

				if (!find_res1 and !find_res2) then continue; end;
				count = count + 1;
				item._id = k;
				local ditem = core.derma:CreateItem(items, sizex, item, true, isTransfer);
				ditem._search = true;
			end;

			if (count == 0 or !getCats()) then
				category:Remove();
			end;
		end;
	end;
	parent.BuildPanel();

	if (isTransfer) then
		local category = vgui.Create("DPanel", items);
		category:SetSize(sizex, 17);
		category.Paint = function(self, w, h)
			draw.SimpleText("Ожидание", "Raleway Bold 15", 0, h/2, ColorAlpha(main_color, 150), 0, 1);
			surface.SetFont("Raleway Bold 17");
			local w1, _ = surface.GetTextSize("Transfered");
			draw.DashedLine(w1+5, h/2+1, w-w1-5, 2, 3, 5, ColorAlpha(main_color, 150));
		end;
	end;
end;

hook.Add("_angel_sensei.inventory.itemAction", "cl_base", function(data)
	if (!IsValid(core.derma.activeMenu)) then return false; end;
	if (!IsValid(core.derma.activeMenu.transferList)) then return false; end;
	if (data[1]) then return; end;
	local ditem = core.derma:CreateItem(core.derma.activeMenu.transferList, x*inv_size, data[2], true, true, true);
	print(ditem:GetParent());
	timer.Simple(0.1, function()
		core.derma.activeMenu.transferList:GetParent():GetParent():Rebuild();
	end);
end);

function core.derma.createTransferIcons()
	if (!IsValid(core.derma.activeMenu)) then return false; end;
	local main_color = core.config["main_color"];
	local parent = core.derma.activeMenu;

	local panel = vgui.Create("DPanel", parent);
	panel:SetSize(x*inv_align, x*inv_align);
	panel:SetPos(x/2-(x*inv_align)/2, y/2-(x*inv_align)/2);
	panel.Paint = function(self, w, h)
		self.lerp = (self.lerp or 0) + 0.05;
		self.lerp2 = (self.lerp2 or 0) + 0.05;
		if (self.lerp > 1) then self.lerp = -1; end;
		if (self.lerp2 > 1) then self.lerp2 = -0.5; end;

		draw.DashedLine(0, h/2-1, w, 2, 2, 2, Color(255, 255, 255));

		draw.SimpleText("Синхронизирование", "Raleway Bold 17", w/2, h/2-2, main_color, 1, 4);
		draw.SimpleText(".", "Raleway Bold 17", w*self.lerp, h/2+2, Color(255, 255, 255, 150), 0, 0);
		draw.SimpleText(".", "Raleway Bold 17", w*self.lerp2, h/2+2, Color(255, 255, 255, 150), 0, 0);
	end;
end;


function core.derma.Open()
	core.derma.createWindow();
	core.derma.createSelf();
end;

function core.derma.Close()
	if (!IsValid(core.derma.activeMenu)) then return false; end;
	core.derma.activeMenu:Close();
	netstream.Start("_angel_sensei_inventory_unSync");
end;

function core.derma.Toggle()
	if (IsValid(core.derma.activeMenu)) then core.derma.Close(); return false; end;
	core.derma.Open(); return true;
end;

function core.derma.CloseOnConVar()
	if (GetConVar("_angel_sensei_inventory_closeOnUse"):GetBool()) then
		core.derma.Close();
	end;
end;

local toggled = false;
hook.Add("Think", "_angel_sensei.inventory.open", function()	// Menu open
	local keys = {}; 
	for k, v in pairs(core.config["menu_keybind"]) do
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
		core.derma.Toggle();
	elseif (!allPressed and toggled) then
		toggled = false;
	end;
end);

local toggled = false;
hook.Add("Think", "_angel_sensei.inventory.item_pickup", function()
	local keys = {}; 
	for k, v in pairs(core.config["pickup_keybind"]) do
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

		if (entity_item and IsValid(entity_item) and !entity_item:IsPlayer() and entity_item:GetPos():Distance(LocalPlayer():GetPos()) <= core.actionDistance and core:inv_itemIsPickable(entity_item)) then
			netstream.Start("_angel_sensei.inventory.pickUp", entity_item);
		end;
	elseif (!allPressed and toggled) then
		toggled = false;
	end;
end);