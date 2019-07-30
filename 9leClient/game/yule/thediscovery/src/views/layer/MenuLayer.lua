
local MenuLayer = class("MenuLayer",cc.Layer)

local Shakingbool = false
local Soundbool = false

function MenuLayer:ctor(delegate)
    self._delegate = delegate
    --self:init()
end
function MenuLayer:init()
    node = cc.CSLoader:createNode("SystemLayer.csb")
    self:addChild(node)

    self.panelback = node:getChildByName("PanelBack")
    self.panelback:addClickEventListener(function()
            self:LayerAnimation()
        end)
    -- 获取按钮节点
    self.panel = node:getChildByName("Panel")
    
    -- 返回大厅
    local lobbyButton = self.panel:getChildByName("Lobby")
    lobbyButton:addTouchEventListener(function(sender, eventType) 
            if eventType == TOUCH_EVENT_ENDED then
                ccexp.AudioEngine:play2d("mp3/Button.mp3")
                self:LayerAnimation()
                self._delegate:exitFunction()
            end
        end)

    -- 帮助
    local helpButton = self.panel:getChildByName("Help")
    helpButton:addTouchEventListener(function(sender, eventType) 
            if eventType == TOUCH_EVENT_ENDED then
                ccexp.AudioEngine:play2d("mp3/Button.mp3")
                if self._delegate.helpfunc then
                    self:LayerAnimation()
                    self._delegate:helpfunc()
                end 
            end
        end)
	
	-- 声音 
    local soundButton = self.panel:getChildByName("Sound")
    soundButton:setSelectedState(Soundbool)
    soundButton:addEventListenerCheckBox(function(sender,eventType)
		ccexp.AudioEngine:play2d("mp3/Button.mp3")
        if eventType == ccui.CheckBoxEventType.selected then
            Soundbool = true
            if self._delegate.soundNo then 
                self._delegate:soundNo()
            end 
        elseif eventType == ccui.CheckBoxEventType.unselected then
            Soundbool = false
            if self._delegate.soundYes then 
                self._delegate:soundYes()
            end 
        end
    end)

    --摇一摇暂代管理
    local shakingButton = self.panel:getChildByName("Shaking")
    shakingButton:setSelectedState(Shakingbool)
    shakingButton:addEventListenerCheckBox(function(sender,eventType)

            if eventType == ccui.CheckBoxEventType.selected then             
                self._delegate:shakingYes()
            elseif eventType == ccui.CheckBoxEventType.unselected then
                self._delegate:shakingNo()
            end
        end)
end
function MenuLayer:LayerAnimation()
    if self.actionPlaying then
        return
    end
    self.actionPlaying = true
    if not self._delegate._IsMenuOpen then       
        self:setVisible(true)
        self.panel:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.15,1.0,1.0,1.0),cc.MoveTo:create(0.15,cc.p(1170,550))),
                            cc.CallFunc:create(function()
                                self._delegate._IsMenuOpen = true
                                self.actionPlaying = false
                                self.panelback:setTouchEnabled(true)
                                end)))
    else
        local tmpAction = cc.Spawn:create(cc.MoveTo:create(0.15,cc.p(1220,680)),cc.ScaleTo:create(0.15,0.3,0.3,0.3))
        self.panel:runAction(cc.Sequence:create(tmpAction, cc.CallFunc:create(function()
                    self:setVisible(false)
                    self._delegate._IsMenuOpen = false
                    self.actionPlaying = false
                    self.panelback:setTouchEnabled(false)
                end)))
    end
end

return MenuLayer