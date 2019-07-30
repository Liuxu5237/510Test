--[[
  分享界面
  2017_11_09 CRL
]]

local ShareLayer = class("ShareLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

function ShareLayer:ctor()
   local csbNode = ExternalFun.loadCSB("Share/ShareLayer.csb"):addTo(self)
   self._content = csbNode:getChildByName("content")

   	local btn_close = self._content:getChildByName("btn_close")
   	btn_close:addClickEventListener(function()
       	ExternalFun.playClickEffect()
       	dismissPopupLayer(self)
   	end)

   	local btn_shareFriend = self._content:getChildByName("btn_sharefriend")
   	btn_shareFriend:addClickEventListener(function()
   			self:WeChatShare(yl.ThirdParty.WECHAT)
   		end)

   	local btn_shareFriends = self._content:getChildByName("btn_sharefriends")
   	btn_shareFriends:addClickEventListener(function()
   			self:WeChatShare(yl.ThirdParty.WECHAT_CIRCLE)
   		end)
end

function ShareLayer:WeChatShare(plat)
	local function sharecall( isok )
        if type(isok) == "string" and isok == "true" then
            showToast(self, "分享完成", 2)
        end
    end
    --local url = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
    local url = "https://down.game217.com/d/index.html"
    print(url)
    MultiPlatform:getInstance():shareToTarget(plat, sharecall, "玩游戏，领微信红包","510游戏，下载送金币，红包领不停。", url, "")
end

return ShareLayer