--请求管理器
local RequestManager = class("RequestManager")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")


local function _callback(c, r, m)
    
    if c then
        c(r, m)
    end
end

function RequestManager.LotteryConfigCallBack( result,message2 ,callback)
    print("奖品配置")
    print(message2)
    local action = cjson.encode(message2)
    local message = cjson.decode(message2)

    if message[1] == 3 and message[2] == 104 then
        
        if type(message[3]) == "table" then
            for i=1,#message[3] do
                 --配置转盘
                local lottery2 = message[3][i]
                local lottery = lottery2[1]

                GlobalUserItem.dwLotteryQuotas[i] = lottery[3]
                if lottery[2] == 20 then
                    GlobalUserItem.cbLotteryTypes[i] = 0
                elseif lottery[2]==21 then
                    GlobalUserItem.cbLotteryTypes[i] = 1
                    GlobalUserItem.dwLotteryQuotas[i] = GlobalUserItem.dwLotteryQuotas[i] / 100
                end
            end

            --抽奖已配置
            GlobalUserItem.bLotteryConfiged = true

            _callback(callback, 0)

            return
        end
        _callback(callback, -1, "数据获取失败")
    end


end
--获取抽奖奖品配置
function RequestManager.requestLotteryConfig(callback)

    local _webFrame = WebFrame:create(nil, function(result, message)
        if RequestManager.LotteryConfigCallBack then
			RequestManager.LotteryConfigCallBack(result,message,callback)
		end
    end,true)

    local action = {}
    action["taskid"] = 1001
    local pargams = {3,4,action}

    local action = cjson.encode(pargams)
    dump(action)
    _webFrame:wsSendString(action) 

end


function RequestManager.UserScoreInfoCallBack( result,message2 ,callback )
    print("用户分数")
    print(message2)
    local action = cjson.encode(message2)
    local message = cjson.decode(message2)

    if message[1]==6 and message[2] == 120 then
        if type(message[3]) == "table" then
            local data = message[3]
            if type(data) == "table" then
                --local valid = data["valid"]
                --if true == valid then
                    local score = tonumber(data["Score"]) or 0
                    local bean = tonumber(data["Integral"]) or 0
                    local ingot = tonumber(data["UserMedal"]) or 0
                    local roomcard = tonumber(data["RoomCard"]) or 0
                    local memberOrder = tonumber(data["MemberOrder"])

                    local needupdate = false
                    if score ~= GlobalUserItem.lUserScore 
                    	or bean ~= GlobalUserItem.dUserBeans
                    	or ingot ~= GlobalUserItem.lUserIngot
                    	or roomcard ~= GlobalUserItem.lRoomCard 
                        or memberOrder ~= GlobalUserItem.cbMemberOrder then
                    	GlobalUserItem.dUserBeans = tonumber(bean)
                    	GlobalUserItem.lUserScore = tonumber(score)
                    	GlobalUserItem.lUserIngot = tonumber(ingot)
                    	GlobalUserItem.lRoomCard = tonumber(roomcard)
                        GlobalUserItem.cbMemberOrder = tonumber(memberOrder)
                        needupdate = true
                    end
                    if needupdate then
                        print("update score")
                        --通知更新        
                        local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
                        eventListener.obj = yl.RY_MSG_USERWEALTH
                        cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
                    end 

                    _callback(callback, 0)  
                    
                    return      
                --end
            end
        end

        _callback(callback, -1, "数据获取失败")
    end

    if message[1]==4 and message[2] == 101 then
        if type(message[3]) == "table" then
            local data = message[3]
            local eventListener = cc.EventCustom:new("ry_GetGroptype")
            eventListener._usedata = {["gro_list"] = data}
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
        end
    end
end
--获取用户分数信息
function RequestManager.requestUserScoreInfo(callback)

    
    local _webFrame = WebFrame:create(nil, function(result, message)
        if RequestManager.UserScoreInfoCallBack then
			RequestManager.UserScoreInfoCallBack(result,message,callback)
		end
    end,true)

 
    local pargams = {6,20}
    local action = cjson.encode(pargams)
    dump(action)
    _webFrame:wsSendString(action) 
    
end

function RequestManager.QueryActivityCallBack( result,message2 ,callback )
    print("活动信息")
    print(message2)
    local action = cjson.encode(message2)
    local message = cjson.decode(message2)

    if message[1]==3 and message[2] == 103 then
       if message[3] ~=nil then
             --活动列表
            GlobalUserItem.dwActivityList = message[3]
            _callback(callback, 0)
       else 
            _callback(callback, -1, "数据获取失败")
       end

    end

end

--活动查询
function RequestManager.requestQueryActivityStatus(callback)

    local _webFrame = WebFrame:create(nil, function(result, message)
        if RequestManager.QueryActivityCallBack then
			RequestManager.QueryActivityCallBack(result,message,callback)
		end
    end,true)

    local action = {}
    action["tp"] = 3
    local pargams = {3,3,action}
    local action2 = cjson.encode(pargams)
    dump(action2)
   
    _webFrame:wsSendString(action2) 

end

return RequestManager