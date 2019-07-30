module("DSCommon", package.seeall)
local isShowLog = true

--临时变量 //********
g_eLoginType = nil	--登录类型
g_zsInsurePass = nil -- 银行密码
g_gameState = 0
g_tGameState = {
	login = 0,
	hall = 1,
	game = 2,
}
--锁表信息
g_nLocketRoom = 
	{
		nServerId = nil, --锁表房间serverid
		nKindId = nil, --锁表房间kindid

		mServerId = nil, --表房间serverid
		mKindId = nil, --表房间kindid
		mRoomId = nil, --房间的房间号
	}


---************************//
ds = ds or {}
ds.common = {}

ds.log = function( ... )
	if (isShowLog) then
		print(...)
	end
end

ds.error = function( ... )
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
    	buglyReportLuaException(tostring(...), debug.traceback())
    end
end
--字体
ds.common.ZI_MARKERFELT = "fonts/MarkerFelt.ttf"
ds.common.ZI_ARIAL = "fonts/arial.ttf"

--loading的层级为1000
ds.common.LOADING_Z_ORDER = 1000

--默认登录密码
ds.common.DEFAULT_LOGINPASSWD = "079196169"

--微信头像的名字
ds.common.WEBCHAT_URL="webchat_profile_url.png"

--登录类型
ds.common.LoginType ={
	LoginType_Account = 1,	--账号登录
	LoginType_Visitor = 2,	--游客登录
	LoginType_Webchat = 3,	--微信登录
}

local tHeadLoad = {
	IMG_HEAD_PHOTO_1 = "TX-1.png",
	IMG_HEAD_PHOTO_2 = "TX-2.png",
	IMG_HEAD_PHOTO_3 = "TX-3.png",
	IMG_HEAD_PHOTO_4 = "TX-4.png",
	IMG_HEAD_PHOTO_5 = "TX-5.png",
	IMG_HEAD_PHOTO_6 = "TX-6.png",
	IMG_HEAD_PHOTO_7 = "TX-7.png",
	IMG_HEAD_PHOTO_8 = "TX-8.png",
	IMG_HEAD_PHOTO_9 = "TX-9.png",
	IMG_HEAD_PHOTO_10 = "TX-10.png",
}


ds.common.ConvertFunc = function(strFunc, ...)
	local nPoint = string.find(strFunc, "%.")
	if nPoint == nil then
		return _G[strFunc]
	else
		local strModuleName = string.sub(strFunc, 1, nPoint-1)
		local strName = string.sub(strFunc, nPoint+1)
		local module = _G[strModuleName]	
		if module ~= nil then
			local mPoint = string.find(strName, "%:")
			if (mPoint == nil) then
				return module[strName]
			else
				local strClassName = string.sub(strName, 1, mPoint-1)
				local strFuncName = string.sub(strName, mPoint+1)
				if (type(module[strClassName]) == "table") then
					return module[strClassName][strFuncName]
				else
					return nil
				end
				
			end
		end
	end
end

