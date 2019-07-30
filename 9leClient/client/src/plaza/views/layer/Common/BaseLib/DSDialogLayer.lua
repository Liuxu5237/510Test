
module("DSDialogLayer", package.seeall)

local DSDialogLayer = class("DSDialogLayer")
DSDialogLayer.__index = DSDialogLayer
DSDialogLayer.__Frame = nil

local mDialogLayer = nil

ds = ds or {}

ds.Dialog = {}
ds.Dialog.Type = 
{
	--包含确认取消
	AFFIRMANDCANCEL = 0,
	--确认
	AFFIRM = 1,
	--无
	NONEBUTTON = 2,
}

ds.Dialog.LOADING_Z_ORDER = 1000
ds.Dialog.ZI_ARIAL = "fonts/arial.ttf"

local mDialogTipsImage = nil
local mDialogTipsImageOfHall = nil

function DSDialogLayer.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, DSDialogLayer)
    return target
end


function DSDialogLayer:init(Type, Text, Title, aff_Img, cancel_Img, CallBack_affirm, CallBack_cancle, CallBack_none, isInGame, textColor, titileColor, disTime, isDisappear)
	Type = Type or ds.Dialog.Type.NONEBUTTON
	Text = Text or ""
	Title = Title or ""
	aff_Img = aff_Img or "PlatForm/Tips/confirm.png"
	cancel_Img = cancel_Img or "PlatForm/Tips/cancle.png"
	textColor = textColor or ccc3(241,211,128)
    titileColor = titileColor or ccc3(249,223,130)
    disTime = disTime or 2

    if (not isDisappear) then
        isDisappear = true
    else
        isDisappear = false
    end
    
	if (not cc.FileUtils:getInstance():isFileExist(aff_Img)) then
		aff_Img = "PlatForm/Tips/confirm.png"
	end

	if (not cc.FileUtils:getInstance():isFileExist(cancel_Img)) then
		cancel_Img = "PlatForm/Tips/cancle.png"
	end

    local function onTouchBegan(touch, event)
        if (CallBack_none and type(CallBack_none) == "function") then
            CallBack_none();
            self:removeFromParent();
        end
        
        return true
    end

    local function onTouchMoved(touch, event)
        
    end

    local function onTouchEnded(touch, event)
        
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    local height = 100
    self.TextLabel = cc.LabelTTF:create(Text, ds.Dialog.ZI_MARKERFELT, 30,cc.size(500,0),cc.TEXT_ALIGNMENT_CENTER,cc.TEXT_ALIGNMENT_CENTER)
    height = height + self.TextLabel:getContentSize().height + 10

    local titleBG = nil
    if (Title ~= "") then
       titleBG = cc.Sprite:create("PlatForm/Global/title/TitleBack_big.png")

    	self.TitleLabel = cc.LabelTTF:create(Title, ds.Dialog.ZI_MARKERFELT, 38,cc.size(400,0),cc.TEXT_ALIGNMENT_CENTER,cc.TEXT_ALIGNMENT_CENTER)
    	height = height + self.TitleLabel:getContentSize().height +  30
    else
    	height = height + 15
    end

    if (height < 320) then
    	height = 320
    end

    self.__Frame = cc.Scale9Sprite:create("PlatForm/Tips/tipsBg.png")
    self.__Frame:setCapInsets(CCRectMake(29, 28, 2, 2))
	if (isInGame) then
		self.__Frame = cc.Scale9Sprite:create("common/tangkuangdi.png")
    	self.__Frame:setCapInsets(CCRectMake(29, 29, 2, 2))
	end
    
    self.__Frame:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
    self.__Frame:setAnchorPoint(cc.p(0.5, 0.5))
    self.__Frame:setContentSize(cc.size(500, height))
    self:addChild(self.__Frame)


    if (titleBG) then
        titleBG:setPosition(cc.p(self.__Frame:getContentSize().width/2, self.__Frame:getContentSize().height - titleBG:getContentSize().height/2 - 5))
        titleBG:setScaleX((self.__Frame:getContentSize().width - 20)/titleBG:getContentSize().width)
        self.__Frame:addChild(titleBG)
    end

    self.TextLabel:setPosition(cc.p(self.__Frame:getContentSize().width/2, self.__Frame:getContentSize().height/2 + 30))
    self.TextLabel:setAnchorPoint(cc.p(0.5, 0.5))
    if (Title ~= "") then
     	self.TextLabel:setPosition(cc.p(self.__Frame:getContentSize().width/2, self.__Frame:getContentSize().height*0.5))
    end
    self.TextLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.TextLabel:setColor(textColor)
    self.__Frame:addChild(self.TextLabel)
	
    if (Title ~= "") then
		self.TitleLabel:setPosition(cc.p(self.__Frame:getContentSize().width/2, self.__Frame:getContentSize().height - self.TitleLabel:getContentSize().height/2 - 12))
    	self.TitleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    	if (titileColor ~= nil) then
    		self.TitleLabel:setColor(titileColor)
    	end
    	self.__Frame:addChild(self.TitleLabel)
    end

    local path_aff = "PlatForm/Button/Bt_Yellow_c.png"
    if (isInGame) then
       path_aff = "PlatForm/Button/Button_queding.png"
    end
    self.Affi_btn = ccui.Button:create(path_aff,"","");
	local affi_size = self.Affi_btn:getContentSize();
	self.Affi_btn:setPosition(cc.p(self.__Frame:getContentSize().width/2  + 40 + affi_size.width/2,50))
	self.__Frame:addChild(self.Affi_btn);

	self.Affi_btn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
			if ds.common ~= nil and ds.common.playButtonClickEffect ~= nil then
				ds.common.playButtonClickEffect()
			end
		elseif eventType == ccui.TouchEventType.ended then
			if (CallBack_affirm and type(CallBack_affirm) == "function") then
				CallBack_affirm();
            elseif (CallBack_none and type(CallBack_none) == "function") then
                CallBack_none();
			end

            if (isDisappear) then	
                self:removeFromParent();
                mDialogLayer = nil
            end
        end
    end)

    if (isInGame == nil) then
        self.btn_title_img = ccui.ImageView:create(aff_Img)
        self.btn_title_img:setPosition(cc.p(self.Affi_btn:getContentSize().width/2, self.Affi_btn:getContentSize().height/2 + 5))
        self.btn_title_img:setAnchorPoint(cc.p(0.5, 0.5))
	    self.Affi_btn:addChild(self.btn_title_img);
    end


    local path_cancle = "PlatForm/Button/Bt_Green_B.png"
    if (isInGame) then
       path_cancle = "PlatForm/Button/Button_quxiao.png"
    end
    self.cancle_bn = ccui.Button:create(path_cancle,"","");
	local cancle_size = self.cancle_bn:getContentSize();
	self.cancle_bn:setPosition(cc.p(self.__Frame:getContentSize().width/2 - 40 - cancle_size.width/2 ,50))
	self.__Frame:addChild(self.cancle_bn);

	self.cancle_bn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
			if ds.common ~= nil and ds.common.playButtonClickEffect ~= nil then
				ds.common.playButtonClickEffect()
			end
		elseif eventType == ccui.TouchEventType.ended then
			if (CallBack_cancle and type(CallBack_cancle) == "function") then
				CallBack_cancle();
            elseif (CallBack_none and type(CallBack_none) == "function") then
                CallBack_none();
			end

			if (isDisappear) then    
                self:removeFromParent();
                mDialogLayer = nil
            end
        end
    end)

    if (isInGame == nil) then
        self.btn_title_img_cancle = ccui.ImageView:create(cancel_Img)
        self.btn_title_img_cancle:setPosition(cc.p(self.cancle_bn:getContentSize().width/2, self.cancle_bn:getContentSize().height/2 + 5))
        self.btn_title_img_cancle:setAnchorPoint(cc.p(0.5, 0.5))
	   self.cancle_bn:addChild(self.btn_title_img_cancle);
    end

	if (Type == ds.Dialog.Type.AFFIRM)then
		self.cancle_bn:setVisible(false)
		self.Affi_btn:setVisible(true)
		self.cancle_bn:setEnabled(false)
		self.Affi_btn:setEnabled(true)
		self.Affi_btn:setPositionX(self.__Frame:getContentSize().width/2)
	elseif (Type == ds.Dialog.Type.AFFIRMANDCANCEL)then
		self.cancle_bn:setVisible(true)
		self.Affi_btn:setVisible(true)
		self.cancle_bn:setEnabled(true)
		self.Affi_btn:setEnabled(true)
	else
		self.cancle_bn:setVisible(false)
		self.Affi_btn:setVisible(false)
		self.cancle_bn:setEnabled(false)
		self.Affi_btn:setEnabled(false)
		self.TextLabel:setPositionY(self.__Frame:getContentSize().height * 0.5)
	end

    if (CallBack_none and type(CallBack_none) == "function") then
        local delaytime = cc.DelayTime:create(disTime)
        local actions = cc.Sequence:create(delaytime, cc.CallFunc:create(function()
            self:removeFromParent();
            mDialogLayer = nil
            CallBack_none();
        end));
        self:runAction(actions);
    end
