--[[
	常用定义
]]
appdf = appdf or {}

appdf.isErrorLogin                             = false     ---错误修复开关
--屏幕高宽
appdf.WIDTH									= 1334
appdf.HEIGHT								= 750
appdf.g_scaleX                              = display.width / appdf.WIDTH           --X坐标的缩放比例值 added ycc
appdf.g_scaleY                              = display.height / appdf.HEIGHT         --Y坐标的缩放比例值 added ycc

appdf.DEF_FONT                              = "fonts/round_body.ttf"                --默认字体

appdf.BASE_SRC                              = "base.src."
appdf.CLIENT_SRC                            = "client.src."
appdf.GAME_SRC                              = "game."

--扩展目录
appdf.EXTERNAL_SRC							= "client.src.external."
--通用定义目录
appdf.HEADER_SRC							= "client.src.header."
--私人房目录
appdf.PRIVATE_SRC                           = "client.src.privatemode."


--渠道SDK目录

appdf.CHANNE_SDK_SRC					  = "client.src.external.sdk."
--下载信息
appdf.DOWN_PRO_INFO							= 1 									--下载进度
appdf.DOWN_COMPELETED						= 3 									--下载结果
appdf.DOWN_ERROR_PATH						= 4 									--路径出错
appdf.DOWN_ERROR_CREATEFILE					= 5 									--文件创建出错
appdf.DOWN_ERROR_CREATEURL					= 6 									--创建连接失败
appdf.DOWN_ERROR_NET		 				= 7 									--下载失败

--程序版本
appdf.BASE_C_VERSION = 3 --@app_version

--PC程序版本
appdf.BASE_C_WINDOWS_VERSION = 1

appdf.BASE_C_RESVERSION = 30 --@client_version
--渠道号  这里渠道号在welcomeScene里面读取本地文件 不会去热更
appdf.CHANNEL_ID = 1

appdf.NoterGameList={
{KindID="27",   KindName="四人牛牛",  TypeID="0", ModuleName="yule.OxNew",         ClientVersion="101122049",ResVersion="1",SortID="22", KindMark="3"},
{KindID="36",   KindName="通比牛牛",  TypeID="0", ModuleName="yule.oxsixex",       ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="102",  KindName="二人牛牛",  TypeID="0", ModuleName="yule.oxex",          ClientVersion="101122049",ResVersion="1",SortID="0",  KindMark="3"},
{KindID="104",  KindName="百人牛牛",  TypeID="0", ModuleName="yule.oxbattle",      ClientVersion="101122049",ResVersion="1",SortID="0",  KindMark="3"},
{KindID="118",  KindName="百人骰宝",  TypeID="0", ModuleName="yule.sicbobattle",   ClientVersion="101122049",ResVersion="0",SortID="16", KindMark="3"},
{KindID="122",  KindName="百家乐",    TypeID="0", ModuleName="yule.baccaratnew",   ClientVersion="101122049",ResVersion="0",SortID="17", KindMark="3"},
{KindID="140",  KindName="豪车俱乐部",TypeID="0", ModuleName="yule.luxurycar",     ClientVersion="101122049",ResVersion="2",SortID="0",  KindMark="3"},
{KindID="200",  KindName="斗地主",    TypeID="0", ModuleName="qipai.land",         ClientVersion="101122049",ResVersion="1",SortID="23", KindMark="3"},
{KindID="516",  KindName="水浒传",    TypeID="0", ModuleName="yule.WaterMargin",   ClientVersion="101122049",ResVersion="0",SortID="17", KindMark="3"},
{KindID="601",  KindName="大闹天宫",  TypeID="0", ModuleName="yule.Dntg",          ClientVersion="101122049",ResVersion="1",SortID="0",  KindMark="3"},
{KindID="2068", KindName="幸运财神",  TypeID="0", ModuleName="yule.godofwealth",   ClientVersion="101122049",ResVersion="1",SortID="0",  KindMark="3"},
{KindID="998",  KindName="龙虎斗",    TypeID="0", ModuleName="yule.longhu",	       ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="13",  KindName="封神榜",    TypeID="0", ModuleName="yule.fengshenbang",   ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="2075", KindName="水果拉霸",  TypeID="0", ModuleName="yule.thediscovery",  ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="14", 	KindName="李逵劈鱼8人",  TypeID="0", ModuleName="yule.yule.fishlk8",  ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="20", 	KindName="摇钱树",  TypeID="0", ModuleName="yule.xyaoqianshu",  	ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="21", 	KindName="金蟾捕鱼",  TypeID="0", ModuleName="yule.xjcby",  		ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="22", KindName="熊猫捕鱼",  	TypeID="0", ModuleName="yule.xlkpy",  		ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="30", KindName="潘金莲", 	 TypeID="0", ModuleName="yule.panjinlian",  	ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="31", KindName="熊之舞",  	TypeID="0", ModuleName="yule.bonusbears",  		ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="32", KindName="樱桃女郎",  TypeID="0", ModuleName="yule.cherrylove",  		ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},
{KindID="34", KindName="西游",  	TypeID="0", ModuleName="yule.xiyou",  			ClientVersion="101122049",ResVersion="0",SortID="0",  KindMark="3"},

}             

