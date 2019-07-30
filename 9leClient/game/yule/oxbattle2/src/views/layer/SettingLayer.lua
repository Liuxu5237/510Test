--
-- Author: zhong
-- Date: 2016-07-08 17:16:26
--
--设置界面
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local SettingLayer = class("SettingLayer", cc.Layer)

SettingLayer.BT_EFFECT = 1
SettingLayer.BT_MUSIC = 2
SettingLayer.BT_CLOSE = 3
SettingLayer.BT_AUTO = 4
SettingLayer.BT_DAY = 5
SettingLayer.BT_NIGHT = 6

--构造
function SettingLayer:ctor(verstr, selfLayer, selfnightbg)
	self.Layer = selfLayer
	self.nightPrompt_bg = selfnightbg
	--加载csb资源
	local csbNode = ExternalFun.loadCSB("SettingLayer.csb", self)

	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onBtnClick(sender:getTag(), sender)
		end
	end

	local layoutbg = csbNode:getChildByName("layout_bg")
	layoutbg:setTag(SettingLayer.BT_CLOSE)
	layoutbg:addTouchEventListener(btnEvent)

	local sp_bg = csbNode:getChildByName("setting_bg")
	sp_bg:setScale(0.1)
	sp_bg:runAction(cc.ScaleTo:create(0.17, 1.0))

	--关闭按钮
	local btn = sp_bg:getChildByName("close_btn")
	btn:setTag(SettingLayer.BT_CLOSE)
	btn:addTouchEventListener(btnEvent)

	csbNode:getChildByName("setting_bg"):getChildByName("txt_version"):setVisible(false)
	--switch
    --音效
    self.m_btnEffect = sp_bg:getChildByName("effect_btn")
    self.m_btnEffect:setTag(SettingLayer.BT_EFFECT)
    self.m_btnEffect:addTouchEventListener(btnEvent)
    --音乐
    self.m_btnMusic = sp_bg:getChildByName("music_btn")
    self.m_btnMusic:setTag(SettingLayer.BT_MUSIC)
    self.m_btnMusic:addTouchEventListener(btnEvent)
    --自动
    self.m_btnAuto = sp_bg:getChildByName("auto_btn")
    self.m_btnAuto:setTag(SettingLayer.BT_AUTO)
    self.m_btnAuto:addTouchEventListener(btnEvent)
    --白天
    self.m_btnDay = sp_bg:getChildByName("day_btn")
    self.m_btnDay:setTag(SettingLayer.BT_DAY)
    self.m_btnDay:addTouchEventListener(btnEvent)
    --晚上
    self.m_btnNight = sp_bg:getChildByName("night_btn")
    self.m_btnNight:setTag(SettingLayer.BT_NIGHT)
    self.m_btnNight:addTouchEventListener(btnEvent)

    --版本
    self.m_txtversion = sp_bg:getChildByName("txt_version")
    self.m_txtversion:setString(verstr)

	self:refreshBtnState()
end

--
function SettingLayer:showLayer( var)
	self:setVisible(var)
end

function SettingLayer:onBtnClick( tag, sender )
	if SettingLayer.BT_CLOSE == tag then
		ExternalFun.playClickEffect()
		self:removeFromParent()
	elseif SettingLayer.BT_MUSIC == tag then
		local music = not GlobalUserItem.bVoiceAble;
		GlobalUserItem.setVoiceAble(music)
		self:refreshMusicBtnState()
		-- if GlobalUserItem.bVoiceAble == true then
		-- 	ExternalFun.playBackgroudAudio(self:getBgMusic())
		-- end
	elseif SettingLayer.BT_EFFECT == tag then
		local effect = not GlobalUserItem.bSoundAble
		GlobalUserItem.setSoundAble(effect)
		self:refreshEffectBtnState()
	elseif SettingLayer.BT_DAY == tag then
		local isDay = not GlobalUserItem.bDayAble
		GlobalUserItem.setDayAble(isDay)
		self:SetIsDay()
	elseif SettingLayer.BT_NIGHT == tag then
		local isDay = not GlobalUserItem.bDayAble
		GlobalUserItem.setDayAble(isDay)
		self:SetIsDay()
	elseif SettingLayer.BT_AUTO == tag then
		local isAuto = not GlobalUserItem.bAutoAble
		local isDay = nil
		GlobalUserItem.setAutoAble(isAuto)
		if isAuto then
			self:Auto()
		else
			self:SetAutoClose()
		end 
	end
end

function SettingLayer:refreshBtnState(  )
	self:refreshEffectBtnState()
	self:refreshMusicBtnState()
	self:refreshTimeBtnState()
end

function SettingLayer:refreshEffectBtnState(  )
	local str = nil
	if GlobalUserItem.bSoundAble then
		str = "bt_set_open.png"
	else
		str = "bt_set_close.png"
	end

	if nil ~= str then
		self.m_btnEffect:loadTextureDisabled(str,UI_TEX_TYPE_PLIST)
		self.m_btnEffect:loadTextureNormal(str,UI_TEX_TYPE_PLIST)
		self.m_btnEffect:loadTexturePressed(str,UI_TEX_TYPE_PLIST)
	end
