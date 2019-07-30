--
-- Author: luo
-- Date: 2016年12月30日 15:18:32
--
--设置界面
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local SettingLayer = class("SettingLayer", function(scene)
	local settingLayer = display.newLayer()
	return settingLayer
end)
SettingLayer.BT_EFFECT = 1
SettingLayer.BT_MUSIC = 2
SettingLayer.BT_CLOSE = 3
SettingLayer.BT_MUTE = 4
SettingLayer.BT_DAY = 5
SettingLayer.BT_NIGHT = 6
SettingLayer.BT_AUTO = 7
--构造
function SettingLayer:ctor(scene)
    self._scene = scene
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)
    --加载csb资源
    self._csbNode = ExternalFun.loadCSB("set/set.csb", self)
    --回调方法
    local cbtlistener = function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:OnButtonClickedEvent(sender:getTag(),sender)
        end
    end
    --背景
    local sp_bg = self._csbNode:getChildByName("bg")
    self.m_spBg = sp_bg

    --关闭按钮
    local btn = self._csbNode:getChildByName("closeBtn")
    btn:setTag(SettingLayer.BT_CLOSE)
    btn:addTouchEventListener(function (ref, eventType)
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playCloseButtonClickEffect()
            self:hide()
        end
    end)
    --是否静音
    self.m_mute = false 

    --是否是白天
    self.m_day = true
    --是否是黑夜
    self.m_night = false
    --是否自动
    self.m_auto = false


    --音效
    self.m_btnEffect = self._csbNode:getChildByName("soundBtn")
    self.m_btnEffect:setTag(SettingLayer.BT_EFFECT)
    self.m_btnEffect:addTouchEventListener(cbtlistener)

    --音乐
    self.m_btnMusic = self._csbNode:getChildByName("musicBtn")
    self.m_btnMusic:setTag(SettingLayer.BT_MUSIC)
    self.m_btnMusic:addTouchEventListener(cbtlistener)

    --静音按钮
    self.m_btnMute = self._csbNode:getChildByName("muteBtn")
    self.m_btnMute:setTag(SettingLayer.BT_MUTE)
    self.m_btnMute:addTouchEventListener(cbtlistener)

    --黑夜模式背景
	self.m_nightLayout = self._csbNode:getChildByName("layout_night")
    self.m_nightLayout:setVisible(false)

    --白天按钮
    self.m_btnDay = self._csbNode:getChildByName("daytiemBtn")
    self.m_btnDay:setTag(SettingLayer.BT_DAY)
    self.m_btnDay:addTouchEventListener(cbtlistener)

    --夜间按钮
    self.m_btnNight = self._csbNode:getChildByName("nightBtn")
    self.m_btnNight:setTag(SettingLayer.BT_NIGHT)
    self.m_btnNight:addTouchEventListener(cbtlistener)

    --自动按钮
    self.m_btnAuto = self._csbNode:getChildByName("automateBtn")
    self.m_btnAuto:setTag(SettingLayer.BT_AUTO)
    self.m_btnAuto:addTouchEventListener(cbtlistener)
    

    if GlobalUserItem.bVoiceAble == false and GlobalUserItem.bSoundAble == false then
        self.m_mute = true
    end

    --按钮纹理
    if GlobalUserItem.bVoiceAble == true then 
        self.m_btnMusic:setBrightStyle(ccui.BrightStyle.normal)
    else
        self.m_btnMusic:setBrightStyle(ccui.BrightStyle.highlight)
    end
    if GlobalUserItem.bSoundAble == true then 
        self.m_btnEffect:setBrightStyle(ccui.BrightStyle.normal)
    else
        self.m_btnEffect:setBrightStyle(ccui.BrightStyle.highlight)
    end
    if self.m_mute == true then
        self.m_btnMute:setBrightStyle(ccui.BrightStyle.normal)
    else
        self.m_btnMute:setBrightStyle(ccui.BrightStyle.highlight)
    end
    if self.m_day == true and self.m_night == false then
        self.m_btnDay:setBrightStyle(ccui.BrightStyle.normal)
        self.m_btnNight:setBrightStyle(ccui.BrightStyle.highlight)
    else
        self.m_btnDay:setBrightStyle(ccui.BrightStyle.highlight)
        self.m_btnNight:setBrightStyle(ccui.BrightStyle.normal)
    end
    
    if self.m_auto == true then
        self.m_btnAuto:setBrightStyle(ccui.BrightStyle.normal)
    else
        self.m_btnAuto:setBrightStyle(ccui.BrightStyle.highlight)
    end

    self:show()
 
    
end

--
function SettingLayer:showLayer( var )
    self:setVisible(var)
