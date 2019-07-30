
module("DSResouresMgr", package.seeall)


--加载游戏的lua脚本
function RequireLuaResoures(GameId)
	
	local strGameResourceRoot = ds.CPlatformGameConfig:shared():getValue(GameId,"game_resource")
	local filePath = strGameResourceRoot.."/lua_resource.plist"
	local plistFile = cc.FileUtils:getInstance():fullPathForFilename(filePath)  
  	local tableLuaResources = cc.FileUtils:getInstance():getValueVectorFromFile(plistFile)
	
	for i = 1, #tableLuaResources do
		require(tableLuaResources[i])
	end
end


--卸载游戏的lua脚本
function DeleteLuaResoures(GameId)
	
	--得到游戏模块的名字
	local strDeleteLuaModule = ds.CPlatformGameConfig:shared():getValue(GameId,"game_lua_module")
	if strDeleteLuaModule == nil or strDeleteLuaModule == "" then
		return
	end
	
	--卸载相应的游戏模块
	if (_G[strDeleteLuaModule] ~= nil) then
		_G[strDeleteLuaModule] = nil
		
		package.loaded[strDeleteLuaModule] = nil
	end
	
	--卸载掉相应的lua脚本
	local strGameResourceRoot = ds.CPlatformGameConfig:shared():getValue(GameId,"game_resource")
	local filePath = strGameResourceRoot.."/lua_resource.plist"
	local plistFile = cc.FileUtils:getInstance():fullPathForFilename(filePath)  
  	local tableLuaResources = cc.FileUtils:getInstance():getValueVectorFromFile(plistFile)
	
	for i = 1, #tableLuaResources do
		package.loaded[tableLuaResources[i]] = nil
	end
end
