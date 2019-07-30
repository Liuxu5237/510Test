module("DSEditBox", package.seeall)
local DSEditBox = class("DSLabel")
DSEditBox._index = DSEditBox

function DSEditBox.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, DSLabel)
    return target
end

-- cc.KEYBOARD_RETURNTYPE_GO
-- cc.KEYBOARD_RETURNTYPE_DONE
-- cc.KEYBOARD_RETURNTYPE_SEND
-- cc.KEYBOARD_RETURNTYPE_SEARCH
-- cc.KEYBOARD_RETURNTYPE_DEFAULT

--设置键盘的类型
function DSEditBox:setReturnType(type)
	self:setReturnType(type)
end

-- cc.EDITBOX_INPUT_MODE_ANY
-- cc.EDITBOX_INPUT_MODE_URL
-- cc.EDITBOX_INPUT_MODE_DECIMAL
-- cc.EDITBOX_INPUT_MODE_NUMERIC
-- cc.EDITBOX_INPUT_MODE_EMAILADDR
-- cc.EDITBOX_INPUT_MODE_SINGLELINE
-- cc.EDITBOX_INPUT_MODE_PHONENUMBER
--设置输入的模式
function DSEditBox:setInputMode(type)
	self:setInputMode(type)
end

-- cc.EDITBOX_INPUT_FLAG_PASSWORD
-- cc.EDITBOX_INPUT_FLAG_SENSITIVE
-- cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD
-- cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE
-- cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_ALL_CHARACTERS
--设置输入方式（设置密码一类的）
function DSEditBox:setInputFlag(type)
	self:setInputFlag(type)
end


--editBoxSize:大小
--BgPic:背景图
--FontSize:字体大小（好像无效）
--FontColor：默认字体颜色
--HolderStr：默认字符
--Color：输入字体颜色
--MaxLength：最大长度

function create(editBoxSize, BgPic, FontSize, FontColor, HolderStr, Color, MaxLength,FontName)
	BgPic = BgPic or "common/touming.png"
	FontSize = FontSize or 10
	FontColor = FontColor or cc.c3b(0,0,0)
	HolderStr = HolderStr or ""
	Color = Color or cc.c3b(0,0,0)
	MaxLength = MaxLength or 20
	editBoxSize = editBoxSize or cc.size(100,100)
	FontName = FontName or ds.common.ZI_MARKERFELT

    local editBox = DSEditBox.extend(cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create(BgPic),cc.Scale9Sprite:create(BgPic),cc.Scale9Sprite:create(BgPic)))
    editBox:setFontSize(FontSize)
    editBox:setFontColor(FontColor)
    editBox:setPlaceHolder(HolderStr)
    editBox:setPlaceholderFontColor(Color)
    editBox:setMaxLength(MaxLength)
	local lengthmax = editBox:getMaxLength()
	if FontName ~= nil then
		editBox:setFontName(FontName)
	end
    return editBox
end