--PC登录界面
local LogonLayerForWin = class("LogonLayerForWin", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local LogonCheckUser = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.logon.LogonCheckUserLayer")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

function LogonLayerForWin:ctor(delegate)

    self._delegate = delegate
    --ExternalFun.registerNodeEvent(self)
    local csbNode = ExternalFun.loadCSB("Logon/LogonLayerWithWin32.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")
    --返回
    local btnBack = self._content:getChildByName("btn_back")
    btnBack:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        self:onExit(true)    
    end)

    --设计尺寸下坐标
    local x ,y = 806, 322
    local width, height = 165, 165
    --获取缩放比例
    local screensize = getScreenSize()

    local scalex = screensize[1] / yl.WIDTH
    local scaley = screensize[2] / yl.HEIGHT
    x = x * scalex
    y = y * scaley
    width = width * scalex
    height = height * scaley
    print(x,y,width,height)
    local rect = {x ,y , width, height}
    local url = "https://bpi.hjy510.com/WeChatCode.html"
    createWebWindow(rect[1],rect[2],rect[3],rect[4],url)

    ds.MyNotification:getInstance():registerLuaEventCallBack("GET_WXINFO_SUCCESS",function()
        print("==================数据接收成功====================")
            local Wxinfo = getWxInfo()
            self:Logon(Wxinfo[1],Wxinfo[2])
        end)

end

function LogonLayerForWin:Logon(accounts,nickname)

    local gender = 1;
    self._delegate._tThirdData = 
        {
            accounts = accounts,
            nickname = nickname,
            headurl = "",
            pwd    = accounts,
            gender = gender,
            platform = yl.PLATFORM_LIST[yl.ThirdParty.WECHAT],
        }
    showPopWait()

    
    
    if self._delegate and self._delegate.onLogonByWin32Wx then
        self._delegate:onLogonByWin32Wx(accounts, nickname, gender)
    end
    -- if self._delegate._logonFrame and self._delegate._logonFrame.onLoginByThirdParty then
    --     self._delegate._logonFrame:onLoginByThirdParty(accounts, nickname, gender, yl.PLATFORM_LIST[yl.ThirdParty.WECHAT])
    -- end
end

function LogonLayerForWin:onExit(isZhudong)
    if isZhudong == true then
        WebFrame:getInstance():close()
    end

    --通知关闭
    if self._delegate and self._delegate.onLogonLayerClose then
        self._delegate:onLogonLayerClose()
    end
    closeWebWindow()
    ds.MyNotification:getInstance():unRegisterEventListener("GET_WXINFO_SUCCESS")
    dismissPopupLayer(self)
end

--验证登陆提示
function LogonLayerForWin:onChenckUsertips(unidUserID)
    QueryDialog:create("系统提示".."\n检测到您更换了登陆设备\n是否进行短信验证?",function(bReTry)
            if bReTry == true then
                 local szAccount
                 if appdf.CHANNEL_ID == 1004  or appdf.CHANNEL_ID == 2001 then
                    szAccount = string.gsub(unidUserID, " ", "")
                    print("heheda")
                    print(unidUserID)
                 else
                    szAccount = string.gsub(self._editAccount:getText(), " ", "")
                end
                    showPopupLayer(LogonCheckUser:create(self._delegate, szAccount), false)
               
            else
                os.exit(0)
            end
        end)
        :addTo(self)
end

return LogonLayerForWin