--深拷贝
ds.common.deepcopy = function(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end  
        return setmetatable(new_table, getmetatable(object))
    end 
    return _copy(object)
end

--淡入淡出
ds.common.MyFadout = function(node,action)
	-- if(action~=nil) then
		-- node:runAction(action);
	-- end
	local child = GetAllChild(node);
	--print("所有子对象=",node:getChildrenCount());
	node:setCascadeColorEnabled(true);
    node:setCascadeOpacityEnabled(true);
	--local ac = action:clone();

	for k,v in pairs(child) do
		v:setCascadeColorEnabled(true);
		v:setCascadeOpacityEnabled(true);
	end	
	node:runAction(action);
end

function GetAllChild(parent) 
local node_list = {} 
local children = parent:getChildren()

    local function seach_child(parente)
        local childCount = parente:getChildrenCount()
        if childCount < 1 then
            node_list[parente:getName()] = parente
        else 
            for i = 1, childCount do
                dump(parente)
                node_list[parente:getName()] = parente
                seach_child(parente:getChildren()[i])
            end
        end
    end 

	for k , v in next ,children do 
    	if #v:getChildren() < 1 then
        	node_list[v:getName()] = v
        else
        	seach_child(v)
    	end
	end
	return node_list
end


ds.common.YRComGetHeadImageById = function(head_id)
	local headImg = tHeadLoad.IMG_HEAD_PHOTO_1
	if (head_id == 0) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_1
	elseif (head_id == 1) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_2
	elseif (head_id == 2) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_3
	elseif (head_id == 3) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_4
	elseif (head_id == 4) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_5
	elseif (head_id == 5) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_6
	elseif (head_id == 6) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_7
	elseif (head_id == 7) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_8
	elseif (head_id == 8) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_9
	elseif (head_id == 9) then
		headImg = tHeadLoad.IMG_HEAD_PHOTO_10
	end

	return headImg
end


ds.common.InitTable = function (Tab, value)
	if (type(Tab) ~= "table") then
		ds.log("Please input table")
	end

	for k, v in pairs(Tab) do
		if (type(v) == "table") then
			ds.common.CleanupTable(Tab[k])
		else
			Tab[k] = value
		end
	end
end

ds.common.CleanupTable = function (Tab, value)
	if (type(Tab) ~= "table") then
		ds.log("Please input table")
	end

	for k, v in pairs(Tab) do
		Tab[k] = nil
	end
end

--去字符串的长度，中文也是算是一个字符
ds.common.GetStringWordNum = function(str)
    local fontSize = 20
    local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
           	byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        i = i + byteCount
        count = count + 1
    end
    return count
end

ds.common.GetTableLenth = function (Tab)
	if (type(Tab) ~= "table") then
		ds.log("Please input table")
		return 0
	end

	local len = 0 
	for k, v in pairs(Tab) do
		len = len + 1
	end

	return len
end


ds.common.printTab = function(tab)
	ds.log(json.encode(tab))
end

ds.common.split = function(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
   	  local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
  	  if not nFindLastIndex then
    	nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
    	break
   	  end
   	  nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
      nFindStartIndex = nFindLastIndex + string.len(szSeparator)
      nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end


ds.common.setClippingType = function(obj)
	if (obj == nil) then
		ds.log("error:please input obj")
		return
	end
	
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (targetPlatform == cc.PLATFORM_OS_MAC or targetPlatform == cc.PLATFORM_OS_ANDROID or targetPlatform == cc.PLATFORM_OS_IPHONE
        or targetPlatform == cc.PLATFORM_OS_IPAD) then
    else
       	obj:setClippingType(ccui.ClippingType.scissor)
    end
end


ds.common.playBackMusic = function(isReplay)
	local bState = cc.UserDefault:getInstance():getBoolForKey("canPlayMusic",true)
	if (bState == false) then
		return
	end
	
	if (isReplay) then
		ds.SoundManager:shared():stopMusic()
	end
	
	if ds.SoundFun:Instance():GetIsPalyMusic() then
		ds.SoundFun:Instance():playBackMusic("platform_background.mp3")
	end
end


ds.common.playButtonClickEffect = function(EffectName, bPreload)
	local bState = cc.UserDefault:getInstance():getBoolForKey("canPlayEffect",true)
	if (bState == false) then
		return
	end
	bPreload = bPreload or false
	EffectName = EffectName or "platform_sound_button.mp3"
	ds.SoundFun:Instance():playEffect(EffectName, bPreload)
end

ds.common.playButtonCloseEffect = function(EffectName, bPreload)
	local bState = cc.UserDefault:getInstance():getBoolForKey("canPlayEffect",true)
	if (bState == false) then
		return
	end
	bPreload = bPreload or false
	EffectName = EffectName or "platform_sound_close.mp3"
	ds.SoundFun:Instance():playEffect(EffectName, bPreload)
end

-- 判断输入的账号或密码 是否仅包括字母和数字
ds.common.IsAccountPasswrod = function(szString)
	local len = #szString
	local asc_value = 0
	for i=1, len do
		asc_value = string.byte(szString,i)
		if asc_value == 0 and i == len then
			return true
		elseif (asc_value < 48 or asc_value > 122) then
			return false
		elseif (asc_value > 57 and asc_value < 65) or (asc_value > 90 and asc_value < 97) then
			return false		
		end
	end
	return true
end

-- 判断输入的是否是类似电话号码的纯数字，(仅包含0~9，也不能有小数点)
ds.common.IsPhoneNumber = function(szString)  
	local len = #szString
	local asc_value = 0
	for i=1, len do
		asc_value = string.byte(szString,i)
		if (asc_value < 48 or asc_value > 57) then
			return false
		end
	end
	return true
end

--传人数字，大于10000用万，和亿
ds.common.GetNumberOfShort = function (num)
	if (type(num) ~= "number") then
		return num
	end
	local str = num
	if (num >= 100000000) then
		str =  num/100000000
        local length  = string.len(str)
        if length >5 then
        
            str = string.sub(str,1,5)
            local pos = string.find(str,"%.")
            if pos == 5 then
             
                str = string.sub(str,1,4)        
            end 
              
        end
        
		str = str..ds.StringData:shared():stringFromKey("big_num5")
	elseif (num >= 10000) then
		str = num/10000
        local length  = string.len(str)
        if length >5 then
            str = string.sub(str,1,5)
            local pos = string.find(str,"%.")
            if pos == 5 then
             
                str = string.sub(str,1,4)        
            end 
        end
		str = str..ds.StringData:shared():stringFromKey("big_num4")
	end

	return str
end

--名字太长，简化字符
ds.common.splitName = function(name, length)
	local nLength = ds.common.GetStringWordNum(name)
	
	if nLength > length then
		local nickname = SubStringUTF8(name,1,6).."..."
		return nickname
	else
		return name
	end

	
end

function SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then 
        return string.sub(str, SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

function SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end



--返回当前字符实际占用的字符数
function SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end



--获取中英混合UTF8字符串的真实字符数量
function SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end