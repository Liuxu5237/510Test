-- 游戏聊天

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ChatLayer = class("ChatLayer",cc.Layer)

function ChatLayer:ctor(parentNode,gameLayer)
    self._parentNode=parentNode
    self._scene = gameLayer
	self._frameEngine = self._scene._gameFrame
 	self.csbNode=ExternalFun.loadCSB("ChatLayer.csb",self)
     self:setPosition(-566,-5)

 	local callback = function (sender,eventType)
    	self:onSelectedEvent(sender:getName(),sender,eventType)
	end

    appdf.getNodeByName(self.csbNode,"btnChatRet")
    :addClickEventListener(callback)
    self.btnMask = appdf.getNodeByName(self.csbNode,"btnMask")
    self.btnMask:addClickEventListener(callback)
    appdf.getNodeByName(self.csbNode,"btnSend")
    :addClickEventListener(callback)
    
    self.txtInput = appdf.getNodeByName(self.csbNode,"tfInput")
    self.lvViewChat = appdf.getNodeByName(self.csbNode,"lvChat")
    self.lvViewChat:setScrollBarEnabled(false)
    self.staticChat = self.lvViewChat:getChildByTag(0)
    self.staticChat:retain()
    self.lvViewChat:removeAllItems()
end

function ChatLayer:onExit()
    if self.staticChat then
        self.staticChat:release()
    end
end

function ChatLayer:onSelectedEvent(name,sender,eventType)
    if name == "btnClose" or name == "btnMask" then
        self:hide()
    elseif name == "btnSend" then
        local curScene = cc.Director:getInstance():getRunningScene()
        local chatstr = self.txtInput:getString()
        chatstr = string.gsub(chatstr, " " , "")
        if ExternalFun.stringLen(chatstr) > 128 then
            showToast(curScene, "聊天内容过长", 2)
            return
        end

        if ExternalFun.stringLen(chatstr) ==  0 then
            showToast(curScene, "请输入聊天内容", 2)
            return
        end

        --判断emoji
        if ExternalFun.isContainEmoji(chatstr) then
            showToast(curScene, "聊天内容包含非法字符,请重试", 2)
            return
        end

        --敏感词过滤  
        if true == ExternalFun.isContainBadWords(chatstr) then
            showToast(curScene, "聊天内容包含敏感词汇!", 2)
            return
        end

        if "" ~= chatstr then
            local valid, msg = self:sendTextChat(chatstr)
            if false == valid and type(msg) == "string" and "" ~= msg then
                showToast(curScene, msg, 2)
            else
                self.txtInput:setText("")
            end
        end
        self.txtInput:setText("")
	end
end

function ChatLayer:show()
    self:setPosition(-566,-5)
    self:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(-8,-5))))
    self.btnMask:setVisible(true)
end

function ChatLayer:hide()
    self.btnMask:setVisible(false)
    self:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(-566,-5)),cc.CallFunc:create(function()
       -- self:removeSelf()
    end)))
end

--发送文本聊
function ChatLayer:sendTextChat(msg)
	if nil ~= self._frameEngine and nil ~= self._frameEngine.sendTextChat then
		return self._frameEngine:sendTextChat(msg)
	end
	return false, ""
end

--发送表情聊天
function ChatLayer:sendBrowChat(idx)
	if nil ~= self._frameEngine and nil ~= self._frameEngine.sendBrowChat then
		return self._frameEngine:sendBrowChat(idx)
	end

	return false, ""
end

-- 添加消息
function ChatLayer:pushMsg(isMe,name,msg)
    local lvView = self.lvViewChat
        local chatName = nil
        local chat = nil
        local count = lvView:getChildrenCount()
        if count < 100 then
            chatName = self.staticChat:clone()
            chat = self.staticChat:clone()
            lvView:pushBackCustomItem(chatName)
            lvView:pushBackCustomItem(chat)
        else
            chatName = lvView:getItem(0)
            chatName:retain()
            lvView:removeItem(0)
            lvView:pushBackCustomItem(chatName)
            chatName:release()
            chat = lvView:getItem(0)
            chat:retain()
            lvView:removeItem(0)
            lvView:pushBackCustomItem(chat)
            chat:release()
        end
        if not isMe then
            chatName:setTextColor(cc.c3b(173,216,230))
        else
            chatName:setTextColor(cc.c3b(30,145,255))
        end
        chat:setTextColor(cc.c3b(255,255,255))

        chatName:setString(name..":")
        chat:setString(msg)
        chat:setTextAreaSize(cc.size(479,0))

        lvView:forceDoLayout()
        lvView:jumpToBottom()
end


--用户聊天
function ChatLayer:onUserChat(isMe, nick, chatstr)
   	
	local record = {nick,{_type=0,_content=chatstr}}

--	self._dataModule:insertRecord(record)
    -- self:reloadData()
    self:pushMsg(isMe,nick,chatstr)
end

return ChatLayer