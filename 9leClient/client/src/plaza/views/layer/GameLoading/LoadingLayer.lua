module("LoadingLayer", package.seeall)

ds = ds or {}
ds.common = {}

ds.common.ConvertFunc = function(strFunc, ...)
	local nPoint = string.find(strFunc, "%.")
	if nPoint == nil then
		return _G[strFunc]
	else
		local strModuleName = string.sub(strFunc, 1, nPoint-1)
		local strName = string.sub(strFunc, nPoint+1)
		local module = _G[strModuleName]	
		if module ~= nil then
			local mPoint = string.find(strName, "%:")
			if (mPoint == nil) then
				return module[strName]
			else
				local strClassName = string.sub(strName, 1, mPoint-1)
				local strFuncName = string.sub(strName, mPoint+1)
				if (type(module[strClassName]) == "table") then
					return module[strClassName][strFuncName]
				else
					return nil
				end
				
			end
		end
	end
end

local GameLoading = {
	mLayer_UI = nil,
	mLoading = nil,
	mImg_Head = nil,
	mGameId = 0,
	mNowLoadResourseName = nil,
	mFunc = "",
	mOld_posX = 0,
	mOld_posY = 0,
	mSchedulerID = nil,
	mResources = {},
	mFrame_cur = 0,
	mFrame_Load = 10,
	mLoading_Light_Width = 20,
  	mSchedulerDeleteID = nil,
}
local mloadingLayer = nil

function GameLoading:create()  
	local instance = {}

	setmetatable(instance, self)
	self.__index = self
	return instance
end

function GameLoading:Init()

	local needLoadingPage = ds.CPlatformGameConfig:shared():getValue(self.mGameId,"loading_page_show")
	if (needLoadingPage == "") then 
    --不需要loading界面去预加载游戏资源
		if (self.mFunc ~= "") then
	    	ds.common.ConvertFunc(self.mFunc)()
	    end
	else
    	self:setUpdateView()
	end

end

--初始化组件
function GameLoading:setUpdateView()

	local function onNodeEvent(event)
        if event == "enter" then
            self:onEnterTransitionDidFinish()
        end
    end
    
	self.mLayer_UI = DSBaseLayer.initWithJsonFile("GameLoadingLayer","PlatForm/GameLoadingLayer.json")
    self.mLayer_UI:setContentSize(1280,720) --这个是资源设计尺寸
	self.mLayer_UI:setScale(yl.WIDTH / 1280 + 0.04);
	self.mLayer_UI:registerScriptHandler(onNodeEvent)
	
	
    self.mLoading = self.mLayer_UI:seekWidgetByNameOfRoot("pb_loading")
    self.mImg_Head = self.mLayer_UI:seekWidgetByNameOfRoot("img_head")
    local bgImage = self.mLayer_UI:seekWidgetByNameOfRoot("Image_1")
    local fileName = ds.CPlatformGameConfig:shared():getValue(self.mGameId,"loading_page_background")
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
    	self.mLayer_UI:setScale(1)
    	fileName = "dntg/GameLoading/pc3.jpg"
    end
    bgImage:loadTexture(fileName, ccui.TextureResType.localType)

    self.mOld_posX, self.mOld_posY = self.mImg_Head:getPosition()

    local scheduler = cc.Director:getInstance():getScheduler()
    if (self.mSchedulerID ~= nil) then
        scheduler:unscheduleScriptEntry(self.mSchedulerID)
        self.mSchedulerID = nil
    end

    self.mSchedulerID = scheduler:scheduleScriptFunc(function()
        self:checkComeIn()
    end,30, false)
end


function GameLoading:checkComeIn()
	--是否有游戏界面，有的话就关闭游戏界面
	if (self.mLayer_UI ~= nil) then
		self.mLayer_UI:Close()
	end
end

