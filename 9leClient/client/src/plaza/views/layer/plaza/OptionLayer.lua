--设置页面
local OptionLayer = class("OptionLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

local ModifyPasswordLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ModifyPasswordLayer")

function OptionLayer:ctor(delegate)
    
    self._delegate = delegate

    local csbNode = ExternalFun.loadCSB("Option/OptionLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --头像
    local headSprite = HeadSprite:createClipHead(GlobalUserItem, 60, "sp_avatar_mask_120.png")
    headSprite:setPosition(120, 337)
    headSprite:addTo(self._content)

    --昵称
    local txtNickName = self._content:getChildByName("Image_1"):getChildByName("txt_nickname")
    txtNickName:setString(GlobalUserItem.szNickName)
    
    --背景音乐开关
    local checkBgMusic = self._content:getChildByName("Image_3"):getChildByName("check_bgmusic")
    checkBgMusic:setSelected(GlobalUserItem.bVoiceAble)
    checkBgMusic:addEventListener(function(ref, type)

        --播放音效
        ExternalFun.playClickEffect()

        GlobalUserItem.setVoiceAble(ref:isSelected())

        if ref:isSelected() then
            ExternalFun.playPlazzBackgroudAudio()
        end
    end)

    --游戏音效开关
    local checkGameEffect = self._content:getChildByName("Image_3"):getChildByName("check_gameeffect")
    checkGameEffect:setSelected(GlobalUserItem.bSoundAble)
    checkGameEffect:addEventListener(function(ref, type)

        --播放音效
        ExternalFun.playClickEffect()

        GlobalUserItem.setSoundAble(ref:isSelected())
    end)

    --修改密码
    local btnModifyPwd = self._content:getChildByName("Image_1"):getChildByName("btn_modify_pwd")
    btnModifyPwd:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        showPopupLayer(ModifyPasswordLayer:create(), false)
    end)
    if yl.APPSTORE_VERSION then
        btnModifyPwd:setVisible(false)		
    end
    
--    --切换账号
--    local btnSwitchAccount = self._content:getChildByName("btn_switch_account")
--    btnSwitchAccount:addClickEventListener(function()

--        --播放音效
--        ExternalFun.playClickEffect()

--        if self._delegate and self._delegate.onSwitchAccount then
--            self._delegate:onSwitchAccount()
--        end
--    end)

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)

--    --客服电话
--    local btnService = self._content:getChildByName("btn_service")
--    btnService:setVisible(false)
--    btnService:addClickEventListener(function()

--        --播放音效
--        ExternalFun.playClickEffect()

--        --拨打客服电话
--        cc.Application:getInstance():openURL("tel:" .. yl.SERVICE_PHONE)
--    end)

    --手机绑定

    local BindIphone = self._content:getChildByName("Image_3"):getChildByName("Text_1")
     local phonelen = string.len(GlobalUserItem.szMobilePhone)
     if GlobalUserItem.szMobilePhone == "" or phonelen ~= 11 then
       BindIphone:setText("未绑定")
     else
     --替换的号码
     local  replaceNuber = string.sub(GlobalUserItem.szMobilePhone,8,-1);
     
       local RefIphone =  string.sub(GlobalUserItem.szMobilePhone,1,3).."****"..replaceNuber
        
        if RefIphone == nil then
            BindIphone:setText("未绑定")
            else
             BindIphone:setText(RefIphone)
        end
    
    end


    -- 内容跳入
    AnimationHelper.jumpIn(self._content)
end

------------------------------------------------------------------------------------------------------------
-- 事件处理


return OptionLayer