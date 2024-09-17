// Global vars
local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;
core.derma = core.derma or {};

local function getSize()
	return GetConVar("_angel_sensei_inventory_size"):GetString();
end;
local function getDouble()
	return GetConVar("_angel_sensei_inventory_itemsDouble"):GetFloat();
end;

local sizes = {
	XS = 32,
	S = 40,
	M = 52
}
local color_white = Color(255, 255, 255);

function core.derma:CreateItem(parent, sizex, itemTable, is_self, isTransfer, newItem)
	if (getDouble() == 2) then
		sizex = (sizex-14)/2;
	elseif (getDouble() == 3) then
		sizex = sizes[getSize()];
	end; 
	itemTable = itemTable or {};
	local main_color = core.config["main_color"];
	local item = vgui.Create("DButton", parent);
	item:SetSize(sizex, sizes[getSize()]);
	item.size = sizes[getSize()];
	item.itemTable = itemTable;
	item:SetText("")
	item.newItem = newItem;
	item.Paint = function(self, w, h)
		self.lerp1 = Lerp(FrameTime()*5, self.lerp1 or 0, self.Active and 1 or 0);
		self.lerp2 = Lerp(FrameTime()*2, self.lerp2 or (self.newItem and 1 or 0), 0);

		fontSize = self.size == 52 and 2 or 0;
		draw.RoundedBox(0, 0, 0, w*self.lerp1, h, Color(0, 0, 0, 150*self.lerp1));
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100));

		draw.RoundedBox(0, 0, 0, self.size, self.size, Color(0, 0, 0, 150));
		draw.RoundedBox(0, 0, 0, self.size, self.size, ColorAlpha(main_color, 255*self.lerp2));
		if (getSize() == "XS") then
			draw.SimpleText(self.itemTable.name, "Raleway Bold 15", self.size + 5, 0, ColorAlpha(main_color, 255-255*self.lerp1), 0, 0);
			draw.SimpleText(self.itemTable.name, "Raleway Bold 15", self.size + 5, 0, ColorAlpha(color_white, 255*self.lerp1), 0, 0);

			draw.SimpleText("Вес: ", "Raleway Bold 13", self.size + 5, 15, ColorAlpha(color_white, 50+105*self.lerp1), 0, 0);
			surface.SetFont("Raleway Bold 13");
			local w1, _ = surface.GetTextSize("Вес: ");
			draw.SimpleText(self.itemTable.weight.." кг" or "0.0 кг", "Raleway Bold 13", self.size + 5 + w1, 15, ColorAlpha(color_white, 50+105*self.lerp1), 0, 0);
		elseif (getSize() == "S") then
			draw.SimpleText(self.itemTable.name, "Raleway Bold 15", self.size + 5, 0, ColorAlpha(main_color, 255-255*self.lerp1), 0, 0);
			draw.SimpleText(self.itemTable.name, "Raleway Bold 15", self.size + 5, 0, ColorAlpha(color_white, 255*self.lerp1), 0, 0);
			draw.SimpleText(self.itemTable.description or "Item description", "Raleway 13", self.size + 5, 15, Color(255, 255, 255, 150), 0, 0);
			
			draw.SimpleText("Вес: ", "Raleway 13", self.size + 5, 15+13, ColorAlpha(color_white, 50+105*self.lerp1), 0, 0);
			surface.SetFont("Raleway Bold 13");
			local w1, _ = surface.GetTextSize("Вес: ");
			draw.SimpleText(self.itemTable.weight.." кг" or "0.0 кг", "Raleway 13", self.size + 5 + w1, 15+13, ColorAlpha(color_white, 50+105*self.lerp1), 0, 0);
		else
			draw.SimpleText(self.itemTable.name, "Raleway Bold 17", self.size + 5, 0, ColorAlpha(main_color, 255-255*self.lerp1), 0, 0);
			draw.SimpleText(self.itemTable.name, "Raleway Bold 17", self.size + 5, 0, ColorAlpha(color_white, 255*self.lerp1), 0, 0);
			draw.SimpleText(self.itemTable.description or "Item description", "Raleway 15", self.size + 5, 17, Color(255, 255, 255, 150), 0, 0);
			
			draw.SimpleText("Вес: ", "Raleway 13", self.size + 5, 17+15, ColorAlpha(color_white, 50+105*self.lerp1), 0, 0);
			surface.SetFont("Raleway Bold 13");
			local w1, _ = surface.GetTextSize("Вес: ");
			draw.SimpleText(self.itemTable.weight.." кг" or "0.0 кг", "Raleway 13", self.size + 5 + w1, 17+15, ColorAlpha(color_white, 50+105*self.lerp1), 0, 0);
		end
		/*
		draw.SimpleText(self.itemTable.name or "Item name", "Raleway Bold "..(15+fontSize), self.size + 5, 0, ColorAlpha(main_color, 255-255*self.lerp1), 0, 0);
		draw.SimpleText(self.itemTable.name or "Item name", "Raleway Bold "..(15+fontSize), self.size + 5, 0, Color(255, 255, 255, 255*self.lerp1), 0, 0);
		draw.SimpleText(self.itemTable.description or "Item description", "Raleway "..(13+fontSize), self.size + 5, (15+fontSize), Color(255, 255, 255, 150), 0, 0);
		draw.SimpleText("Вес: ", "Raleway Bold "..(13+fontSize), self.size + 5, (13+fontSize) + (15+fontSize), Color(255, 255, 255, 150-150*self.lerp1), 0, 0);
		draw.SimpleText("Вес: ", "Raleway Bold "..(13+fontSize), self.size + 5, (13+fontSize) + (15+fontSize), ColorAlpha(main_color, 255*self.lerp1), 0, 0);

		surface.SetFont("Raleway Bold "..(13+fontSize));
		local w1, _ = surface.GetTextSize("Вес: ");

		draw.SimpleText(self.itemTable.weight.." кг" or "0.0 кг", "Raleway Bold "..(13+fontSize), self.size + 5 + w1, (13+fontSize) + (15+fontSize), main_color, 0, 0);
		*/
	end;
	item.OnCursorEntered = function(self)
		if (!self.Active) then surface.PlaySound("garrysmod/ui_hover.wav"); end;
		self.Active = true;
	end;
	item.OnCursorExited = function(self)
		self.Active = false;
	end;
	item.DoClick = function(self)
		if (!isTransfer) then return; end;
		//if (core.syncInfo.action == "storage") then
		if (!self.itemTable.in_store) then
			if (self.itemTable.weight > (core.syncInfo.maxWeight - core:inv_invGetSyncWeight())) then
				surface.PlaySound("buttons/weapon_cant_buy.wav");
				return;
			end;
		else
			if (self.itemTable.weight > (core.storeSelfInventoryData.weight_max-core:inv_invGetSelfWeight())) then
				surface.PlaySound("buttons/weapon_cant_buy.wav");
				return;
			end;
		end;
		netstream.Start("_angel_sensei.inventory.itemAction", {"store_action", self.itemTable._id});
		//end;

		self:Remove();

		self.itemTable.in_store = !self.itemTable.in_store;
		hook.Call("_angel_sensei.inventory.itemAction", GAMEMODE, {is_self, self.itemTable});
		surface.PlaySound("garrysmod/ui_click.wav");
	end;
	item.DoRightClick = function(self)
		if (!is_self) then return; end;
		if (isTransfer) then return; end;
		local base = core:inv_itemGetBase(self.itemTable.base_id);
		local actionMenu = DermaMenu()
		actionMenu:AddCVar("Закрыть меню при использовании", "_angel_sensei_inventory_closeOnUse", "1", "0");
		actionMenu:AddSpacer();
		actionMenu:AddOption("Выбросить", function() 
			self:Remove();
			netstream.Start("_angel_sensei.inventory.itemAction", {"drop", self.itemTable._id});
			core.derma.CloseOnConVar(); 
		end);
		if ((base and base.canUse or false) or self.itemTable.base_id == "spawned_weapon" or self.itemTable.base_id == "spawned_food") then
			actionMenu:AddOption("Использовать", function() 
				self:Remove();
				netstream.Start("_angel_sensei.inventory.itemAction", {"use", self.itemTable._id});
				core.derma.CloseOnConVar(); 
			end);
		end;
		if (base and base.canDestroy or false) then
			actionMenu:AddOption("Удалить", function() 
				self:Remove();
				netstream.Start("_angel_sensei.inventory.itemAction", {"destroy", self.itemTable._id});
				core.derma.CloseOnConVar(); 
			end);
		end;
		actionMenu:Open();
	end;

	item.icon = vgui.Create("ModelImage", item);
	item.icon:SetSize(item.size-6, item.size-6);
	item.icon:SetPos(3, 3);
	item.icon:SetCursor("hand");
	item.icon:SetModel(itemTable.model or "models/props_junk/cardboard_box004a.mdl", 1, "000000000");

	item.upper = vgui.Create("DButton", item);
	item.upper:SetSize(item.size-6, item.size-6);
	item.upper:SetPos(3, 3);
	item.upper:SetText("");
	item.upper.Paint = function(self, w, h) end;
	item.upper.OnCursorEntered = function(self)
		self:GetParent():OnCursorEntered();
	end;
	item.upper.OnCursorExited = function(self)
		self:GetParent():OnCursorExited();
	end;
	item.upper.DoClick = function(self)
		self:GetParent():DoClick();
	end;
	item.upper.DoRightClick = function(self)
		self:GetParent():DoRightClick();
	end;
	item.upper:SetTooltip(item.itemTable.name.."\n"..item.itemTable.description.."\nВес:"..item.itemTable.weight.." кг");

	return item;
end;
