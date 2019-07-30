--奖励展示
local RewardShowLayer = class("RewardShowLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local RequestManager = appdf.req(appdf.CLIENT_SRC .. "plaza.models.RequestManager")

RewardType = 
{
    Gold = 1,
    Bean = 2,
    RoomCard = 3
}

function RewardShowLayer:ctor(lotteryinfo, signinfo, closeCallback)

    local csbNode = ExternalFun.loadCSB("RewardShow/RewardShowLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --网络回调
    
    --self._checkinFrame:onConnectCompeleted()
    --确定
    local btnOK = self._content:getChildByName("btn_ok")
    btnOK:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)

        if closeCallback then
            closeCallback()
        end

         --请求个人信息
         RequestManager.requestUserScoreInfo(nil)

        -- --发送更新财富通知       
		-- local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
		-- eventListener.obj = yl.RY_MSG_USERWEALTH
		-- cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
    end)

    --奖励类型
    --local txtRewardType = self._content:getChildByName("txt_reward_type")

    --[[if rewardtype == RewardType.Gold then
        self._content:getChildByName("icon_golds"):setVisible(true)
        txtRewardType:setString("游戏币")
    elseif rewardtype == RewardType.Bean then
        self._content:getChildByName("icon_beans"):setVisible(true)
        txtRewardType:setString("游戏钻")
    elseif rewardtype == RewardType.RoomCard then
        self._content:getChildByName("icon_roomcard"):setVisible(true)
        txtRewardType:setString("房卡")
    end]]

    --奖励数量
    --local txtReward = self._content:getChildByName("txt_reward")
    --txtReward:setString("+" .. rewardcount)
    local sp_reward_lottery = self._content:getChildByName("sp_reward_lottery")
    local sp_lottery_icon = sp_reward_lottery:getChildByName("sp_icon")
    local txt_lottery_count = sp_reward_lottery:getChildByName("txt_count")
    local icon_str = string.format("LogonReward/sp_icon_%d.png",lotteryinfo._itemIndex)
    sp_lottery_icon:setTexture(icon_str)
    local txt_str = (lotteryinfo._itemType == 0) and (tostring(lotteryinfo._drawReward).."金币") or (tostring(lotteryinfo._drawReward).."元红包")
    txt_lottery_count:setString(txt_str)


    local sp_reward_sign = self._content:getChildByName("sp_reward_sign")
    local sp_sign_icon = sp_reward_sign:getChildByName("sp_icon")
    local txt_sign_count = sp_reward_sign:getChildByName("txt_count")

    --是签到还是转盘
    if next(signinfo) ~= nil then
        local strSignIcon = string.format("LogonReward/sp_item_%d.png",signinfo._itemIndex)
        sp_sign_icon:setTexture(strSignIcon)
        local txtSignCount = (signinfo._itemType == 0) and (signinfo._drawReward.."金币") or (signinfo._drawReward.."元红包")
        txt_sign_count:setString(txtSignCount)
    else
        sp_reward_lottery:setPositionX(667)
        sp_reward_sign:setVisible(false)
    end


    --光线
    local spGuangXian = self._content:getChildByName("sp_guangxian")
    spGuangXian:runAction(cc.RepeatForever:create(cc.RotateBy:create(6.0, 360)))

    btnOK:setVisible(false)
    btnOK:runAction(cc.Sequence:create(
                        cc.DelayTime:create(0.5), 
                        cc.CallFunc:create(function()
                            btnOK:setVisible(true)
                            AnimationHelper.jumpIn(btnOK)
                        end)
                        )
                    )

    self._content:setScale(0.9)
    self._content:runAction(cc.EaseSineOut:create(cc.ScaleTo:create(0.2, 1.0)))

    --播放音效
    ExternalFun.playPlazaEffect("GetGoods.mp3")
end

return RewardShowLayer