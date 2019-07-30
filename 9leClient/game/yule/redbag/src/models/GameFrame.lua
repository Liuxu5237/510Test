--
-- Author: zhouweixiang
-- Date: 2016-11-24 14:51:31
--

local BrnnCMD = appdf.req(appdf.GAME_SRC.."yule.redbag.src.models.CMD_Game")
local GameFrame = class("GameFrame")

local RecordMaxNum = 12  --最大路单记录

function GameFrame:ctor()
	--以座椅号管理
    self.m_tableChairUserList = {}
    --以uid管理
    self.m_tableUidUserList = {}
    --编号管理
    self.m_tableList = {}
    --上庄用户
    self.m_tableApplyList = {}
    --申请上庄数量
    self.m_llApplyCount = 0

    --路单
    self.m_vecRecord = {}
end

--游戏玩家管理

--初始化用户列表
function GameFrame:initUserList( userList )
    --以座椅号管理
    self.m_tableChairUserList = {}
    --以uid管理
    self.m_tableUidUserList = {}
    self.m_tableList = {}

    for k,v in pairs(userList) do
        self.m_tableChairUserList[v.wChairID + 1] = v;
        self.m_tableUidUserList[v.dwUserID] = v;
        table.insert(self.m_tableList, v)
    end
    dump(self.m_tableChairUserList)
end

--增加用户
function GameFrame:addUser( userItem )
    if nil == userItem then
        return;
    end

    self.m_tableChairUserList[userItem.wChairID + 1] = userItem;
    self.m_tableUidUserList[userItem.dwUserID] = userItem;
    
    local user = self:isUserInList(userItem)
    if nil == user then
        table.insert(self.m_tableList, userItem)
    else
        user = userItem
    end 

    print("after add:" .. #self.m_tableList)
end

function GameFrame:updateUser( useritem )
    if nil == useritem then
        return
    end

    local user = self:isUserInList(useritem)
    if nil == user then
        table.insert(self.m_tableList, useritem)
    else
        user = useritem
    end

    self.m_tableChairUserList[useritem.wChairID + 1] = useritem;
    self.m_tableUidUserList[useritem.dwUserID] = useritem;
end

function GameFrame:isUserInList( useritem )
    local user = nil
    for k,v in pairs(self.m_tableList) do
        if v.dwUserID == useritem.dwUserID then
            user = useritem
            break
        end
    end
    return user
end

--移除用户
function GameFrame:removeUser( useritem )
    if nil == useritem then
        return
    end

    local deleteidx = nil
    for k,v in pairs(self.m_tableList) do
        local item = v
        if v.dwUserID == useritem.dwUserID then
            deleteidx = k
            break
        end
    end

    if nil ~= deleteidx then
        table.remove(self.m_tableList,deleteidx)
    end

    table.remove(self.m_tableChairUserList,useritem.wChairID + 1)
    table.remove(self.m_tableUidUserList,useritem.dwUserID)

    print("after remove:" .. #self.m_tableList)
end

function GameFrame:removeAllUser(  )
    --以座椅号管理
    self.m_tableChairUserList = {}
    --以uid管理
    self.m_tableUidUserList = {}

    self.m_tableList = {}
    --上庄用户
    self.m_tableApplyList = {}
end

function GameFrame:getChairUserList(  )
    return self.m_tableChairUserList;
end

function GameFrame:getUidUserList(  )
    return self.m_tableUidUserList;
end

function GameFrame:getUserList( )
    return self.m_tableList
end

function GameFrame:sortList(  )
    --排序
    local function sortFun( a,b )
        return a.m_llIdx > b.m_llIdx
    end
    table.sort(self.m_tableApplyList, sortFun)
end

------

------
return GameFrame