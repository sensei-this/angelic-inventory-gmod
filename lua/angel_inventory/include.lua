// Global vars
local _angel_sensei = _angel_sensei or {};
_angel_sensei.inventory = _angel_sensei.inventory or {};
local core = _angel_sensei.inventory;

function core:cl_include(folder, filename)
	folder = folder and folder.."/" or "";
	local fullPath = core.dir.."/"..folder..filename..(string.sub(filename, -4) != ".lua" and ".lua" or "");
	if (!file.Exists(fullPath, "LUA")) then core:Error("File `"..filename.."` in folder `"..folder.."` doesn't exists!"); return false; end;
	if (SERVER) then
		AddCSLuaFile(fullPath);
	else
		include(fullPath);
	end;
end;

function core:sh_include(folder, filename)
	folder = folder and folder.."/" or "";
	local fullPath = core.dir.."/"..folder..filename..(string.sub(filename, -4) != ".lua" and ".lua" or "");
	if (!file.Exists(fullPath, "LUA")) then core:Error("File `"..filename.."` in folder `"..folder.."` doesn't exists!"); return false; end;
	if (SERVER) then
		AddCSLuaFile(fullPath);
	end;
	
	include(fullPath);
end;

function core:sv_include(folder, filename)
	if (CLIENT) then return; end;
	folder = folder and folder.."/" or "";
	local fullPath = core.dir.."/"..folder..filename..(string.sub(filename, -4) != ".lua" and ".lua" or "");
	if (!file.Exists(fullPath, "LUA")) then core:Error("File `"..filename.."` in folder `"..folder.."` doesn't exists!"); return false; end;

	include(fullPath);
end;

function core:folder_include(folder)
	if (SERVER && !file.IsDir(core.dir.."/"..folder, "LUA")) then core:Error("Folder `"..folder.."` doesn't exists!"); return false; end;
	for k, v in pairs(file.Find(core.dir.."/"..folder.."/*.lua", "LUA")) do
		if (string.sub(v, 1, 3) == "cl_") then
			self:cl_include(folder, v);
		elseif (string.sub(v, 1, 3) == "sh_") then
			self:sh_include(folder, v);
		elseif (string.sub(v, 1, 3) == "sv_") then
			self:sv_include(folder, v);
		end;
	end;
end;