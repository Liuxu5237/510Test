module("DSLabel", package.seeall)

local DSLabel = class("DSLabel")
DSLabel.__index = DSLabel
DSLabel.__stringText = ""
DSLabel.__FontSize = 0

function DSLabel.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, DSLabel)
    return target
end

function DSLabel:Init(strText, fontSize)
    local node = cc.Node:create()
    local xPos = 0
    for i=1,10 do
        if strText ~= nil then
            for n,m in pairs(DSCommon.DSStringColor) do
                local x,y = string.find(strText,m[1])
                if x ~= nil then
                    if x == 1 then
                        local k,l = string.find(strText,"<E>")
                        if k then
                            local title = string.sub(strText,string.len(m[1])+1,k-1)
                            local label = cc.LabelTTF:create(title, ds.common.ZI_MARKERFELT, fontSize)
                            label:setColor(m[2])
                            label:setAnchorPoint(cc.p(0, 0))
                            label:setPosition(cc.p(xPos,0))
                            node:addChild(label,0)
                            xPos = xPos +label:getContentSize().width
                            strText = string.sub(strText,k+3)
                        end
                        break
                    else
                        local o,p = string.find(strText,"<#")
                        if o ~= 1 then
                            local title = string.sub(strText,1,o-1)
                            local label = cc.LabelTTF:create(title, ds.common.ZI_MARKERFELT, fontSize)
                            label:setAnchorPoint(cc.p(0, 0))
                            label:setPosition(cc.p(xPos,0))
                            node:addChild(label,0)
                            xPos = xPos +label:getContentSize().width
                            strText = string.sub(strText,o)
                            break
                        end
                    end
                else        
                    if i == 10 and n == #DSCommon.DSStringColor then
                        local label = cc.LabelTTF:create(strText, ds.common.ZI_MARKERFELT, fontSize)
                        label:setAnchorPoint(cc.p(0, 0))
                        label:setPosition(cc.p(xPos,0))
                        node:addChild(label,0)
                        xPos = xPos + label:getContentSize().width
                        strText = nil
                        break
                    end
                end
            end
        end
    end
    
    node:setContentSize(cc.size(xPos,fontSize))

    return node
end

function DSLabel:GetLabel(strText, fontSize, defaultY)
    if strText == nil then
        return
    end
    fontSize = fontSize or 18
    defaultY = defaultY or 5
    local tColorLabel = {}
    for i = 1,10 do
        local k,l = string.find(strText,"<M>")
        if k ~= nil then
            local title = string.sub(strText,1,k-1)
            local label = self:Init(title,fontSize)
            tColorLabel[#tColorLabel + 1] = label
            strText = string.sub(strText,l + 1)
        else
            local label = self:Init(strText,fontSize)
            tColorLabel[#tColorLabel + 1] = label
            strText = nil
            break
        end
    end
    
    local width = tColorLabel[1]:getContentSize().width
    local height = (tColorLabel[1]:getContentSize().height + defaultY)*#tColorLabel
    self:setContentSize(cc.size(width,height))
    for j = 1,#tColorLabel do
        tColorLabel[j]:setAnchorPoint(cc.p(0, 1))
        tColorLabel[j]:setPosition(cc.p(0,height - (defaultY + tColorLabel[1]:getContentSize().height)*j))                
        self:addChild(tColorLabel[j],0)
    end
end

function DSLabel:ResetColorLabel(strText, fontSize, defaultY)
    local parent = self:getParent()
    local x,y = self:getPosition()
    local anchor = self:getAnchorPoint()
    self:removeFromParent(true)
    local label = DSLabel.extend(cc.Node:create())
    label:GetLabel(strText, fontSize)
    label.__stringText = strText
    label.__FontSize = fontSize

    label:setAnchorPoint(anchor)
    label:setPosition(cc.p(x, y))
    parent:addChild(label,0,10)

    return label
end

--strText:需要显示的文本
--fontSize:文本字体大小
--defaultY:字体间的间距
function create(strText, fontSize, defaultY)
    local label = DSLabel.extend(cc.Node:create())
    label:GetLabel(strText, fontSize, defaultY)
    label.__stringText = strText
    label.__FontSize = fontSize

    return label
end