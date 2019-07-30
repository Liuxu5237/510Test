--赠送凭证页面
local TransferCertificateLayer = class("TransferCertificateLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

function TransferCertificateLayer:ctor(info)

    local csbNode = ExternalFun.loadCSB("Bank/Certificate/TransferCertificateLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --填充内容
    local txtSourceNickName = self._content:getChildByName("txt_source_nickname")
    local txtSourceGameID = self._content:getChildByName("txt_source_gameid")
    local txtTargetNickName = self._content:getChildByName("txt_target_nickname")
    local txtTargetGameID = self._content:getChildByName("txt_target_gameid")
    local txtScore = self._content:getChildByName("txt_score")
    local txtScoreCN = self._content:getChildByName("txt_score_cn")
    local txtDate = self._content:getChildByName("txt_date")
    local txtCerID = self._content:getChildByName("txt_cer_id")

    --昵称截取
    function cutOut(nickname)
        local signstrtable = ExternalFun.utf8StringSplit(nickname)
        local signstr = ""
        local signlen = 1
        for i = 1, #signstrtable do
            if signlen > 10 then
                break
            end
            local str = signstrtable[i]
            local dropping = string.byte(str)
            if dropping >= 128 then
                signlen = signlen + 2
            else
                signlen = signlen + 1
            end
            signstr = signstr..str
        end
        if signlen > 10 then
            signstr = signstr.."..."
        end
        return signstr
    end

    txtSourceNickName:setString(cutOut(info.SourceNickName))
    txtSourceGameID:setString(info.SourceGameID)
    txtTargetNickName:setString(cutOut(info.TargetNickName))
    txtTargetGameID:setString(info.TargetGameID)
    txtScore:setString(info.Score)
    txtScoreCN:setString(info.ScoreCN)
    txtDate:setString(info.Date)
    txtCerID:setString(info.CerID)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then 
        --不保存关闭
        local btnShare = self._content:getChildByName("btn_share")
        btnShare:loadTextureNormal("Bank/Certificate/zs_btn3.png")
        btnShare:addClickEventListener(function()
            --播放音效
            ExternalFun.playClickEffect()

            dismissPopupLayer(self)
        end)

        --保存并关闭
        local btnSave = self._content:getChildByName("btn_save")
        btnSave:loadTextureNormal("Bank/Certificate/zs_btn4.png")
        btnSave:addClickEventListener(function()
            --播放音效
            ExternalFun.playClickEffect()
            btnShare:setVisible(false)
            btnSave:setVisible(false)
            self._content:getChildByName("btn_close"):setVisible(false)
            self:onClickSaveWithWindows()
        end)
    else
        --分享
        local btnShare = self._content:getChildByName("btn_share")
        btnShare:addClickEventListener(function()

            --播放音效
            ExternalFun.playClickEffect()

            self:onClickShare()
        end)

        --保存
        local btnSave = self._content:getChildByName("btn_save")
        btnSave:addClickEventListener(function()

            --播放音效
            ExternalFun.playClickEffect()

            self:onClickSave()
        end)
    end
    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)
    -- 内容跳入
    AnimationHelper.jumpIn(self._content)
end

--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--点击分享
function TransferCertificateLayer:onClickShare()

    local url = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local areaSize = self._content:getContentSize()
    local scaleX = frameSize.width / appdf.WIDTH
    local scaleY = frameSize.height / appdf.HEIGHT
    local area = cc.rect((appdf.WIDTH - frameSize.width) / 2 * scaleX, (appdf.HEIGHT - frameSize.height) / 2 * scaleY, frameSize.width * scaleX, frameSize.height * scaleY)

    ExternalFun.popupTouchFilter(0, false)

    captureScreenWithArea(area, "ce_code.png", function(ok, savepath)
        ExternalFun.dismissTouchFilter()
        if ok then
            MultiPlatform:getInstance():customShare(function(isok)
                        end, "转账凭证", "分享我的转账凭证", url, savepath, "true")
        end
    end)
end

--点击保存
function TransferCertificateLayer:onClickSave()

    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local areaSize = self._content:getContentSize()
    local scaleX = frameSize.width / appdf.WIDTH
    local scaleY = frameSize.height / appdf.HEIGHT
    local area = cc.rect((appdf.WIDTH - frameSize.width) / 2 * scaleX, (appdf.HEIGHT - frameSize.height) / 2 * scaleY, frameSize.width * scaleX, frameSize.height * scaleY)

    ExternalFun.popupTouchFilter(0, false)

    captureScreenWithArea(area, "ce_code.png", function(ok, savepath)         
        ExternalFun.dismissTouchFilter()
        if ok then
            if true == MultiPlatform:getInstance():saveImgToSystemGallery(savepath, os.time() .. "_ce_code.png") then
                showToast(nil, "您的转账凭证图片已保存至系统相册", 2)
            end
        end
    end)
end

function TransferCertificateLayer:onClickSaveWithWindows()
    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local areaSize = self._content:getContentSize()
    local scaleX = frameSize.width / appdf.WIDTH
    local scaleY = frameSize.height / appdf.HEIGHT
    local area = cc.rect((appdf.WIDTH - areaSize.width) / 2 * scaleX, (appdf.HEIGHT - areaSize.height) / 2 * scaleY, areaSize.width* scaleX, areaSize.height* scaleY)
    ExternalFun.popupTouchFilter(0, false)

    captureScreenWithArea(area, "ce_code.png", function(ok, savepath)         
        ExternalFun.dismissTouchFilter()
        if ok and CopyImage then
            local result = CopyImage(savepath)
            if result then
                showToast(nil, "图片已复制到剪贴板", 2)
                dismissPopupLayer(self)
            else
                showToast(nil, "图片保存失败,请重试", 2)
                self._content:getChildByName("btn_close"):setVisible(true)
                self._content:getChildByName("btn_share"):setVisible(true)
                self._content:getChildByName("btn_save"):setVisible(true)
            end
            -- local result = SaveScreenShot(savepath);

            -- if result then
            --     showToast(nil, "图片保存成功", 2)
            --     dismissPopupLayer(self)
            -- else
            --     self._content:getChildByName("btn_close"):setVisible(true)
            --     self._content:getChildByName("btn_share"):setVisible(true)
            --     self._content:getChildByName("btn_save"):setVisible(true)
            -- end
        else
            showToast(nil, "图片保存失败,请重试", 2)
            self._content:getChildByName("btn_close"):setVisible(true)
            self._content:getChildByName("btn_share"):setVisible(true)
            self._content:getChildByName("btn_save"):setVisible(true)
        end
    end)
end

return TransferCertificateLayer