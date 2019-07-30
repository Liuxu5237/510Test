--登录奖励
local LogonRewardLayer = class("LogonRewardLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local RewardShowLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RewardShowLayer")
local CheckinFrame = require("client.src.plaza.models.CheckinFrame")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

function LogonRewardLayer:ctor(poplayercallback)

    --初始化数据
    self._drawReward = 0
    self._logonReward = 0
    self._totalReward = 0
    self._signRewardInfo = {}
    self._istrunaction = false
    self._popLayerCallBcak = poplayercallback
    self._bTodayChecked = GlobalUserItem.bTodayChecked
    self.nContinuouDay = GlobalUserItem.nContinuouDay
    local csbNode = ExternalFun.loadCSB("LogonReward/LogonRewardLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    self._spTable = self._content:getChildByName("sp_table")
    self._spTableItemHighlight = self._content:getChildByName("sp_table_item_highlight")
    self._spTableItemFlash0 = self._content:getChildByName("sp_table_item_flash_0")
    self._spTableItemFlash1 = self._content:getChildByName("sp_table_item_flash_1")
    self._panelSign = self._content:getChildByName("panel_sign")
    self._panelResult = self._content:getChildByName("panel_result")

    --关闭
    self._btnClose = self._content:getChildByName("btn_close")
    self._btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        if self._popLayerCallBcak then
            self._popLayerCallBcak()
        end
        dismissPopupLayer(self)
    end)

    --抽奖
    self._btnDraw = self._content:getChildByName("btn_draw")
    self._btnDraw:addClickEventListener(function()
        if not self._istrunaction then
            self._istrunaction = true
            self:onClickDraw()
        end
    end)
    self._btnDraw:setEnabled(not self._bTodayChecked)

    --领取
    local btnReceive = self._panelResult:getChildByName("btn_receive")
    btnReceive:addClickEventListener(function()
        
        self:onClickReceive()
    end)

    --填充转盘信息
    --[[local x0 = self._spTable:getContentSize().width / 2
    local y0 = self._spTable:getContentSize().height / 2
    for i = 1, #GlobalUserItem.dwLotteryQuotas do
        
        local txtQuota = ccui.Text:create(GlobalUserItem.dwLotteryQuotas[i], "fonts/round_body.ttf", 40)
        local x = x0   +   170   *   math.sin((i - 1) * 36   *   3.14   /180   ) 
        local y = y0   +   170   *   math.cos((i - 1) * 36   *   3.14   /180   ) 

        txtQuota:setPosition(x, y)
        txtQuota:setRotation( (270 + (i - 1) * 36) % 360 )
        txtQuota:enableOutline(cc.c3b(136, 70, 0), 1)
        txtQuota:addTo(self._spTable)
    end]]

    --更新签到信息
    self:onUpdateSignInfo()

    --内容跳入
    AnimationHelper.jumpIn(self._content)
end

--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--更新签到信息
function LogonRewardLayer:onUpdateSignInfo()

    local txtSignDays = self._panelSign:getChildByName("txt_sign_days")
    txtSignDays:setString("已连续签到 " .. GlobalUserItem.wSeriesDate .. " 天")

    local wSeriesDate = GlobalUserItem.wSeriesDate
    --local nContinuouDay = GlobalUserItem.nContinuouDay
    print("GlobalUserItem.nContinuouDay"..GlobalUserItem.nContinuouDay)
    local Checkdays = {2,5,7,14,22}

    for i = 1, yl.LEN_WEEK do
        
        local spGoldItemBg = self._panelSign:getChildByName("sp_gold_item_bg_" .. Checkdays[i])
        local spGoldItem = spGoldItemBg:getChildByName("sp_gold_item")
        local spReceived = spGoldItemBg:getChildByName("sp_received")
        local txtReward = spGoldItemBg:getChildByName("txt_reward")

        local bSigned = GlobalUserItem.nContinuouDay >= Checkdays[i]                         --已签到
        local bCanSign = (wSeriesDate + 1 == Checkdays[i] and not self._bTodayChecked)       --可签

        --已签到标志
        spReceived:setVisible(bSigned)
        local strReward = GlobalUserItem.lCheckinRewards[i] > 10 and GlobalUserItem.lCheckinRewards[i].."金币" or GlobalUserItem.lCheckinRewards[i].."元红包"
        --奖励金额
        txtReward:setString(strReward)
    end
end

--更新奖励结果
function LogonRewardLayer:onUpdateRewardResult()
    
    local txtDrawReward = self._panelResult:getChildByName("txt_draw_reward")
    local txtLogonReward = self._panelResult:getChildByName("txt_logon_reward")
    local txtTotalReward = self._panelResult:getChildByName("txt_total_reward")

    txtDrawReward:setString(self._drawReward)
    txtLogonReward:setString(self._logonReward)
    txtTotalReward:setString(self._totalReward)
end

