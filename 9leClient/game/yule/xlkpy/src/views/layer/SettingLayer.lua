--
-- Author: tom
-- Date: 2017-02-27 17:26:42
--
local SetLayer = class("SetLayer", function(scene)
	local setLayer = display.newLayer()
	return setLayer
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
--local cmd = appdf.req(appdf.GAME_SRC.."yule.oxnew.src.models.CMD_Game")

local TAG_BT_MUSICON = 1
local TAG_BT_MUSICOFF = 2
local TAG_BT_EFFECTON = 3
local TAG_BT_EFFECTOFF = 4
local TAG_BT_EXIT = 5

SetLayer.RES_PATH 	= "game/yule/xlkpy/res/game/"
function SetLayer:onInitData()
end

function SetLayer:onResetData()
end

local this
function SetLayer:ctor(scene)
	this = self
	self._scene = scene
	self.bgSelect = nil
	self:onInitData()

	self.colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 125))
		:setContentSize(display.width, display.height)
		:addTo(self)
	self.colorLayer:setTouchEnabled(false)
	self.colorLayer:registerScriptTouchHandler(function(eventType, x, y)
		return this:onTouch(eventType, x, y)
	end)

	local funCallback = function(ref)
		this:onButtonCallback(ref:getTag(), ref)
	end
	--UI
	self._csbNode = cc.CSLoader:createNode(SetLayer.RES_PATH.."SetLayer.csb")
		:addTo(self, 1)
	self.btMusicOn = self._csbNode:getChildByName("bt_music_on")
		:setTag(TAG_BT_MUSICON)
	self.btMusicOn:addClickEventListener(funCallback)
	self.btMusicOff = self._csbNode:getChildByName("bt_music_off")
		:setTag(TAG_BT_MUSICOFF)
	self.btMusicOff:addClickEventListener(funCallback)
	self.btEffectOn = self._csbNode:getChildByName("bt_effect_on")
		:setTag(TAG_BT_EFFECTON)
	self.btEffectOn:addClickEventListener(funCallback)
	self.btEffectOff = self._csbNode:getChildByName("bt_effect_off")
		:setTag(TAG_BT_EFFECTOFF)
	self.btEffectOff:addClickEventListener(funCallback)
	local btnClose = self._csbNode:getChildByName("bt_close")
		:setTag(TAG_BT_EXIT)
	btnClose:addClickEventListener(funCallback)
	self.sp_layerBg = self._csbNode:getChildByName("sp_setLayer_bg")
	--声音
	self.btMusicOn:setVisible(GlobalUserItem.bVoiceAble)
	self.btMusicOff:setVisible(not GlobalUserItem.bVoiceAble)
	self.btEffectOn:setVisible(GlobalUserItem.bSoundAble)
	self.btEffectOff:setVisible(not GlobalUserItem.bSoundAble)
	
	if GlobalUserItem.bVoiceAble then
		AudioEngine.playMusic("sound/bg1.mp3", true)
	end

--	for i=1,4 do
--		local bgBtn = self._csbNode:getChildByName("btn_bg"..i)
--		bgBtn:setTag(100 + i)
--		bgBtn:addClickEventListener(funCallback)
--		if i == 1 then
--			self:addSelectBg(bgBtn)
--		end
--		--print(i)
--	end

--	local cbtlistener = function (sender,eventType)
--        self:onSelectedEvent(sender:getTag(),sender)
--    end
--	self.m_tabCheckBox = {}
--    -- 背景音乐
--    for i = 1, 3 do
--        local checkbx = self._csbNode:getChildByName("check_yinyue" .. i)
--        checkbx:setTag(1000 + i )
--        checkbx:addEventListener(cbtlistener)
--        checkbx:setSelected(false)
--        self.m_tabCheckBox[1000 + i] = checkbx

