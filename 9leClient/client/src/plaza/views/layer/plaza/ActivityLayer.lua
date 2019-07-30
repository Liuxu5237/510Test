--游戏活动
local ActivityLayer = class("ActivityLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local ActivityIndicator = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.general.ActivityIndicator")
local RequestManager = appdf.req(appdf.CLIENT_SRC .. "plaza.models.RequestManager")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")

local ZORDER = 
{
    WEBVIEW = 10,
    CLOSEBTN = 20,
    PROMPT = 30,
    ACTIVITY = 10000,
}


function ActivityLayer:ctor()

    local csbNode = ExternalFun.loadCSB("Activity/ActivityLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")
    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:setLocalZOrder(ZORDER.CLOSEBTN)
    btnClose:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()
        removebackgroundcallback()
        dismissPopupLayer(self)
    end)
    --活动列表
    self._activityCategoryBtns = {}
    --页面列表
    self._imageArray = {}
    --WEB页面
    self._webView = nil
    --下载下标
    self._downIndex = 1 

    self._oldImageInfo = {}
    self._newImageInfo = {}
    self._newImageInfo.image = {}
    --保存路径
    self._filePath = device.writablePath.."client/res/Activity/".."imageFile.plist"
    --保存信息
    self._oldImageInfo = cc.FileUtils:getInstance():getValueMapFromFile(self._filePath)

    --网页页面容器
    self._webLayout = ccui.Layout:create()
    self._webLayout:setAnchorPoint(cc.p(0,0))
    --self._webLayout:setBackGroundColor(cc.RED)
    --self._webLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    --self._webLayout:setBackGroundColorOpacity(100)
    self._webLayout:setContentSize(cc.size(display.width,display.height))
    self._webLayout:addTo(self,1)
    self._webLayout:setTouchEnabled(true)
    self._webLayout:setVisible(false)
    --self._webLayout:setSwallowTouches(true)
    --添加背景
    cc.Sprite:create("plaza/plaza_bg.jpg")
             :setPosition(cc.p(display.width / 2,display.height / 2))
             :addTo(self._webLayout)
    --提示文字
    ccui.Text:create("活动加载中,请稍后...", "fonts/round_body.ttf", 28)
             :setPosition(cc.p(display.width / 2,display.height / 2))
             --:setColor(cc.BLACK)
             :setTag(ZORDER.PROMPT)
             :addTo(self._webLayout,ZORDER.PROMPT)
    --容器关闭按钮
    ccui.Button:create("Activity/btn_close.png","Activity/btn_close.png")
              :setPosition(cc.p(40,710))
              :setTag(ZORDER.CLOSEBTN)
              :setVisible(true)
              :addTo(self._webLayout,ZORDER.CLOSEBTN)
              :addClickEventListener(function()
                    self._webLayout:setVisible(false)
                    if self._webView ~= nil then
                        self._webView:stopLoading()
                        self._webView:removeFromParent()
                        self._webView = nil
                    end
                    self._ImageCategoryIndex = nil
                    self._webLayout:getChildByTag(ZORDER.PROMPT):setString("活动加载中,请稍后...")
                end)
    --活动指示器
    self._activity = ActivityIndicator:create()
    self._activity:setPosition(self._content:getContentSize().width / 2 + 77, self._content:getContentSize().height / 2)
    self._activity:addTo(self._content, ZORDER.ACTIVITY)
    if GlobalUserItem.dwActivityList then
        self._activityList = GlobalUserItem.dwActivityList
        if appdf.isErrorLogin == false then
            self:InitUi()
        end
    else
        self:requestQueryActivity()
    end
    --设置背景回调
    -- setbackgroundcallback(function(bEnter)
    --     if bEnter then
    --         if self._ImageCategoryIndex ~= nil then
                
    --             if self._webView ~= nil then
    --                 --self._webView:reload()
    --                 self._webView:removeFromParent()
    --                 self._webView = nil
    --             end
    --             self:onLoadWebView(self._ImageCategoryIndex)
    --         end
    --     end
    -- end)
    -- 内容跳入
    AnimationHelper.jumpIn(self._content)
    --self:onLoadWebView()
