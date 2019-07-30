--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")


local KefuLayer = class("KefuLayer",function()
	local ServiceLayer =  display.newLayer()
    return ServiceLayer
end)

function KefuLayer:ctor()

    local winSize = cc.Director:getInstance():getVisibleSize()
    local  node = cc.CSLoader:createNode("public/FefeLayer.csb")
    node:setScale(winSize.width / 1334,winSize.height / 750)
    node:addTo(self) 

    local msg = {
                    "xyqp7777",
                    "xyqp5555",
                    "xygc7777",
                }

    local function onToucher(touch,event)
        if event == ccui.TouchEventType.ended then
            self:removeFromParent()
        end   
    end

    local function onTouchers(touch,event)

    end
     self._panel = node:getChildByName("Panel_3")
     self._panel:setTouchEnabled(true)
     self._panel:addTouchEventListener(onToucher)

     local _panel = node:getChildByName("Image_2")
     _panel:setTouchEnabled(true)
     _panel:addTouchEventListener(onTouchers)
     _panel:setScale(0.000001)

     local function copyTouch(sender,eventtouch)
     if eventtouch == ccui.TouchEventType.ended then
         local url = msg[sender:getTag()]
		local res, msg = MultiPlatform:getInstance():copyToClipboard(url)
		if true == res then
			    showToast(self, "复制到剪贴板成功!", 1)
		else
			    if type(msg) == "string" then
				    showToast(self, msg, 1, cc.c3b(250,0,0))
			    end
		    end
        end    
     end

     local btn = _panel:getChildByName("Button_1")
     btn:addTouchEventListener(copyTouch)
     btn:setTag(1)

     btn = _panel:getChildByName("Button_2")
     btn:addTouchEventListener(copyTouch)
     btn:setTag(2)

     btn = _panel:getChildByName("Button_3")
     btn:addTouchEventListener(copyTouch)
     btn:setTag(3)

     local scale = cc.ScaleTo:create(0.2,1.0)
     _panel:runAction(cc.Sequence:create(scale))
end




return KefuLayer