function GameLoading:onEnterTransitionDidFinish()
	
	--释放图片
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	
	--释放此前加载的路径
	ds.Game_Path_Manager:purge()

	local filePath = self.mNowLoadResourseName.."/resources.plist" --"game/yule/dntg/res/dntgGameScene/" .. 
	local plistFile = cc.FileUtils:getInstance():fullPathForFilename(filePath)  
  	self.mResources = cc.FileUtils:getInstance():getValueVectorFromFile(plistFile)

  	self.mTime = 0
  	self.mFrame_cur = self.mFrame_Load
  	local mLoadedNum = 0
  	local mTotalNum = #self.mResources
  	local function update(interval)
  		if (self.mFrame_cur >= self.mFrame_Load) then
  			self.mFrame_cur = 0
  			if (mLoadedNum < mTotalNum) then
  				local sPlist = self.mResources[mLoadedNum + 1]..".plist"
  				cc.SpriteFrameCache:getInstance():addSpriteFrames(sPlist)

  				mLoadedNum = mLoadedNum + 1
  			end
  		else
  			self.mFrame_cur = self.mFrame_cur + 1
  		end

  		local pos_x = self.mOld_posX
  		local Xdistance = (self.mLoading:getContentSize().width - self.mLoading_Light_Width)/mTotalNum
  		
  		pos_x = pos_x + Xdistance*(mLoadedNum)
  		if (mTotalNum > 0 and ((mLoadedNum)*100/mTotalNum) > 10) then
  			self.mImg_Head:setPositionX(pos_x)
  			self.mLoading:setPercent((mLoadedNum)*100/mTotalNum)
  		end

  		cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
  		
  		if (mLoadedNum < mTotalNum) then
  			return
  		end
		
  		self.mLayer_UI:unscheduleUpdate()
		
  		ds.SpriteHelper:cacheAnimations(self.mNowLoadResourseName)


  		local have_path = ds.CPlatformGameConfig:shared():getValue(self.mGameId,"loading_page_have_path")
  		if (have_path ~= "") then
  			local filePath = self.mNowLoadResourseName.."/resources_path.plist"
  			ds.Game_Path_Manager:shared():initialise_paths(filePath)
  		end

  		if (self.mFunc ~= "") then
	    	ds.common.ConvertFunc(self.mFunc)()
	    end
  	end

  	self.mLayer_UI:scheduleUpdateWithPriorityLua(update, 0)
end

function GameLoading:removeFromParent()
	
	local scheduler = cc.Director:getInstance():getScheduler()
    if (self.mSchedulerID ~= nil) then
        scheduler:unscheduleScriptEntry(self.mSchedulerID)
        self.mSchedulerID = nil
    end
	
	if (self.mSchedulerDeleteID ~= nil) then
		scheduler:unscheduleScriptEntry(self.mSchedulerDeleteID)	
		self.mSchedulerDeleteID = nil
	end
	
	self.mSchedulerDeleteID = scheduler:scheduleScriptFunc(function()
		if (self.mLayer_UI ~= nil) then
			AudioEngine.stopMusic()
			mloadingLayer.mLayer_UI:Close()
		end
		scheduler:unscheduleScriptEntry(self.mSchedulerDeleteID)
		self.mSchedulerDeleteID = nil
	 end, 0.03, false)
end

function create(wGameId, func)
	mloadingLayer = GameLoading:create()
	mloadingLayer.mFunc = func
    
	mloadingLayer.mGameId = wGameId
	mloadingLayer.mNowLoadResourseName = ds.CPlatformGameConfig:shared():getValue(wGameId,"game_resource")
    mloadingLayer:Init()

    if (mloadingLayer.mLayer_UI ~= nil) then
    	mloadingLayer.mLayer_UI:Run(nil, 999)
    end

    return mloadingLayer
end

function destroyResource(wGameId)
	
	local needLoadingPage = ds.CPlatformGameConfig:shared():getValue(wGameId,"loading_page_show")
	if (needLoadingPage ~= "") then
		
		--释放没有使用的纹理	
		cc.Director:getInstance():getTextureCache():removeUnusedTextures()
		
		--释放已经加载的精灵
		local loadResourseName = ds.CPlatformGameConfig:shared():getValue(wGameId,"game_resource")
		local filePath = loadResourseName.."/resources.plist"
		local plistFile = cc.FileUtils:getInstance():fullPathForFilename(filePath)
		local Resources = cc.FileUtils:getInstance():getValueVectorFromFile(plistFile)
		for i = 1,#Resources do
			local sPlist = Resources[i]..".plist"
  			cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(sPlist)
		end
		
		--释放动画资源
		ds.SpriteHelper:removeAnimations(loadResourseName)
		
		--释放记载的路径
		ds.Game_Path_Manager:purge()
	end
end