--玩家信息
local UserInfoLayer = class("UserInfoLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

function UserInfoLayer:ctor(userItem)

    local csbNode = ExternalFun.loadCSB("UserInfo/UserInfoLayer.csb"):addTo(self)
    local content = csbNode:getChildByName("content")

    content:getChildByName("btn_close"):addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)

    --昵称
    local txtNickName = content:getChildByName("txt_nickname")
    txtNickName:setString(userItem.NickName or userItem.szNickName)

    local nickname_width = txtNickName:getContentSize().width
    local nickname_posx = txtNickName:getPositionX()

    --性别
    local sp_user_sex = content:getChildByName("sp_user_sex")
    sp_user_sex:setPositionX(nickname_width + nickname_posx + sp_user_sex:getContentSize().width/2 + 10)
    local str_sp = (userItem.Gender == 0) and "PersonalInfo/sp_girl.png" or "PersonalInfo/sp_boy.png"
    sp_user_sex:setTexture(str_sp)

    --游戏币
    --local txtGold = content:getChildByName("txt_gold")
    --txtGold:setString(ExternalFun.numberThousands(tonumber(userItem.Score or userItem.lScore)))
    local str = ExternalFun.numberThousands(tonumber(userItem.Score or userItem.lScore))
    str = string.gsub(str,",",":")
    local txtGold = content:getChildByName("txt_gold")
    txtGold:setString(str)
   
    
    --游戏ID
    local txtGameID = content:getChildByName("txt_gameid")
    txtGameID:setVisible(false)
    --[[txtGameID:setString("ID:"..userItem.GameID or userItem.dwGameID)

    local txtUnderWrite = ccui.Text:create("个人签名", "fonts/round_body.ttf", 22)
    txtUnderWrite:setAnchorPoint(0, 0.5)
    txtUnderWrite:setPosition(210, 145)
    txtUnderWrite:setTextColor(cc.c3b(148, 187, 209))
    txtUnderWrite:addTo(content)
    txtUnderWrite:setString(userItem.szSign or userItem.szUnderWrite or userItem.UnderWrite or "这个家伙很懒，什么都没留下")]]

    --签名
    local txtUnderWrite = content:getChildByName("txt_underwrite")
    --txtUnderWrite:ignoreContentAdaptWithSize(false)
    --txtUnderWrite:setSize(cc.size(500, 54))
    txtUnderWrite:setString(userItem.szSign or userItem.szUnderWrite or userItem.UnderWrite or "这个家伙很懒，什么都没留下")

    --头像
    local headSprite = HeadSprite:createClipHead({ wFaceID = userItem.FaceID or userItem.wFaceID }, 120, "sp_avatar_mask_120.png")
    headSprite:setPosition(100, 150)
    headSprite:addTo(content)

    --内容跳入
    AnimationHelper.jumpIn(content)
end

return UserInfoLayer