--自带游戏
appdf.BASE_GAME = 
{
	--{kind = 25,version = "0"},      --港式五张
    --{kind = 200,version = "8"},     --斗地主
    --{kind = 36,version = "0"},      --通比牛牛
}

--环境

appdf.ENV     = 2                   --没用(1.香港 2.正式服 3外网测试 4内网测试
appdf.HTTP_URLS = {
	
	"https://hk01.5185931.com",
	"https://bpi.hjy510.com",
	"http://59.111.94.110:8080",
	"http://192.168.31.242:8011",

}


appdf.HTTP_SERVER_URLS = {
	"https://001.5185931.com",
	"https://bpi.hjy510.com",
	"https://001.5185931.com",
	"http://192.168.31.242:8011",
}
--登陆服务器
appdf.SERVER_LIST = {
	"hklogin01.5185931.com",
	"logon.hjy510.com",
	"001.5185931.com",
	"192.168.31.81",                                        
}

--公告地址
appdf.HTTP_NOTICE_URL_LIST = {

}


--http请求链接地址
appdf.HTTP_URL								= appdf.HTTP_URLS[appdf.ENV]            --网站地址

--http请求后端服务地址
appdf.HTTP_SERVER_URL                       = appdf.HTTP_SERVER_URLS[appdf.ENV]     --后端地址

--登录服务器地址
appdf.LOGONSERVER                           = appdf.SERVER_LIST[appdf.ENV]          --登录地址

--公告地址
appdf.HTTP_NOTICE_URL                       = appdf.HTTP_NOTICE_URL_LIST[appdf.ENV] --公告地址

function appdf.req(path)
    if path and type(path) == "string" then
        return require(path)
    else
        print("require paht unknow")
    end
    
end
-- 字符分割
function appdf.split(str, flag)
	local tab = {}
	while true do

		local n = string.find(str, flag)
		if n then
			local first = string.sub(str, 1, n-1) 
			str = string.sub(str, n+1, #str) 
			table.insert(tab, first)
		else
			table.insert(tab, str)
			break
		end
	end
	return tab
end

--依据宽度截断字符
function appdf.stringEllipsis(szText, sizeE,sizeCN,maxWidth)
	--当前计算宽度
	local width = 0
	--截断位置
	local lastpos = 0
	--截断结果
	local szResult = "..."
	--完成判断
	local bOK = false
	 
	local i = 1
	 
	while true do
		local cur = string.sub(szText,i,i)
		local byte = string.byte(cur)
		if byte == nil then
			break
		end
		if byte > 128 then
			if width +sizeCN <= maxWidth - 3*sizeE then
				width = width +sizeCN
				 i = i + 3
				 lastpos = i+2
			else
				bOK = true
				break
			end
		elseif	byte ~= 32 then
			if width +sizeE <= maxWidth - 3*sizeE then
				width = width +sizeE
				i = i + 1
				lastpos = i
			else
				bOK = true
				break
			end
		else
			i = i + 1
			lastpos = i
		end
	end
	 
	 	if lastpos ~= 0 then
			szResult = string.sub(szText, 1, lastpos)
			if(bOK) then
				szResult = szResult.."..."
			end
		end
		return szResult
end

--打印table
function appdf.printTable(dataBuffer)
	if not dataBuffer then
		print("printTable:dataBuffer is nil!")
		return
	end
	if type(dataBuffer) ~= "table" then
		print("printTable:dataBuffer is not table!")
		return
	end
	for k ,v in pairs(dataBuffer) do
		local typeinfo = type(v) 
		if typeinfo == "table" then
			appdf.printTable(v)
		elseif typeinfo == "userdata" then
			print("key["..k.."]value[userdata]")
		elseif typeinfo == "boolean" then
			print("key["..k.."]value["..(v and "true" or "false").."]")
		else
			print("key["..k.."]value["..v.."]")
		end
	end

end

function appdf.onHttpImage(url,path, filename,callback)
	local xhr = cc.XMLHttpRequest:new()
	
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)
	local function onDownloadImage()
	    print("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
	    local ncode = 0
	    local msg = ""
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	        local fileData = xhr.response
	        local fullFileName = path..filename--cc.FileUtils:getInstance():getWritablePath() .. "/" .. "head.png"
	        local str = string.sub(path, -1)
	        if str ~= "/" then
	        	fullFileName = path.."/"..filename
	        end
	        
	        local file = io.open(fullFileName,"wb")
	        file:write(fileData)
	        file:close()
	        ncode = 0
	        msg = "downloadsuccess"
	        
	        --local texture2d = cc.Director:getInstance():getTextureCache():addImage(fullFileName)
	        --if texture2d then
	        	
	        --end
	    else
	    	ncode = -1
	    	msg = "downloadfail"
	    end
	    if type(callback) == "function" then
	    	print("下载完成消息:","ncode=",ncode,"msg = ",msg,"filename = ",filename )
	    	callback(ncode, msg, filename)
	    end
	end
	xhr:registerScriptHandler(onDownloadImage)
	xhr:send()
end

--HTTP获取json
function appdf.onHttpJsionTable(url,methon,params,callback)
	
    if params ~= nil and params ~= "" then
        print("[appdf.onHttpJsionTable] "..url.."?"..params)
	else
		print("[appdf.onHttpJsionTable] "..url)
	end

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local bPost = ((methon == "POST") or (methon == "post"))

	--模式判断
	if not bPost then
		if params ~= nil and params ~= "" then
			xhr:open(methon, url.."?"..params)
		else
			xhr:open(methon, url)
		end
	else
		xhr:open(methon, url)
	end
	--HTTP回调函数
	local function onJsionTable()
		local datatable 
		local response
		local ok
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	   		response  = xhr.response -- 获得响应数据

	   		if response then
			   print("-response-".. response)
	   		    ok, datatable = pcall(function()
			       return cjson.decode(response)
			    end)
			    if not ok then
			    	print("onHttpJsionTable_cjson_error")
			    	datatable = nil
			    end
		    end
	    else
	    	print("onJsionTable http fail readyState:"..xhr.readyState.."#status:"..xhr.status)
	    end
	    if type(callback) == "function" then
	    	callback(datatable,response)
	    end	    
	end
	xhr:registerScriptHandler(onJsionTable)
	if not bPost then
		xhr:send()
	else
		xhr:send(params)
	end
	return true
end

--创建版本
function appdf.ValuetoVersion(value)
	if not value then
		return {p=0,m=0,s=0,b=0}
	end
	local tmp 
	if type(value) ~= "number" then
		tmp = tonumber(value)
	else
		tmp = value
	end
	return
	{
		p = bit:_rshift(bit:_and(tmp,0xFF000000),24),
		m = bit:_rshift(bit:_and(tmp,0x00FF0000),16),
		s = bit:_rshift(bit:_and(tmp,0x0000FF00),8),
		b = bit:_and(tmp,0x000000FF)
	}
end

function appdf.encodeBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end

    return s64
end

function appdf.decodeBase64(str64)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local temp={}
    for i=1,64 do
        temp[string.sub(b64chars,i,i)] = i
    end
    temp['=']=0
    local str=""
    for i=1,#str64,4 do
        if i>#str64 then
            break
        end
        local data = 0
        local str_count=0
        for j=0,3 do
            local str1=string.sub(str64,i+j,i+j)
            if not temp[str1] then
                return
            end
            if temp[str1] < 1 then
                data = data * 64
            else
                data = data * 64 + temp[str1]-1
                str_count = str_count + 1
            end
        end
        for j=16,0,-8 do
            if str_count > 0 then
                str=str..string.char(math.floor(data/math.pow(2,j)))
                data=math.mod(data,math.pow(2,j))
                str_count = str_count - 1
            end
        end
    end

    local last = tonumber(string.byte(str, string.len(str), string.len(str)))
    if last == 0 then
        str = string.sub(str, 1, string.len(str) - 1)
    end
    return str
end

--创建颜色
function appdf.ValueToColor( r,g,b )
	r = r or 255
	g = g or 255
	b = b or 255
	if type(r) ~= "number" then
		r = 255
	end
	if type(g) ~= "number" then
		g = 255
	end
	if type(b) ~= "number" then
		b = 255
	end

	local c = 0
	c = bit:_lshift(bit:_and(0, 255),24)
	c = bit:_or(c, bit:_lshift(bit:_and(r, 255),16))
	c = bit:_or(c, bit:_lshift(bit:_and(g, 255),8))
	c = bit:_or(c, bit:_and(b, 255))

	return c
end

--版本值
function appdf.VersionValue(p,m,s,b)

	local v = 0
	if p ~= nil then
		v = bit:_or(v,bit:_lshift(p,24))
	end
	if m ~= nil then
		v = bit:_or(v,bit:_lshift(m,16))
	end
	if s ~= nil then
		v = bit:_or(v,bit:_lshift(s,8))
	end
	if b ~= nil then
		v = bit:_or(v,b)
	end

	return v
end

---根據名稱取node
function appdf.getNodeByName(node,name)
	local curNode = node:getChildByName(name)
	if curNode then
		return curNode
	else
		local  nodeTab = node:getChildren()
		if #nodeTab>0 then		
			for i=1,#nodeTab do
				local  result = appdf.getNodeByName(nodeTab[i],name)
				if result then					
					return result
				end 
			end
		end

	end
end

--判断是否对象
function appdf.isObject(obj)
    return (obj.__cname ~= nil)
end