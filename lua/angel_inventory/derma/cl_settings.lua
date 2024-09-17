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
	["S"] = "Small",
	["XS"] = "Extra small"
}

local function getSize()
	return GetConVar("_angel_sensei_inventory_size"):GetString();
end;
local function getCats()
	return GetConVar("_angel_sensei_inventory_showCats"):GetBool();
end;
local function getDouble()
	return GetConVar("_angel_sensei_inventory_itemsDouble"):GetFloat();
end;

function core.derma.createSettingsWindow()
	local main_color = core.config["main_color"];
	if (IsValid(core.derma.activeMenu)) then
		core.derma.Close();
	end
	
	core.derma.activeMenu = vgui.Create("DFrame");
	local _frame = core.derma.activeMenu;
	_frame:SetSize(x, y);
	_frame:SetPos(0, 0);
	_frame:SetTitle("");
	_frame:SetDraggable(false);
	_frame:MakePopup();
	_frame:ShowCloseButton(false);
	_frame.startTime = SysTime();
	_frame.Paint = function(self, w, h)
		Derma_DrawBackgroundBlur(self, self.startTime);
		draw.SimpleText(core.config.title, "Raleway ExtraBold 36", w/2, align, Color(main_color.r, main_color.g, main_color.b, 255), 1, 2);
		draw.SimpleText("Настройки", "Raleway ExtraBold 23", w/2, align+36, Color(255, 255, 255, 150), 1, 2);
	end;

	local sizex = x*inv_size
	local item_list = vgui.Create("DScrollPanel", _frame);
	item_list:SetSize(sizex, y - align*3 - 36-23);
	item_list:SetPos(x/2-sizex/2, align*2 + 36+23);
	item_list.Paint = function(self, w, h)
	end;

	local sbar = item_list:GetVBar();
	sbar:SetWide(0);

	local items = vgui.Create("DIconLayout", item_list);
	items:Dock(FILL);
	items:SetSpaceX(10);
	items:SetSpaceY(10);
	items:SetAlpha(0);
	items:AlphaTo(255, 1);
	items.Paint = function(self, w, h)
	end;

	local header = vgui.Create("DPanel", items);
	header:SetSize(sizex, 23);
	header.Paint = function(self, w, h)
		draw.SimpleText("Размер предметов", "Raleway Bold 19", 0, h/2, Color(255, 255, 255, 150), 0, 1);
	end;

	local btn = vgui.Create("DButton", items);
	btn:SetSize(150, 16);
	btn:SetText("");
	btn.size = "XS";
	btn.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);
		draw.RoundedBox(0, 0, 0, 16, 16, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, Color(255, 255, 255, 50+105*self.lerp1-255*((getSize() == self.size) and 1 or 0)));

		draw.SimpleText("Размер "..btn.size, "Raleway Bold 15", 20, h/2, Color(255, 255, 255, 150-150*self.lerp1), 0, 1);
		draw.SimpleText("Размер "..btn.size, "Raleway Bold 15", 20, h/2, ColorAlpha(main_color, 150*self.lerp1), 0, 1);

		if (getSize() == self.size) then
			draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, ColorAlpha(main_color, 150));
		end;
	end;
	btn.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	btn.OnCursorExited = function(self)
		self.Active = false;
	end;
	btn.DoClick = function(self)
		self.Active = false;
		surface.PlaySound("garrysmod/ui_click.wav");
		GetConVar("_angel_sensei_inventory_size"):SetString(self.size);
	end;

	local btn = vgui.Create("DButton", items);
	btn:SetSize(150, 16);
	btn:SetText("");
	btn.size = "S";
	btn.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);
		draw.RoundedBox(0, 0, 0, 16, 16, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, Color(255, 255, 255, 50+105*self.lerp1-255*((getSize() == self.size) and 1 or 0)));

		draw.SimpleText("Размер "..btn.size, "Raleway Bold 15", 20, h/2, Color(255, 255, 255, 150-150*self.lerp1), 0, 1);
		draw.SimpleText("Размер "..btn.size, "Raleway Bold 15", 20, h/2, ColorAlpha(main_color, 150*self.lerp1), 0, 1);

		if (getSize() == self.size) then
			draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, ColorAlpha(main_color, 150));
		end;
	end;
	btn.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	btn.OnCursorExited = function(self)
		self.Active = false;
	end;
	btn.DoClick = function(self)
		self.Active = false;
		surface.PlaySound("garrysmod/ui_click.wav");
		GetConVar("_angel_sensei_inventory_size"):SetString(self.size);
	end;

	local btn = vgui.Create("DButton", items);
	btn:SetSize(150, 16);
	btn:SetText("");
	btn.size = "M";
	btn.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);
		draw.RoundedBox(0, 0, 0, 16, 16, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, Color(255, 255, 255, 50+105*self.lerp1-255*((getSize() == self.size) and 1 or 0)));

		draw.SimpleText("Размер "..btn.size, "Raleway Bold 15", 20, h/2, Color(255, 255, 255, 150-150*self.lerp1), 0, 1);
		draw.SimpleText("Размер "..btn.size, "Raleway Bold 15", 20, h/2, ColorAlpha(main_color, 150*self.lerp1), 0, 1);

		if (getSize() == self.size) then
			draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, ColorAlpha(main_color, 150));
		end;
	end;
	btn.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	btn.OnCursorExited = function(self)
		self.Active = false;
	end;
	btn.DoClick = function(self)
		self.Active = false;
		surface.PlaySound("garrysmod/ui_click.wav");
		GetConVar("_angel_sensei_inventory_size"):SetString(self.size);
	end;

	local header = vgui.Create("DPanel", items);
	header:SetSize(sizex, 23);
	header.Paint = function(self, w, h)
		draw.SimpleText("Показать категории", "Raleway Bold 19", 0, h/2, Color(255, 255, 255, 150), 0, 1);
	end;

	local btn = vgui.Create("DButton", items);
	btn:SetSize(150, 16);
	btn:SetText("");
	btn.action = true;
	btn.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);
		draw.RoundedBox(0, 0, 0, 16, 16, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, Color(255, 255, 255, 50+105*self.lerp1-255*((getCats() == self.action) and 1 or 0)));

		draw.SimpleText("Включить", "Raleway Bold 15", 20, h/2, Color(255, 255, 255, 150-150*self.lerp1), 0, 1);
		draw.SimpleText("Включить", "Raleway Bold 15", 20, h/2, ColorAlpha(main_color, 150*self.lerp1), 0, 1);

		if (getCats() == self.action) then
			draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, ColorAlpha(main_color, 150));
		end;
	end;
	btn.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	btn.OnCursorExited = function(self)
		self.Active = false;
	end;
	btn.DoClick = function(self)
		self.Active = false;
		surface.PlaySound("garrysmod/ui_click.wav");
		GetConVar("_angel_sensei_inventory_showCats"):SetBool(self.action);
	end;

	local btn = vgui.Create("DButton", items);
	btn:SetSize(150, 16);
	btn:SetText("");
	btn.action = false;
	btn.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);
		draw.RoundedBox(0, 0, 0, 16, 16, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, Color(255, 255, 255, 50+105*self.lerp1-255*((getCats() == self.action) and 1 or 0)));

		draw.SimpleText("Отключить", "Raleway Bold 15", 20, h/2, Color(255, 255, 255, 150-150*self.lerp1), 0, 1);
		draw.SimpleText("Отключить", "Raleway Bold 15", 20, h/2, ColorAlpha(main_color, 150*self.lerp1), 0, 1);

		if (getCats() == self.action) then
			draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, ColorAlpha(main_color, 150));
		end;
	end;
	btn.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	btn.OnCursorExited = function(self)
		self.Active = false;
	end;
	btn.DoClick = function(self)
		self.Active = false;
		surface.PlaySound("garrysmod/ui_click.wav");
		GetConVar("_angel_sensei_inventory_showCats"):SetBool(self.action);
	end;

	local header = vgui.Create("DPanel", items);
	header:SetSize(sizex, 23);
	header.Paint = function(self, w, h)
		draw.SimpleText("Столбцы товаров", "Raleway Bold 19", 0, h/2, Color(255, 255, 255, 150), 0, 1);
	end;

	local btn = vgui.Create("DButton", items);
	btn:SetSize(150, 16);
	btn:SetText("");
	btn.action = 1;
	btn.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);
		draw.RoundedBox(0, 0, 0, 16, 16, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, Color(255, 255, 255, 50+105*self.lerp1-255*((getDouble() == self.action) and 1 or 0)));

		draw.SimpleText("Одиночные", "Raleway Bold 15", 20, h/2, Color(255, 255, 255, 150-150*self.lerp1), 0, 1);
		draw.SimpleText("Одиночные", "Raleway Bold 15", 20, h/2, ColorAlpha(main_color, 150*self.lerp1), 0, 1);

		if (getDouble() == self.action) then
			draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, ColorAlpha(main_color, 150));
		end;
	end;
	btn.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	btn.OnCursorExited = function(self)
		self.Active = false;
	end;
	btn.DoClick = function(self)
		self.Active = false;
		surface.PlaySound("garrysmod/ui_click.wav");
		GetConVar("_angel_sensei_inventory_itemsDouble"):SetFloat(self.action);
	end;

	local btn = vgui.Create("DButton", items);
	btn:SetSize(150, 16);
	btn:SetText("");
	btn.action = 2;
	btn.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);
		draw.RoundedBox(0, 0, 0, 16, 16, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, Color(255, 255, 255, 50+105*self.lerp1-255*((getDouble() == self.action) and 1 or 0)));

		draw.SimpleText("Двойные", "Raleway Bold 15", 20, h/2, Color(255, 255, 255, 150-150*self.lerp1), 0, 1);
		draw.SimpleText("Двойные", "Raleway Bold 15", 20, h/2, ColorAlpha(main_color, 150*self.lerp1), 0, 1);

		if (getDouble() == self.action) then
			draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, ColorAlpha(main_color, 150));
		end;
	end;
	btn.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	btn.OnCursorExited = function(self)
		self.Active = false;
	end;
	btn.DoClick = function(self)
		self.Active = false;
		surface.PlaySound("garrysmod/ui_click.wav");
		GetConVar("_angel_sensei_inventory_itemsDouble"):SetFloat(self.action);
	end;

	local btn = vgui.Create("DButton", items);
	btn:SetSize(150, 16);
	btn:SetText("");
	btn.action = 3;
	btn.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);
		draw.RoundedBox(0, 0, 0, 16, 16, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, Color(255, 255, 255, 50+105*self.lerp1-255*((getDouble() == self.action) and 1 or 0)));

		draw.SimpleText("Только иконки", "Raleway Bold 15", 20, h/2, Color(255, 255, 255, 150-150*self.lerp1), 0, 1);
		draw.SimpleText("Только иконки", "Raleway Bold 15", 20, h/2, ColorAlpha(main_color, 150*self.lerp1), 0, 1);

		if (getDouble() == self.action) then
			draw.RoundedBox(0, 4-math.floor(4*self.lerp1), 4-math.floor(4*self.lerp1), 8+8*self.lerp1, 8+8*self.lerp1, ColorAlpha(main_color, 150));
		end;
	end;
	btn.OnCursorEntered = function(self)
		surface.PlaySound("garrysmod/ui_hover.wav");
		self.Active = true;
	end;
	btn.OnCursorExited = function(self)
		self.Active = false;
	end;
	btn.DoClick = function(self)
		self.Active = false;
		surface.PlaySound("garrysmod/ui_click.wav");
		GetConVar("_angel_sensei_inventory_itemsDouble"):SetFloat(self.action);
		GetConVar("_angel_sensei_inventory_size"):SetString("M");
	end;
end;

function core.derma.OpenSettingsMenu()
	core.derma.createSettingsWindow();
end;

function core.derma.CloseSettingsMenu()
	if (!IsValid(core.derma.activeMenu)) then return false; end;
	core.derma.activeMenu:Close();
end;

concommand.Add("test", function() core.derma.OpenSettingsMenu() end);