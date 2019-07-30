
module("DSLayerMgr", package.seeall)

local tBaseLayer = {}
local mPlatformScene = nil

function AddNewLayer(layer, index)
    if layer ~= nil and type(index) == "string" then
        tBaseLayer[index] = layer
    end
end

function DeleteLayer(index)
    if type(index) == "string" then
        if (tBaseLayer[index] ~= nil) then
            tBaseLayer[index] = nil
        end
    end
end

function SearchLayer(index)
    local layer = nil
    if type(index) == "string" then
       for k,v in pairs(tBaseLayer) do
            if (k == index) then
                layer = v
                break
            end
       end
    end

    return layer
end

function IsHaveLayerByIndex(index)
    local isExist = false
    if type(index) == "string" then
        for k,v in pairs(tBaseLayer) do
            if (k == index) then
                isExist = true
                break
            end
       end
    end
    return isExist
end

function setPlatformScene(scene)
    mPlatformScene = scene
end

function changeModeLayer(isHide)
    if (IsHaveLayerByIndex("HallLayer")) then
        tBaseLayer["HallLayer"]:setVisible(isHide)
        tBaseLayer["HallLayer"]:setTouchEnabled(isHide)
    end

    if (IsHaveLayerByIndex("RoomLayer")) then
        tBaseLayer["RoomLayer"]:setVisible(isHide)
        tBaseLayer["RoomLayer"]:setTouchEnabled(isHide)
    end

    if (IsHaveLayerByIndex("RoomListLayer")) then
        tBaseLayer["RoomListLayer"]:Close()
        -- tBaseLayer["RoomListLayer"]:setVisible(isHide)
        -- tBaseLayer["RoomListLayer"]:setTouchEnabled(isHide)
    end
end

function modeSelectedNotify(selectMode)
    local mDefaultModeSelected = selectMode
    if (mDefaultModeSelected == 0) then --快速模式 
        local pServerListData = ds.CServerListData:shared() 
        local GameServerCount = pServerListData:GetGameServerCount()
        local servers = {}
        for i = 0, GameServerCount - 1 do
            local GameServerItem = pServerListData:SearchGameServerByIndex(i):GetGameServer()
            local severName = GameServerItem:getServerName()

            local elems = ds.common.split(severName, '|')
            local iServerType = 0
            local iType = 0
            local iRate = 0
            if (#elems > 3) then
                iServerType = elems[2]
                iType = elems[3]
                iRate = elems[4]
            end

            if (iRate == 0) then
                iRate = 1
            end

            if ((iType == 1 and iRate == 1) or (iType == 0)) then
                table.insert(servers, GameServerItem)
            end
        end

        if (#servers == 0) then
            DSDialogLayer.create(ds.Dialog.Type.NONEBUTTON,ds.StringData:shared():stringFromKey("none_quick_mode_room"),ds.StringData:shared():stringFromKey("system_tips_title"))
            return
        end

        local iRandIndex = math.random() % (#servers)

        --G_NOTIFY_D("CONNECT_SERVER", MTData::create(0, 0, 0, "", "", "", servers[iRandIndex])); 

    elseif (mDefaultModeSelected == 1) then
        if (mPlatformScene == nil) then
            ds.log("mPlatformScene is not isExist")
            return
        end
        local now_Scene = cc.Director:getInstance():getRunningScene() 
        if (now_Scene == mPlatformScene) then
            ds.log("this scene is PlatFormScene")
            changeModeLayer(true)
            return 
        end
		DSWaitingLayer.dismiss()
        changeModeLayer(true)
        --删除弹出的提示框
        --DSDialogLayer.DeleteTipsDialog()
        if (now_Scene ~= nil) then
            cc.Director:sharedDirector():replaceScene(mPlatformScene)
        else
            cc.Director:sharedDirector():runWithScene(mPlatformScene)
        end

        ds.common.playBackMusic()
        
    elseif (mDefaultModeSelected == 2) then
        DSDialogLayer.create(ds.Dialog.Type.NONEBUTTON,ds.StringData:shared():stringFromKey("none_match_mode_room"),ds.StringData:shared():stringFromKey("system_tips_title"))
        return
    end
end

-- function connectServerNotify(data)
--     if (data == 0) then
--         return
--     end

--     if (mPlatformScene == nil) then
--         ds.log("mPlatformScene is not isExist")
--         return
--     end
--     local now_Scene = cc.Director:getInstance():getRunningScene() 
--     if (now_Scene == mPlatformScene) then
--         return
--     else
--         cc.Director:sharedDirector():replaceScene(cc.TransitionFade:create(0.5, mPlatformScene))
--     end
-- end

-- function backToServerListNofity(data)

-- end