--转盘开始
function LogonRewardLayer:onTurnTableBegin(index)

    local itemCount = #GlobalUserItem.dwLotteryQuotas
    print(itemCount)
    local degree = 1800 + (itemCount - index) * (360 / itemCount)

    self._spTable:runAction(cc.Sequence:create( 
        cc.EaseSineInOut:create(cc.RotateTo:create(5.0, degree)),
        cc.CallFunc:create(function()
            
            self:onTurnTableEnd()
        end)
        )
    )

    --转盘音效
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.8),
        cc.CallFunc:create(function()
            ExternalFun.playPlazaEffect("zhuanpanBegin.mp3")
        end)
        )
    )
end

--转盘结束
function LogonRewardLayer:onTurnTableEnd()

    --更新状态
    print("更新状态bTodayChecked = "..tostring(self._bTodayChecked))
    local Checkdays = {2,5,7,14,22}
    if false == self._bTodayChecked then
        GlobalUserItem.wSeriesDate = GlobalUserItem.wSeriesDate + 1
        print("更新天数 = wSeriesDate"..GlobalUserItem.wSeriesDate)
        for i = 1, yl.LEN_WEEK do
            if  GlobalUserItem.wSeriesDate == Checkdays[i] and GlobalUserItem.nContinuouDay < GlobalUserItem.wSeriesDate then
                GlobalUserItem.nContinuouDay = Checkdays[i]
                break
            end
        end  
        for i = 1, yl.LEN_WEEK do
            if GlobalUserItem.wSeriesDate == Checkdays[i] and self.nContinuouDay < GlobalUserItem.wSeriesDate then
                --图标序号
                self._signRewardInfo._itemIndex = Checkdays[i]
                --资金数量
                self._signRewardInfo._drawReward = GlobalUserItem.lCheckinRewards[i]
                --奖励类型0为金币,1为红包
                self._signRewardInfo._itemType = GlobalUserItem.lCheckinRewards[i] > 10 and 0 or 1
            end
        end
    end
    --GlobalUserItem.bTodayChecked = true
    self._btnDraw:setEnabled(false)
    
    --统计奖励
    --self._logonReward = GlobalUserItem.lCheckinRewards[GlobalUserItem.wSeriesDate]
    --self._totalReward = self._drawReward + self._logonReward

    --闪烁选中奖品
    self._spTableItemHighlight:setVisible(true)
    self:runAction(
                    cc.RepeatForever:create(
                        cc.Sequence:create(
                            cc.CallFunc:create(function()
                                
                                if self._spTableItemFlash0:isVisible() then
                                    self._spTableItemFlash0:setVisible(false)
                                    self._spTableItemFlash1:setVisible(true)
                                else
                                    self._spTableItemFlash0:setVisible(true)
                                    self._spTableItemFlash1:setVisible(false)
                                end
                            end),
                            cc.DelayTime:create(0.2)
                        )
                    )
                )

    --显示签到动画和结果页
    self:runAction(cc.Sequence:create( 
                    cc.CallFunc:create(function()
                        --已签到动画
                        self:onCheckedAnimation()   
                        --音效
                        ExternalFun.playPlazaEffect("zhuanzhong.mp3")
                    end),
                    cc.DelayTime:create(1.0),
                    cc.CallFunc:create(function()

                    self:onClickReceive()
                    self._istrunaction = false
                        --更新奖励结果
                        --self:onUpdateRewardResult()

                        --显示结果页面
                        --self._panelSign:setVisible(false)
                        --self._panelResult:setVisible(true)
                    end)
                    )
                )
    
end

--已签到动画
function LogonRewardLayer:onCheckedAnimation()
    if GlobalUserItem.wSeriesDate < 1 or GlobalUserItem.wSeriesDate > 31 then
        return
    end
    print("签到动画 = "..tostring(GlobalUserItem.wSeriesDate))
    local Checkdays = {2,5,7,14,22}
    local isactionrun = false
    for i = 1, yl.LEN_WEEK do
        if GlobalUserItem.wSeriesDate == Checkdays[i] and self.nContinuouDay < GlobalUserItem.wSeriesDate then
            isactionrun = true
            break
        end
    end
    if isactionrun then
        local spGoldItemBg = self._panelSign:getChildByName("sp_gold_item_bg_" .. GlobalUserItem.wSeriesDate)
        local spReceived = spGoldItemBg:getChildByName("sp_received")

        spReceived:setVisible(true)
        spReceived:setScale(2.0)

        spReceived:runAction(cc.Sequence:create(
                                cc.ScaleTo:create(0.5, 1.0),
                                cc.DelayTime:create(0.5),
                                cc.CallFunc:create(function()                              
                                    --更新签到信息
                                    self:onUpdateSignInfo()
                                end)
                                )
                            )
    else
        --更新签到信息
        self:onUpdateSignInfo()
    end
end

--点击抽奖
function LogonRewardLayer:onClickDraw()

    --播放音效
    ExternalFun.playClickEffect()

    --self._btnDraw:setEnabled(false)

    self:requestLotteryStart()

--    self:onTurnTableBegin(2)

--    self._lotteryResult = {
--        ItemIndex = 2,
--        ItemQuota = 200
--    }
end

