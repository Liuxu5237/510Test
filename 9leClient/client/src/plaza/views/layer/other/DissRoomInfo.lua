--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local TextTools = appdf.CLIENT_SRC .. "plaza.views.layer.other.TextTools"

local scheduler = cc.Director:getInstance():getScheduler()

local DissRoomInfo = class("DissRoomInfo", function(msg,callback,isUpdate,updateTime)
		local optionLayer = display.newLayer()
    return optionLayer
end)

DissRoomInfo.BT_CANCEL		    =  0   
DissRoomInfo.BT_CONFIRM		    =  1


--截取中英混合的UTF8字符串，endIndex可缺省
function DissRoomInfo:SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = self:SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = self:SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then 
        return string.sub(str, self:SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, self:SubStringGetTrueIndex(str, startIndex), self:SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

--获取中英混合UTF8字符串的真实字符数量
function DissRoomInfo:SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function DissRoomInfo:SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

--返回当前字符实际占用的字符数
function DissRoomInfo:SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end










function DissRoomInfo:ctor(msg,callback,isUpdate,updateTime)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local node = cc.CSLoader:createNode("public/DissLayer.csb")
    node:setScale(winSize.width / 1334,winSize.height / 750)
    node:addTo(self) 

    self._callback = callback

    local bg = node:getChildByName("Image_2")
    self.kh = {}
    for i = 1, 5 do
        self.kh[i] = bg:getChildByName("Text_1_"..i.."_0")
    end

    bg:getChildByName("Text_1_1_11")
      :setString(msg)

    local function onTouches(ref,touch)
        if touch == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

   self.clean =   bg:getChildByName("Button_1")
   self.clean:setTag(DissRoomInfo.BT_CANCEL)
   self.clean:addTouchEventListener(onTouches)

   self.comfirm=bg:getChildByName("Button_1_0")
   self.comfirm:setTag(DissRoomInfo.BT_CONFIRM)
   self.comfirm:addTouchEventListener(onTouches)

   if callback == nil then
        self.clean:setVisible(false)
        self.comfirm:setVisible(false)
   end

   self.clockbg = bg:getChildByName("Image_1")
   self.clockNum = self.clockbg:getChildByName("Text_1")

   self._timer = updateTime == nil and  120 or updateTime
   self._update = isUpdate


   self._update = scheduler:scheduleScriptFunc(handler(self, self.updateTimer), 1.0, false)


end

function DissRoomInfo:setInfo(userInfo)
    local i = 1
    local statues = ""
    for k,v in pairs(userInfo) do
        if tonumber(v[2]) == 0 then
            statues = "不同意解散"
        elseif tonumber(v[2]) == 1 then
            statues = "同意解散"
        elseif tonumber(v[2]) == -1 then
            statues = "等待同意"
        end

        local _name = "玩家["..self:setName(v[1]).."]"..statues
        self.kh[i]:setString(_name)
        self.kh[i]:setVisible(true)
        i = i + 1
    end
end





--按键点击
function DissRoomInfo:onButtonClickedEvent(tag,ref)
	if self._dismiss == true then
		return
	end
	--取消显示
	self.clean:setVisible(false)
    self.comfirm:setVisible(false)
	--通知回调
	if self._callback then
		self._callback(tag == DissRoomInfo.BT_CONFIRM)
	end
    if self._update ~= nil then
        self._callback = nil
    end
    
end

function DissRoomInfo:updateTimer(df)

    if self._timer  == nil then
        return 
    end
   self._timer = self._timer - 1
   if self._timer > 0 then
        
        local txt = self._timer
        self.clockNum:setString(txt)
        self.clockNum:setVisible(true)
   else
        if self._callback and  self._update then
		    self._callback(true)
	    end
        scheduler:unscheduleScriptEntry(self._update)
        self.clockbg:setVisible(false)
        self._update = nil
   end    

end
function DissRoomInfo:setName(szName)
    local len = string.len(szName)
    local name = szName
    if len >= 8 then
        name = self:SubStringUTF8(szName,0,8)
        name = name .. "..."
    end

    return name
end

function DissRoomInfo:rejectEnd()
    if self._update ~= nil then
        scheduler:unscheduleScriptEntry(self._update)
    end
    self:removeFromParent()

end

function DissRoomInfo:onExit()
    if self._update ~= nil then
        scheduler:unscheduleScriptEntry(self._update)
    end
end

return DissRoomInfo