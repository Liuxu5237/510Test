--加入房间界面
local RoomJoinLayer = class("RoomJoinLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

function RoomJoinLayer:ctor(userItem)

    --初始化变量
    self._inputCount = 0
    self._txtNumbers = {}

    local csbNode = ExternalFun.loadCSB("Room/PrivateMode/RoomJoinLayer.csb"):addTo(self)
    local content = csbNode:getChildByName("content")

    content:getChildByName("btn_close"):addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)

    local touchListener = function(ref, type)
        --改变按钮点击颜色
        if type == ccui.TouchEventType.began then
            ref:setColor(cc.c3b(200, 200, 200))
        elseif type == ccui.TouchEventType.ended or ccui.TouchEventType.canceled then
            ref:setColor(cc.WHITE)
        end
    end

    --数字文本
    for i = 1, 6 do 
        local txtNumber = content:getChildByName("txt_number_" .. i)
        txtNumber:setString("")
        self._txtNumbers[i] = txtNumber
    end

    --数字按钮
    for i = 0, 9 do
        local btnNumber = content:getChildByName("btn_" .. i)
        btnNumber:addTouchEventListener(touchListener)
        btnNumber:addClickEventListener(function()
            self:onClickNumber(i)
        end)
    end

    --清空按钮
    local btnClear = content:getChildByName("btn_clear")
    btnClear:addTouchEventListener(touchListener)
    btnClear:addClickEventListener(function()
        self:onClickClear()
    end)

    --删除按钮
    local btnDel = content:getChildByName("btn_del")
    btnDel:addTouchEventListener(touchListener)
    btnDel:addClickEventListener(function()
        self:onClickDel()
    end)

    --内容跳入
    AnimationHelper.jumpIn(content)
end

--点击数字
function RoomJoinLayer:onClickNumber(number)

    --播放音效
    ExternalFun.playMenuEffect()

    if self._inputCount >= 6 then
        self:onFinishInput()
        return
    end

    self._inputCount = self._inputCount + 1
    self._txtNumbers[self._inputCount]:setString(number)

    if self._inputCount >= 6 then
        self:onFinishInput()
    end
end

--点击清空
function RoomJoinLayer:onClickClear()

    --播放音效
    ExternalFun.playMenuEffect()

    self._inputCount = 0

    for i = 1, 6 do 
        self._txtNumbers[i]:setString("")
    end
end

--点击删除
function RoomJoinLayer:onClickDel()

    --播放音效
    ExternalFun.playMenuEffect()

    if self._inputCount > 0 then
        self._txtNumbers[self._inputCount]:setString("")
        self._inputCount = self._inputCount - 1
    end
end

--完成输入
function RoomJoinLayer:onFinishInput()

    local txtRoomID = self._txtNumbers[1]:getString() .. self._txtNumbers[2]:getString() .. self._txtNumbers[3]:getString() ..
                      self._txtNumbers[4]:getString() .. self._txtNumbers[5]:getString() .. self._txtNumbers[6]:getString()

    print("完成输入: ", txtRoomID)
end

return RoomJoinLayer