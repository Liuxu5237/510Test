
module("DSNewEditBox", package.seeall)

local DSNewEditBox = {
	mLayer_UI = nil,
	mTitle = "",
	mText = "",
	mAff_txt = "",
	mCancel_txt = "",
	mCallBack_affirm = nil,
	mCallBack_cancle = nil,
	mCancle_none = nil,
	mDialogType = 0,
	mTextField = nil,
}

ds = ds or {}
ds.NewEditBoxTYPE = {
	--包含确认取消
	AFFIRMANDCANCEL = 0,
	--确认
	AFFIRM = 1,
	--无
	NONEBUTTON = 2,
	--自定义-两个按钮
	CUSTOM_TWO = 3,
	CUSTOM_ONE = 4,
}

function DSNewEditBox:create()  
	local instance = {}

	setmetatable(instance, self)
	self.__index = self

	self.mLayer_UI = DSBaseLayer.initWithJsonFile("NewEditBoxLayer","PlatForm/InputLayer.json")
    return instance
end 


function DSNewEditBox:init()
    local lab_titile = self.mLayer_UI:seekWidgetByNameOfRoot("lab_titile")
    lab_titile:setString(self.mTitle)

    local viewSize = self.mLayer_UI:getContentSize()

    local lab_txt = self.mLayer_UI:seekWidgetByNameOfRoot("lab_txt")
    lab_txt:setString(self.mText)

    self.mTextField = self.mLayer_UI:seekWidgetByNameOfRoot("lab_input")
    self.mTextField:setString("")

    local btn_cancel = self.mLayer_UI:seekWidgetByNameOfRoot("btn_cancel")
    btn_cancel:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
			ds.common.playButtonClickEffect()
		elseif eventType == ccui.TouchEventType.ended then
			if (self.mCallBack_cancle ~= nil and type(self.mCallBack_cancle) == "function") then
				self.mCallBack_cancle(self)
			end
			self.mLayer_UI:removeFromParent()
			self.mLayer_UI = nil
        end
    end)
    btn_cancel:setVisible(false)

    local btn_affirm = self.mLayer_UI:seekWidgetByNameOfRoot("btn_affirm")
    btn_affirm:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
			ds.common.playButtonClickEffect()
		elseif eventType == ccui.TouchEventType.ended then
			if (self.mCallBack_affirm ~= nil and type(self.mCallBack_affirm) == "function") then
				self.mCallBack_affirm(self)
			end
			self.mLayer_UI:removeFromParent()
			self.mLayer_UI = nil
        end
    end)
    btn_affirm:setVisible(false)

	
	if(self.mDialogType == ds.NewEditBoxTYPE.AFFIRMANDCANCEL) then
		btn_cancel:setVisible(true)
		btn_affirm:setVisible(true)
	elseif(self.mDialogType == ds.NewEditBoxTYPE.AFFIRM)then
		btn_affirm:setVisible(true)
		btn_affirm:setPositionX(viewSize.size/2)	
	elseif(self.mDialogType == ds.NewEditBoxTYPE.NONEBUTTON)then

		local move = cc.FadeOut:create(2)
		local actions = cc.Sequence:create(move,cc.CallFunc:create(function(self)
			if (self.mCancle_none ~= nil and type(self.mCancle_none) == "function") then
				self.mCancle_none()
			end
			self.mLayer_UI:removeFromParent()
			self.mLayer_UI = nil
		end))
		self.mLayer_UI:runAction(actions)	
	elseif (self.mDialogType == ds.NewEditBoxTYPE.CUSTOM_TWO)then
		btn_cancel:setVisible(true)
		btn_affirm:setVisible(true)

		btn_cancel:setScale(0.7)
		btn_cancel:setPosition(cc.p(522, 245))
		btn_cancel:setTitleFontSize(34)
		btn_cancel:setTitleText(self.mCancel_txt)

		btn_affirm:setScale(0.7)
		btn_affirm:setPosition(cc.p(753, 245))
		btn_affirm:setTitleFontSize(34)
		btn_affirm:setTitleText(self.mAff_txt)

	elseif (self.mDialogType == ds.NewEditBoxTYPE.CUSTOM_ONE)then
		btn_cancel:setVisible(false)
		btn_affirm:setVisible(true)
		btn_affirm:setScale(0.7)
		btn_affirm:setPosition(cc.p(640, 245))
		btn_affirm:setTitleFontSize(34)
		btn_affirm:setTitleText(self.mAff_txt)
	end
end

function DSNewEditBox:GetInputText()
	local str = ""
	if (self.mTextField) then
		str = self.mTextField:getString()
	end

	return str
end
--dialogType :
	--AFFIRMANDCANCEL 包含(确认,取消)两个按钮
	--AFFIRM 确认 一个按钮
	--NONEBUTTON 无按钮
--Text 对话框内容
--Title 对话框标题
--aff_txt (确定)按钮文字
--cancel_txt （取消）按钮文字
--CallBack_affirm (确定)回调函数
--CallBack_cancle (取消)回调函数
function create(Title, Text, dialogType, aff_txt, cancel_txt, CallBack_affirm, CallBack_cancle, CallBack_none)
	local editBoxLayer = DSNewEditBox:create()
	if (Title) then
		editBoxLayer.mTitle = Title
	end
	if (Text) then
		editBoxLayer.mText = Text
	end

	if (dialogType) then
		editBoxLayer.mDialogType = dialogType
	end

	if (aff_txt) then
		editBoxLayer.mAff_txt = aff_txt
	end

	if (cancel_txt) then
		editBoxLayer.mCancel_txt = cancel_txt
	end

	if (CallBack_affirm) then
		editBoxLayer.mCallBack_affirm = CallBack_affirm
	end

	if (CallBack_cancle) then
		editBoxLayer.mCallBack_cancle = CallBack_cancle
	end

	if (CallBack_none) then
		editBoxLayer.mCancle_none = CallBack_none
	end
	editBoxLayer:init()

	
	-- if(Type==ds.Dialog.Type.NONEBUTTON) then
	-- 	local action = cc.FadeOut:create(2);
	-- 	local actions = cc.Sequence:create(action,cc.CallFunc:create(function(self)
	-- 		self:removeFromParent();
	-- 		end));
	-- 	layer:runAction(actions);
	-- 	--ds.common.MyFadout(layer,action);
	-- elseif(Type==ds.Dialog.Type.AFFIRM)then
		
	-- elseif(Type==ds.Dialog.Type.AFFIRMANDCANCEL)then
		
	-- else
		
	-- end

    local _scene = cc.Director:getInstance():getRunningScene()
    if (_scene == nil) then
        _scene = cc.Scene:create()
        cc.Director:getInstance():runWithScene(_scene)
    end
    _scene:addChild(editBoxLayer.mLayer_UI,ds.common.LOADING_Z_ORDER)
    return editBoxLayer
end