end
function ActivityLayer:InitUi()
    if self._activityList == nil then
        return
    end
    --链接地址
    self._urlArray = {}
    --下载地址
    self._urlDown = {}
    --下载信息
    self._downFileInfo = {}
  

    for i = 1, #self._activityList.PID do
        local checkBox = ccui.CheckBox:create("Activity/LeftBtnBg.png",
                                              "Activity/LeftBtnBg.png",
                                              "Activity/LeftBtnBg_active.png",
                                              "Activity/LeftBtnBg.png",
                                              "Activity/LeftBtnBg.png")
        checkBox:setTouchEnabled(true)
        checkBox:setPosition(cc.p(82+20,536 - (i - 1) * 114))
        checkBox:addEventListener(function(ref, type)
            self:onClickActivetyCategory(i, true)
        end)
        
        checkBox:addTo(self._content)

        local txttitle = ccui.Text:create("活动名称", "fonts/round_body.ttf", 22)
        txttitle:setPosition(cc.p(75, 55))
        print(self._activityList.Title[i])
        local str = self._activityList.Title[i]
        txttitle:setString(str)
        txttitle:addTo(checkBox)
        self._activityCategoryBtns[i] = checkBox
        local infotable = {}
        local ostime = os.time()
        infotable["UserID"] = "" .. GlobalUserItem.dwUserID
        infotable["ActivityID"] = ""..self._activityList.TaskID[i]
        infotable["TimeStamp"] = "" .. ostime
        infotable["Sign"] = GlobalUserItem:getSignature(ostime)
        local action = cjson.encode(infotable)
        action = appdf.encodeBase64(action)
        local prefix = self:getrand()
        if prefix == "" then
            prefix = "abcde"
        end
        action = "?a="..prefix..action
        if string.len(self._activityList.Context[i]) > 10 then
            self._urlArray[i] = self._activityList.Context[i]..action
        else
            self._urlArray[i] = self._activityList.Context[i]
        end
        print(self._urlArray[i])
        self._urlDown[i] = self._activityList.Img[i]--string.sub(self._activityList[i].ImageUrl,1,-8)
        self._downFileInfo[i] = string.sub(self._activityList.Img[i],-7,string.len(self._activityList.Img[i]))
        print(self._urlDown[i])
        print(self._downFileInfo[i])
    end

    --删除之前活动图片
    if self._oldImageInfo.image then
        local delpath = device.writablePath.."client/res/Activity/"
        for k, v in pairs(self._downFileInfo) do
            for k1, v1 in pairs(self._oldImageInfo.image) do
                print(v,"=====",v1)
                if v == v1 then
                    table.remove(self._oldImageInfo.image,k1)
                end
            end
        end
        dump(self._oldImageInfo.image)
        for k1,v1 in pairs(self._oldImageInfo.image) do
            local str = delpath..v1
            if cc.FileUtils:getInstance():isFileExist(str) then
                cc.FileUtils:getInstance():removeFile(str)
            end 
        end
    end
    self._activity:start()
    self:onDownLoadImage()
end
--点击活动分类
function ActivityLayer:onClickActivetyCategory(index, enableSound)
    
    --播放按钮音效
    if enableSound then
        ExternalFun.playClickEffect()
    end

    for i = 1, #self._activityCategoryBtns do
        self._activityCategoryBtns[i]:setSelected(index == i)
    end

    --防止重复执行
    if index == self._gameCategoryIndex then
        return
    end
    self._gameCategoryIndex = index
    for i = 1, #self._imageArray do
        self._imageArray[i]:setVisible(index == i)
    end
    print("切换活动分类", index)
end
function ActivityLayer:addActivityImage()
    for i = 1, #self._downFileInfo do
        local btnImage = ccui.Button:create("Activity/"..self._downFileInfo[i], "Activity/"..self._downFileInfo[i], "Activity/"..self._downFileInfo[i])
        btnImage:setAnchorPoint(0.5, 0.5)
        btnImage:setPosition(self._content:getContentSize().width / 2 + 77, self._content:getContentSize().height / 2-32)
        btnImage:addTo(self._content)
        btnImage:setVisible(false)
        btnImage:addClickEventListener(function()
            self:onClickImage(i)
         end)
        self._imageArray[i] = btnImage
    end
    self:onClickActivetyCategory(1,true)
end
function ActivityLayer:onClickImage(index)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        return
    end
    local len = string.len(self._urlArray[index])
    if len < 10 then
        return
    end
    ExternalFun.playClickEffect()
    --防止重复执行
    if index == self._ImageCategoryIndex then
        return
    end   
    self._ImageCategoryIndex = index
    self:onLoadWebView(index)
    self._webLayout:setVisible(true)