end



function createTipsDialog(Text, CallBack_none, textColor)
    local _scene = cc.Director:getInstance():getRunningScene()
    if (_scene == nil) then
       return
    end

    textColor = textColor or ccc3(241,211,128)
    local sceneType = _scene:getTag()
    if (sceneType == 1) then
        if mDialogTipsImageOfHall ~= nil then
            mDialogTipsImageOfHall:removeFromParent()
            mDialogTipsImageOfHall = nil
        end
        mDialogTipsImageOfHall = cc.Scale9Sprite:create("PlatForm/Tips/tipsBg1.png")
        mDialogTipsImageOfHall:setCapInsets(CCRectMake(150, 34, 9, 2))
        local TextLabel = cc.LabelTTF:create(Text, ds.Dialog.ZI_MARKERFELT, 30,cc.size(0,0),cc.TEXT_ALIGNMENT_CENTER,cc.TEXT_ALIGNMENT_CENTER)
        local width = TextLabel:getContentSize().width + 150
        if TextLabel:getContentSize().width > 800 then
            mDialogTipsImageOfHall = cc.Scale9Sprite:create("PlatForm/Tips/tipsBg2.png")
            mDialogTipsImageOfHall:setCapInsets(CCRectMake(150, 54, 9, 2))
            TextLabel = cc.LabelTTF:create(Text, ds.Dialog.ZI_MARKERFELT, 30,cc.size(800,0),cc.TEXT_ALIGNMENT_CENTER,cc.TEXT_ALIGNMENT_CENTER)
            mDialogTipsImageOfHall:setContentSize(cc.size(800 + 150, 109))
        else
            mDialogTipsImageOfHall:setContentSize(cc.size(width, 70))
        end
    
        if (textColor) then
            TextLabel:setColor(textColor)
        end
        TextLabel:setPosition(cc.p(mDialogTipsImageOfHall:getContentSize().width/2, mDialogTipsImageOfHall:getContentSize().height/2))
        TextLabel:setAnchorPoint(cc.p(0.5, 0.5))
        mDialogTipsImageOfHall:addChild(TextLabel)

        local visibleSize = cc.Director:getInstance():getVisibleSize()
        mDialogTipsImageOfHall:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
    

        _scene:addChild(mDialogTipsImageOfHall,ds.Dialog.LOADING_Z_ORDER)

        local delaytime = cc.DelayTime:create(1.5)
        local FadeOut = cc.FadeOut:create(1.5)
        local MoveBy = cc.MoveBy:create(1.5,cc.p(0, 100))
        local action = cc.Spawn:create(FadeOut, MoveBy)

        local actions = cc.Sequence:create(delaytime, action, cc.CallFunc:create(function()
            if (mDialogTipsImageOfHall) then
                mDialogTipsImageOfHall:removeFromParent();
                mDialogTipsImageOfHall = nil
            end
        end));
        mDialogTipsImageOfHall:runAction(actions);

        local actions1 = cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeOut:create(1.5));
        TextLabel:runAction(actions1);
    else
        if mDialogTipsImage ~= nil then
            mDialogTipsImage:removeFromParent()
            mDialogTipsImage = nil
        end
        mDialogTipsImage = cc.Scale9Sprite:create("PlatForm/Tips/tipsBg1.png")
        
        mDialogTipsImage:setCapInsets(CCRectMake(150, 34, 9, 2))
        local TextLabel = cc.LabelTTF:create(Text, ds.Dialog.ZI_MARKERFELT, 30,cc.size(0,0),cc.TEXT_ALIGNMENT_CENTER,cc.TEXT_ALIGNMENT_CENTER)
        local width = TextLabel:getContentSize().width + 150
        if TextLabel:getContentSize().width > 800 then
            mDialogTipsImage = cc.Scale9Sprite:create("PlatForm/Tips/tipsBg2.png")
            mDialogTipsImage:setCapInsets(CCRectMake(150, 54, 9, 2))
            TextLabel = cc.LabelTTF:create(Text, ds.Dialog.ZI_MARKERFELT, 30,cc.size(800,0),cc.TEXT_ALIGNMENT_CENTER,cc.TEXT_ALIGNMENT_CENTER)
            mDialogTipsImage:setContentSize(cc.size(800 + 150, 109))
        else
            mDialogTipsImage:setContentSize(cc.size(width, 70))
        end
    
        if (textColor) then
            TextLabel:setColor(textColor)
        end
        TextLabel:setPosition(cc.p(mDialogTipsImage:getContentSize().width/2, mDialogTipsImage:getContentSize().height/2))
        TextLabel:setAnchorPoint(cc.p(0.5, 0.5))
        mDialogTipsImage:addChild(TextLabel)

        local visibleSize = cc.Director:getInstance():getVisibleSize()
        mDialogTipsImage:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
    
        _scene:addChild(mDialogTipsImage,ds.Dialog.LOADING_Z_ORDER)
    

        local delaytime = cc.DelayTime:create(1.5)
        local FadeOut = cc.FadeOut:create(1.5)
        local MoveBy = cc.MoveBy:create(1.5,cc.p(0, 100))
        local action = cc.Spawn:create(FadeOut, MoveBy)

        local actions = cc.Sequence:create(delaytime, action, cc.CallFunc:create(function()
            if (mDialogTipsImage) then
                mDialogTipsImage:removeFromParent();
                mDialogTipsImage = nil
            end
        end));
        mDialogTipsImage:runAction(actions);

        local actions1 = cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeOut:create(1.5));
        TextLabel:runAction(actions1);
    end