end
--按钮回调方法
function SettingLayer:OnButtonClickedEvent( tag, sender )
    ExternalFun.playCommonButtonClickEffect()
    if SettingLayer.BT_MUSIC == tag then    --音乐
        local music = not GlobalUserItem.bVoiceAble
        GlobalUserItem.setVoiceAble(music)
        if GlobalUserItem.bVoiceAble == true then 
            ExternalFun.playBackgroudAudio("LOAD_BACK.mp3")
            sender:setBrightStyle(ccui.BrightStyle.normal)
        else
            AudioEngine.stopMusic()
            sender:setBrightStyle(ccui.BrightStyle.highlight)
        end
        self:UpdateMute()
    elseif SettingLayer.BT_EFFECT == tag then   --音效
        local effect = not GlobalUserItem.bSoundAble
        GlobalUserItem.setSoundAble(effect)
        if GlobalUserItem.bSoundAble == true then 
            sender:setBrightStyle(ccui.BrightStyle.normal)
        else
            sender:setBrightStyle(ccui.BrightStyle.highlight)
        end
        self:UpdateMute()
    elseif SettingLayer.BT_MUTE == tag then
         self.m_mute = not self.m_mute 
        self:setMute(self.m_mute)
    elseif SettingLayer.BT_DAY == tag then
        self.m_day = not self.m_day
        self:setIsNight(not self.m_day )
    elseif SettingLayer.BT_NIGHT==tag  then
        self.m_night = not self.m_night
        self:setIsNight(self.m_night)
    elseif SettingLayer.BT_AUTO == tag then
        self.m_auto = not self.m_auto
        self:setAuto(self.m_auto) 
    end
end
function SettingLayer:setAuto(isAuto)
    if isAuto ==true then
        local time = os.date("%H")  --获取当前时间：时钟（0-23）
        print("当前时间为："..time)
        local timeNum = tonumber(time)
        if timeNum >7 and timeNum  < 18 then  --白天
            self:setIsNight(false)
        else
            self:setIsNight(true)
        end
    end
    
end
function SettingLayer:setMute( able)
    cc.UserDefault:getInstance():setBoolForKey("showhand_muteable",able)
    GlobalUserItem.setSoundAble(not able)
    GlobalUserItem.setVoiceAble(not able)
    if able == true then
        self.m_btnMusic:setBrightStyle(ccui.BrightStyle.highlight)
        self.m_btnEffect:setBrightStyle(ccui.BrightStyle.highlight)
        self.m_btnMute:setBrightStyle(ccui.BrightStyle.normal)
    else
        self.m_btnMusic:setBrightStyle(ccui.BrightStyle.normal)
        self.m_btnEffect:setBrightStyle(ccui.BrightStyle.normal)
        self.m_btnMute:setBrightStyle(ccui.BrightStyle.highlight)
    end
end
--触摸回调
function SettingLayer:onTouchBegan(touch, event)
    return self:isVisible()
end

function SettingLayer:onTouchEnded(touch, event)
    local pos = touch:getLocation() 
    local m_spBg = self.m_spBg
    pos = m_spBg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        self:hide()
    end
end
function SettingLayer:setIsNight(isNight)
	if self.m_nightLayout == nil then 
		return
	end
    self.m_nightLayout:setVisible(isNight)
    if isNight == false then
        self.m_btnNight:setBrightStyle(ccui.BrightStyle.highlight)
        self.m_btnDay:setBrightStyle(ccui.BrightStyle.normal)
    else
        self.m_btnNight:setBrightStyle(ccui.BrightStyle.normal)
        self.m_btnDay:setBrightStyle(ccui.BrightStyle.highlight)
    end
    self.m_night = isNight
    self.m_day = not isNight
end

function SettingLayer:show()

    local fadeIn = cc.FadeIn:create(0.07)
    local bigger = cc.ScaleTo:create(0.07, 1.1)
    local spawn = cc.Spawn:create(fadeIn, bigger)
    local reNormal = cc.ScaleTo:create(0.21, 1.0)
    local action = cc.Sequence:create(spawn, reNormal)
    self:runAction(action)


end 
function SettingLayer:hide()

    local spawnTime = 0.1
    local moveUp = cc.MoveBy:create(spawnTime, cc.p(0, 20))
    local fadeOut = cc.FadeOut:create(spawnTime)
    local smaller = cc.ScaleTo:create(spawnTime, 0.8)
    local spawn = cc.Spawn:create(moveUp, fadeOut, smaller)
    
    local action = cc.Sequence:create(spawn, callFun,cc.RemoveSelf:create())
    self:runAction(action)

end
function SettingLayer:UpdateMute()
    --按钮纹理
    if GlobalUserItem.bVoiceAble == false and GlobalUserItem.bSoundAble == false then
        self.m_mute = true
    else
        self.m_mute = false
    end
    if self.m_mute == true then
        self.m_btnMute:setBrightStyle(ccui.BrightStyle.normal)
    else
        self.m_btnMute:setBrightStyle(ccui.BrightStyle.highlight)
    end
end

return SettingLayer