end
function ActivityLayer:onDownLoadImage()
    if self._downIndex == (#self._downFileInfo + 1) then
        self._activity:stop()
        self:addActivityImage()
        self:save()
        return
    end
    local dstpath = device.writablePath.."client/res/Activity/"
    print(dstpath)
    if cc.FileUtils:getInstance():isFileExist(dstpath .. self._downFileInfo[self._downIndex]) then
        print("有图片了还说个卵")
        self._downIndex = self._downIndex +1
        self:onDownLoadImage()
    else
        downFileAsync(self._urlDown[self._downIndex],self._downFileInfo[self._downIndex],dstpath,function(main,sub)
            --对象已经销毁
            if not appdf.isObject(self) then
                return
            end
            --下载回调
            if main == appdf.DOWN_PRO_INFO then --进度信息

            elseif main == appdf.DOWN_COMPELETED then --下载完毕
                table.insert(self._newImageInfo.image,self._downFileInfo[self._downIndex])
                self._downIndex = self._downIndex +1
                self:onDownLoadImage()
            else
                self._activity:stop()
                showToast(nil, "活动加载失败,请关闭页面重试!", 3)
                --判断是否有残留资源,有则删除
                for i = 1, #self._downFileInfo do
                    local movepath = dstpath..self._downFileInfo[i]
                    if cc.FileUtils:getInstance():isFileExist(movepath) then
                        cc.FileUtils:getInstance():removeFile(movepath)
                    end
                end
            end
        end)
    end
end
--调用页面
function ActivityLayer:onLoadWebView(index)
    --平台判定
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        --网页
        self._webView = ccexp.WebView:create()
        self._webView:setAnchorPoint(cc.p(0,0))
        self._webView:setPosition(cc.p(0,0))
        self._webView:setContentSize(cc.size(display.width,display.height))
        self._webView:setScalesPageToFit(true) 
        self._webView:loadURL(self._urlArray[index])
        self._webView:addTo(self._webLayout, ZORDER.WEBVIEW + index)
        self._webView:setVisible(false)
        self._webView:setJavascriptInterfaceScheme("ryweb")

        self._webView:setOnJSCallback(function ( sender, url )
            print("网页回调"..tostring(url))
            if url == "ryweb://param:close" then
		        self:onCloseWeb()
            end
	    end)

        self._webView:setOnShouldStartLoading(function(sender, url)
            self._activity:start()
            return true
        end)
        self._webView:setOnDidFailLoading(function ( sender, url )
            print("WebView_onDidFailLoading, url is ", url)
            self._activity:stop()
            self._webView:removeFromParent()
            self._webView = nil
            self._ImageCategoryIndex = nil
            self._webLayout:getChildByTag(ZORDER.PROMPT):setString("活动加载失败,请关闭页面重试")
            return true
        end)
        self._webView:setOnDidFinishLoading(function(sender, url)
            print("WebView_onDidFinishLoading, url is ", url)
            self._activity:stop()
            --removebackgroundcallback()
            if self._webView ~= nil then
                self._webView:setVisible(true)
            end
            return true
        end)
    else
        return
        -- local btn_close = self._webLayout:getChildByTag(ZORDER.CLOSEBTN)
        -- if btn_close then
        --     btn_close:setVisible(true)
        -- end
    end
end
function ActivityLayer:onCloseWeb()
    self._webLayout:setVisible(false)
    self._webView:removeFromParent()
    self._webView = nil
    self._ImageCategoryIndex = nil
    --请求个人信息
    RequestManager.requestUserScoreInfo(nil)
end

--手机返回按钮
function ActivityLayer:onKeyBack()
    print("返回按钮")
    if nil == self._ImageCategoryIndex then
        return false
    end

    if not self._webView:isVisible() then
        return false 
    end
    if nil ~= self._webView and true == self._webView:canGoBack() then
        self._webView:goBack()
        return true
    else
        print("返回按钮")
        self:onCloseWeb()
        return true
    end
    return false
end
--------------------------------------------------------------------------------------
function ActivityLayer:requestQueryActivity()

    local _self = self
	local actQueryActivityCallBack = function ( result,message2 )
		local action = cjson.encode(message2)
		local message = cjson.decode(message2)
        dump(message)
		if message[1]==3 and message[2] == 103 then
		   if message[3] ~=nil then
                    _self._activityList = message[3]
                if _self._activityList == nil then
                    _self._activity:stop()
                    showToast(nil, "暂无新活动!!!", 3)
                    return
                end
                if appdf.isErrorLogin == false then
                    _self:InitUi()
                end
		   else 
				return
		   end
	
		end
	end
	local _webFrame = WebFrame:create(nil, function(result, message)
        actQueryActivityCallBack(result,message)
    end,true)

    local action = {}
    action["tp"] = 3
    local pargams = {3,3,action}
    local action2 = cjson.encode(pargams)
    dump(action2)
   
    _webFrame:wsSendString(action2) 
    
    -- local url = yl.HTTP_URL .. "/WS/NativeWeb.ashx"
    -- local ostime = os.time()
    -- appdf.onHttpJsionTable(url ,"GET","action=queryactivitystatus&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(jstable,jsdata)

    --     if not appdf.isObject(self) then
    --         return
    --     end
        
    --     if type(jstable) ~= "table" then
    --         return
    --     end

    --     local isNewActivity = jstable["SFTJ"]
    --     --活动列表
    --     self._activityList = jstable["Activitylist"]
    --     dump(self._activityList)
    --     if self._activityList == nil then
    --         self._activity:stop()
    --         showToast(nil, "暂无新活动!!!", 3)
    --         return
    --     end
    --     if appdf.isErrorLogin == false then
    --         self:InitUi()
    --     end

    -- end)
end

--保存图片信息
function ActivityLayer:save()
    if next(self._newImageInfo.image) == nil then
        return
    end
    --保存信息
    cc.FileUtils:getInstance():writeToFile(self._newImageInfo,self._filePath)
end

--获取随机码    
function ActivityLayer:getrand()
    local prefixLable = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    mytime = os.time()
    mytime = string.reverse(mytime)
    math.randomseed(mytime)
    local prefix = ""
    for i = 1, 5 do
        num = math.random(1, 62)
        local letter = string.sub(prefixLable,num, num)
        prefix = prefix..letter
    end
    return prefix
end

return ActivityLayer