end

--Type :
--AFFIRMANDCANCEL 包含(确认,取消)两个按钮
--AFFIRM 确认 一个按钮
--NONEBUTTON 无按钮
--Text 对话框内容
--Title 对话框标题
--aff_Img (确定)按钮图片路径
--cancel_Img （取消）按钮图片路径
--CallBack_affirm (确定)回调函数
--CallBack_cancle (取消)回调函数
--isInGame：是否是用游戏中的框
--textColor:正文的颜色
--titileColor：标题的颜色

function create(Type, Text, Title, aff_Img, cancel_Img, CallBack_affirm, CallBack_cancle, CallBack_none, isInGame, textColor, titileColor, disTime, isDisappear)
	if (Type == ds.Dialog.Type.NONEBUTTON) then
		createTipsDialog(Text, CallBack_none, textColor)
		return 
	end

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local layer = DSDialogLayer.extend(cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.3), visibleSize.width, visibleSize.height))
    layer:init(Type, Text, Title, aff_Img, cancel_Img, CallBack_affirm, CallBack_cancle, CallBack_none, isInGame, textColor, titileColor, disTime, isDisappear)
    mDialogLayer = layer
    local _scene = cc.Director:getInstance():getRunningScene()
    if (_scene == nil) then
        _scene = cc.Scene:create()
        cc.Director:getInstance():runWithScene(_scene)
    end
    _scene:addChild(layer,ds.Dialog.LOADING_Z_ORDER)
end

--删除当前这个对话框
function DeleteDialog()
    if (mDialogLayer) then
        mDialogLayer:removeFromParent()
        mDialogLayer = nil
    end
end

function DeleteTipsDialogOfLogin()
    if (mDialogTipsImage) then
        mDialogTipsImage = nil
    end
end


function DeleteTipsDialog()
    if (mDialogTipsImageOfHall) then
        mDialogTipsImageOfHall:removeFromParent()
        mDialogTipsImageOfHall = nil
    end
end