--    end
--    local checkbx1 = self._csbNode:getChildByName("check_yinyue1")
--    checkbx1:setSelected(true)

    if cc.UserDefault:getInstance():getBoolForKey("soundable",true) == true then
    	self.btMusicOn:setVisible(true)
        self.btMusicOff:setVisible(false)
    else
        self.btMusicOn:setVisible(false)
        self.btMusicOff:setVisible(true)
    end

    if cc.UserDefault:getInstance():getBoolForKey("bVoiceAble",true) == true then
		self.btEffectOn:setVisible(true)
		self.btEffectOff:setVisible(false)
    else
		self.btEffectOn:setVisible(false)
		self.btEffectOff:setVisible(true)
    end

--	--版本号
--	local textVersion = self._csbNode:getChildByName("Text_version")
--	local mgr = self._scene._scene._scene:getApp():getVersionMgr()
--	local nVersion = mgr:getResVersion(cmd.KIND_ID) or "0"
--	local strVersion = "游戏版本："..appdf.BASE_C_VERSION.."."..nVersion
--	textVersion:setString(strVersion)

	self:setVisible(false)
end
function SetLayer:onSelectedEvent(tag, sender)
	ExternalFun.playClickEffect()
    if self.m_nSelectIdx == tag then
        sender:setSelected(true)
        return
    end
    self.m_nSelectIdx = tag
    print("背景ying = "..self.m_nSelectIdx)
    
    for k,v in pairs(self.m_tabCheckBox) do
        if k ~= tag then
            v:setSelected(false)
        end
    end
end
function SetLayer:addSelectBg(node)
	if self.bgSelect ~= nil then
		self.bgSelect:removeFromParent()
		self.bgSelect = nil
	end
	self.bgSelect = ccui.ImageView:create()
	self.bgSelect:loadTexture(SetLayer.RES_PATH.."set_seclete.png")
	self.bgSelect:setPosition(cc.p(node:getContentSize().width/2,node:getContentSize().height/2))
	node:addChild(self.bgSelect)
end
function SetLayer:onButtonCallback(tag, ref)
	ExternalFun.playClickEffect()
	if tag == TAG_BT_MUSICON then
		print("音乐状态本开")
		GlobalUserItem.setVoiceAble(false)
		self.btMusicOn:setVisible(false)
		self.btMusicOff:setVisible(true)
        cc.UserDefault:getInstance():setBoolForKey("soundable",false)
	elseif tag == TAG_BT_MUSICOFF then
		print("音乐状态本关")
		GlobalUserItem.setVoiceAble(true)
		self.btMusicOn:setVisible(true)
		self.btMusicOff:setVisible(false)
        cc.UserDefault:getInstance():setBoolForKey("soundable",true)
		ExternalFun.playBackgroudAudio("LOAD_BACK.mp3")
	elseif tag == TAG_BT_EFFECTON then
		print("音效状态本开")
		GlobalUserItem.setSoundAble(false)
		self.btEffectOn:setVisible(false)
		self.btEffectOff:setVisible(true)
        cc.UserDefault:getInstance():setBoolForKey("bVoiceAble",false)
	elseif tag == TAG_BT_EFFECTOFF then
		print("音效状态本关")
		GlobalUserItem.setSoundAble(true)
		self.btEffectOn:setVisible(true)
		self.btEffectOff:setVisible(false)
        cc.UserDefault:getInstance():setBoolForKey("bVoiceAble",true)
	elseif tag == TAG_BT_EXIT then
		print("离开")
		self:hideLayer()
	else
		self._scene:setBgView(tag - 100)
		self:addSelectBg(ref)
	end
end

function SetLayer:onTouch(eventType, x, y)
	if eventType == "began" then
		return true
	end

	local pos = cc.p(x, y)
    local rectLayerBg = self.sp_layerBg:getBoundingBox()
    if not cc.rectContainsPoint(rectLayerBg, pos) then
    	self:hideLayer()
    end

    return true
end

function SetLayer:showLayer()
	self.colorLayer:setTouchEnabled(true)
	self:setVisible(true)
end

function SetLayer:hideLayer()
	self.colorLayer:setTouchEnabled(false)
	self:setVisible(false)
	self:onResetData()
end

return SetLayer