
--request
local tGameFileLoad = {
"client.src.plaza.views.layer.GameCpp/gameInterface",
"client.src.plaza.views.layer.GameCpp/gameEventIDDefine",
"client.src.plaza.views.layer.GameCpp/gameNotificationMgr",
"client.src.plaza.views.layer.GameCpp/gameCommonUi",
"client.src.plaza.views.layer.GameCpp/gameMatchInterface",
--"client.src.plaza.views.layer.GameCpp/serverItemEventSocket",
"client.src.plaza.views.layer.GameCpp/gamePrivateCommonUi",
"client.src.plaza.views.layer.GameCpp/newgamePrivateCommonUi",
"client.src.plaza.views.layer.GameCpp/matchcommonUI"
}


function RequireGameuaFile()
	for k,v in pairs(tGameFileLoad) do
		require(v)
	end
end

RequireGameuaFile()


function UnloadGameLuaFile()
	for k,v in pairs(tGameFileLoad) do
		local tModel = ds.common.split(v,"/")
		if (_G[tModel[#tModel]] ~= nil) then
			_G[tModel[#tModel]] = nil
			package.loaded[tModel[#tModel]] = nil
		end
		package.loaded[v] = nil
	end
end