end

function SettingLayer:refreshMusicBtnState(  )
	local str = nil
	if GlobalUserItem.bVoiceAble then
		str = "bt_set_open.png"
	else
		str = "bt_set_close.png"
	end
	if nil ~= str then
		self.m_btnMusic:loadTextureDisabled(str,UI_TEX_TYPE_PLIST)
		self.m_btnMusic:loadTextureNormal(str,UI_TEX_TYPE_PLIST)
		self.m_btnMusic:loadTexturePressed(str,UI_TEX_TYPE_PLIST)
	end
end

function SettingLayer:refreshTimeBtnState()
	if GlobalUserItem.bAutoAble then
		print("现在是自动初始化")
		self:Auto()
	else
		if GlobalUserItem.bDayAble then 
			self:Day()
			self:SetAutoClose()
		else
			self:Night()
			self:SetAutoClose()
		end
	end
end

function SettingLayer:SetIsDay()
	if GlobalUserItem.bDayAble then 
		self:Day()
		self:SetAutoClose()
		self:setNightPromptText(false)
	else
		self:Night()
		self:SetAutoClose()
		self:setNightPromptText(true)
	end
end

--设置白天选中，隐藏夜晚背景
function SettingLayer:Day()
	local str1 = "bt_set_open.png"
	local str2 = "bt_set_close.png"
	self.m_btnDay:loadTextureNormal(str1,UI_TEX_TYPE_PLIST)
	self.m_btnDay:loadTextureNormal(str1,UI_TEX_TYPE_PLIST)
	self.m_btnDay:loadTexturePressed(st1,UI_TEX_TYPE_PLIST)

	self.m_btnNight:loadTextureNormal(str2,UI_TEX_TYPE_PLIST)
	self.m_btnNight:loadTextureNormal(str2,UI_TEX_TYPE_PLIST)
	self.m_btnNight:loadTexturePressed(str2,UI_TEX_TYPE_PLIST)
	self.Layer:setVisible(false)
end
--设置黑夜选中，显示夜晚背景
function SettingLayer:Night()
	local str1 = "bt_set_open.png"
	local str2 = "bt_set_close.png"
	self.m_btnDay:loadTextureNormal(str2,UI_TEX_TYPE_PLIST)
	self.m_btnDay:loadTextureNormal(str2,UI_TEX_TYPE_PLIST)
	self.m_btnDay:loadTexturePressed(str2,UI_TEX_TYPE_PLIST)

	self.m_btnNight:loadTextureNormal(str1,UI_TEX_TYPE_PLIST)
	self.m_btnNight:loadTextureNormal(str1,UI_TEX_TYPE_PLIST)
	self.m_btnNight:loadTexturePressed(str1,UI_TEX_TYPE_PLIST)
	self.Layer:setVisible(true)
end
--根据当前时间自动判断时间段，白天隐藏背景，黑夜显示背景，自动按钮设置选中，并设置对应的bool值。
function SettingLayer:Auto() 
	local isDay = nil
	local nowDate = os.date("*t", os.time())
	local str = "bt_set_open.png"
	if nowDate.hour > 6 and nowDate.hour < 18 then
		isDay = true
		GlobalUserItem.setDayAble(isDay)
		self:Day()
	else
		isDay = false
		GlobalUserItem.setDayAble(isDay)
		self:Night()
	end 
	self.m_btnAuto:loadTextureNormal(str,UI_TEX_TYPE_PLIST)
	self.m_btnAuto:loadTextureNormal(str,UI_TEX_TYPE_PLIST)
	self.m_btnAuto:loadTexturePressed(str,UI_TEX_TYPE_PLIST)
	self.Layer:setVisible(not GlobalUserItem.bDayAble)
end
--z设置自动按钮关闭，并设置false
function SettingLayer:SetAutoClose()
	local str = "bt_set_close.png"
	self.m_btnAuto:loadTextureNormal(str,UI_TEX_TYPE_PLIST)
	self.m_btnAuto:loadTextureNormal(str,UI_TEX_TYPE_PLIST)
	self.m_btnAuto:loadTexturePressed(str,UI_TEX_TYPE_PLIST)
	GlobalUserItem.setAutoAble(false)
end

function SettingLayer:setNightPromptText(Visible)
	if Visible then
		self.nightPrompt_bg:getChildByName("yituichu"):setString("已进入『               』")
	else
		self.nightPrompt_bg:getChildByName("yituichu"):setString("已退出『               』")
	end
	local action = cc.Sequence:create(
        cc.FadeTo:create(0.2, 200),
        cc.DelayTime:create(1.5),
        cc.FadeTo:create(0.2, 0))
	self.nightPrompt_bg:stopAllActions()
	self.nightPrompt_bg:runAction(action)
end

return SettingLayer