--点击领取
function LogonRewardLayer:onClickReceive()
    --四个参数
    --[[
    --中奖类型
    --中奖数量
    --签到类型
    --签到数量
    self._itemIndex = idx
                            self._itemType = list["ItemType"]
                            self._drawReward = list["ItemQuota"]
    ]]
    local lotteryinfo = {}
    lotteryinfo._itemIndex = self._itemIndex    --转盘序号
    lotteryinfo._itemType = self._itemType      --奖励类型0为金币,1为红包
    lotteryinfo._drawReward = self._drawReward  --奖励数额

    --[[showPopupLayer(
        RewardShowLayer:create(RewardType.Gold, self._totalReward, function()
            dismissPopupLayer(self)
        end), true, false
    )]]
    showPopupLayer(
        RewardShowLayer:create(lotteryinfo, self._signRewardInfo, function()
            if self._popLayerCallBcak then
                self._popLayerCallBcak()
            end
            dismissPopupLayer(self)
        end), true, false
    )
    self._signRewardInfo = {}
end

--------------------------------------------------------------------------------------------------------------------
-- 网络请求

function LogonRewardLayer:webOnCheckInDone( result, message2 )
	
	local action = cjson.encode(message2)
	local message = cjson.decode(message2)
    dismissPopWait()
	if message[1] == 3 and message[2] == 105 then
		if message[3]["code"] == 1 then
			GlobalUserItem.bTodayChecked = true
			GlobalUserItem.bQueryCheckInData = true

			if GlobalUserItem.bTodayChecked == true then	
				--非会员标记当日已签到
				if GlobalUserItem.cbMemberOrder == 0 then
					GlobalUserItem.setTodayCheckIn()
				end
			end
            
            --隐藏关闭按钮
            self._btnClose:setVisible(false)
    
            local idx = message[3]["index"]
            --转盘开始
            self:onTurnTableBegin(idx)
            --保存抽奖数据
            self._itemIndex = idx
            self._itemType = GlobalUserItem.cbLotteryTypes[idx]
            self._drawReward = GlobalUserItem.dwLotteryQuotas[idx]
            
		else 
			GlobalUserItem.bTodayChecked = false
            showToast(nil, "签到失败", 2)
            
            self._istrunaction = false
            self._btnDraw:setEnabled(true)

		end
	end
	
	-- --通知更新        
	-- local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
    -- eventListener.obj = yl.RY_MSG_USERWEALTH
    -- cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

end

--开始抽奖
function LogonRewardLayer:requestLotteryStart()
    
    showPopWait()


    local checkinCallBack = function(result,message,subMessage)
        return true
    end
    --网络处理
    self._checkinFrame = CheckinFrame:create(self,checkinCallBack)
    --签到发送
    if not self._bTodayChecked then
        self._checkinFrame:onCheckinDone()

        local _webFrame = WebFrame:create(nil, function(result, message)
            if self.webOnCheckInDone then
                self:webOnCheckInDone(result,message)
            end
        end,true)
    
        local pargams = {3,5}
        local action2 = cjson.encode(pargams)
       
        _webFrame:wsSendString(action2) 

    end


    -- local ostime = os.time()
    -- local url = yl.HTTP_URL .. "/WS/Lottery.ashx"   
    -- --local url = "http://localhost:12569/WS/Lottery.ashx"           
    -- appdf.onHttpJsionTable(url ,"GET","action=LotteryStart&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(jstable,jsdata)
        
    --     dismissPopWait()

    --     local msg = "抽奖异常"
    --     if type(jstable) == "table" then
    --         msg = jstable["msg"]
    --         local data = jstable["data"]
    --         if type(data) == "table" then
    --             local valid = data["valid"]
    --             if nil ~= valid and true == valid then
    --                 local list = data["list"]
    --                 if type(list) == "table" then

    --                     local idx = list["ItemIndex"]
    --                     msg = nil
    --                     if nil ~= idx then
                            
    --                         --保存抽奖数据
    --                         self._itemIndex = idx
    --                         self._itemType = list["ItemType"]
    --                         self._drawReward = list["ItemQuota"]

    --                         --保存财富数据
    --                         GlobalUserItem.lUserScore = list["Score"]
    --                         GlobalUserItem.dUserBeans = list["Currency"]
    --                         GlobalUserItem.lUserIngot = list["UserMedal"]

    --                         local checkinCallBack = function(result,message,subMessage)
    --                             return true
    --                         end
    --                         --网络处理
    --                         self._checkinFrame = CheckinFrame:create(self,checkinCallBack)
    --                         --签到发送
    --                         if not self._bTodayChecked then
    --                             self._checkinFrame:onCheckinDone()
    --                         end

    --                         --隐藏关闭按钮
    --                         self._btnClose:setVisible(false)

    --                         --转盘开始
    --                         self:onTurnTableBegin(idx)
    --                     else
    --                         msg = "抽奖异常"
    --                     end                        
    --                 end
    --             end
    --         end
    --     end
        
    --     if nil ~= msg then
    --         showToast(self, msg, 2)
    --         self._istrunaction = false
    --         self._btnDraw:setEnabled(true)
    --     end
    -- end) 

end

return LogonRewardLayer