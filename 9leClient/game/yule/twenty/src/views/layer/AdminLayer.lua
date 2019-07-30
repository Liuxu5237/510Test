--管理界面

local AdminLayer = class("AdminLayer",cc.Layer)

local module_pre = "game.yule.twenty.src"
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"

local Tag_Input = 
{
	TAG_BEGIN = 100,
	TAG_ONE = 101,
	TAG_TWO = 102,
	TAG_THREE = 103,
	TAG_FOUR = 104,
	TAG_FIVE = 105,
	TAG_SIX = 106,
	TAG_SEVEN = 107,
	TAG_EIGHT = 108,
	TAG_NINE = 109
}

-- 进入场景而且过渡动画结束时候触发。
function AdminLayer:onEnterTransitionFinish()  
	--self._scene:showPopWait()
	self:onAdminLoad()	
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function AdminLayer:onExitTransitionStart()
    return self
end

function AdminLayer:ctor(delegate,data)

	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			--self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			--self:onExitTransitionStart()
        elseif eventType == "exit" then
           
		end
	end)

	self._delegate = delegate

	self._adminCount = 0

	--用户名字信息
	self._UserListInfo = {GameID = 0, Gold = 0, Chance = 0}


	local node = cc.CSLoader:createNode("AdminLayer.csb")
    self:addChild(node)

    self._content = node:getChildByName("content")

    --关闭
    local btnClose = self._content:getChildByName("Btn_close")
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --保存
    local Btn_save = self._content:getChildByName("Btn_save")
    Btn_save:addClickEventListener(function()
    	self:onSendChangeData()
	end)


    --添加按钮
    local Btn_tianjia = self._content:getChildByName("Btn_tianjia")
    Btn_tianjia:addClickEventListener(function()
    	self:onSendAddUserList()
	end)

    --刷新按钮 
    local Btn_refresh = self._content:getChildByName("Btn_refresh")
    Btn_refresh:addClickEventListener(function()
    	self:onSendRefreshinfo()
	end)

	--删除按钮
	self.Btn_del = self._content:getChildByName("Btn_del")
	self.Btn_del:setTouchEnabled(false)
	self.Btn_del:setBright(false)
    self.Btn_del:addClickEventListener(function()
    	self:onSendDeleteUser()
	end)
	self._editbox = {}
	--创建输入框
	for i = 1, 9 do
		self._editbox[i] = self:onCreateEditBox(i)
		if i == 1 then
			self._editbox[i]:setText(tostring(data.szcurrentstock))
		elseif i == 2 then
			self._editbox[i]:setText(tostring(data.szprobability1))
		elseif i == 3 then
			self._editbox[i]:setText(tostring(data.szupperlimitofstock1))
		elseif i == 4 then
			self._editbox[i]:setText(tostring(data.szprobability2))
		elseif i == 5 then
			self._editbox[i]:setText(tostring(data.szupperlimitofstock2))
		elseif i == 6 then
			self._editbox[i]:setText(tostring(data.szprobability3))
		end
	end

	--用户容器
	self._useritem = self._content:getChildByName("Panel_useritem")

	--列表容器
	self._userLiserView = self._content:getChildByName("ListView_1")
	self:onSendRefreshinfo()
end

function AdminLayer:onRefreshUserList(userlist1)
	--[[ "<var>" = {
     "Counent" = 1
     "Kongzhi" = {
         "dwUserGameID" = 106744
         "lScoreLimit"  = -10000
         "probability"  = 50
     }
	 }]]
	 
	 local cout11 = userlist1:readbyte()
	 local userlist = {}
	 for i=1,cout11 do
		 userlist[i] = ExternalFun.read_netdata(g_var(cmd).CMD_C_KongZhi,userlist1)
	 end


 	self._userLiserView:removeAllChildren()
 	self._itemInfo = {}
 	local admin = userlist
 	self._adminCount = cout11
 	
 	for i = 1, #userlist do
 		if i > g_var(cmd).ITEM_MAX then
 			showToast(nil, "控制成员超过上限", 2)
 			break;
 		end	
 		local useritem = self._useritem:clone()
 		local gameid = useritem:getChildByName("gameid")
 		local chance = useritem:getChildByName("gailv")
 		local gold = useritem:getChildByName("winorlose")
 		gameid:setString(admin[i].dwUserGameID)
 			  :setColor(cc.BLACK)
 		chance:setString(admin[i].probability)
 			  :setColor(cc.BLACK)
 		gold:setString(admin[i].lScoreLimit)
 			:setColor(cc.BLACK)
 		useritem:setTag(i)
 		local item = {GameId = 0, isclick = false}
 		item.GameId = admin[i].dwUserGameID
 		--item.isclick = false
 		self._itemInfo[i] = item
 		useritem:setTouchEnabled(true)
 		useritem:addClickEventListener(function(pSender)
 		 	self:UserItemClickCallBack(pSender)
 		 	end)
 		self._userLiserView:pushBackCustomItem(useritem)
 		-- if item.GameId == self._UserListInfo.GameID then
 		-- 	self:UserItemClickCallBack(useritem)
 		-- end
 	end
end
function AdminLayer:UserItemClickCallBack(pSender)
	local tag = pSender:getTag()
	for i = 1, #self._itemInfo do
	 	if i == tag then
	 		if self._itemInfo[tag].isclick == true then
			 	pSender:setBackGroundColorType(LAYOUT_COLOR_NONE)
			 	self._itemInfo[tag].isclick = false
			 	self.Btn_del:setTouchEnabled(false)
			 	self.Btn_del:setBright(false)
			else
				pSender:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
				pSender:setBackGroundColor(cc.RED)
				pSender:setBackGroundColorOpacity(153)
				self._itemInfo[tag].isclick = true
				self.Btn_del:setTouchEnabled(true)
				self.Btn_del:setBright(true)
				self._currSelected = self._itemInfo[tag].GameId
			end
	 	else
			self._userLiserView:getChildByTag(i):setBackGroundColorType(LAYOUT_COLOR_NONE)
	 		self._itemInfo[i].isclick = false			
		end
	end
end
function AdminLayer:onSendChangeData()
	local cmddata = CCmd_Data:create(30)
	cmddata:pushscore(tonumber(self._editbox[1]:getText()))
	cmddata:pushword(tonumber(self._editbox[2]:getText()))
	cmddata:pushscore(tonumber(self._editbox[3]:getText()))
	cmddata:pushword(tonumber(self._editbox[4]:getText()))
	cmddata:pushscore(tonumber(self._editbox[5]:getText()))
	cmddata:pushword(tonumber(self._editbox[6]:getText()))
	self._delegate:SendData(g_var(cmd).SUB_C_PERSON_CONTROL,cmddata)
end

function AdminLayer:onSendAddUserList()
	if self._adminCount > g_var(cmd).ITEM_MAX then
		showToast(nil, "控制成员超过上限", 2)
		return
	end
	local gameid = tonumber(self._editbox[7]:getText())
    local chance = tonumber(self._editbox[8]:getText())
	local score = self._editbox[9]:getText()
    if string.find(score, "^[+-]?%d+$") then
        score = tonumber(score)
    else
        showToast(nil, "分数输入不合法,请重新输入", 2)
        return
    end
	    
	local cmddata = CCmd_Data:create(14)
	cmddata:pushdword(gameid)
	cmddata:pushscore(score)
	cmddata:pushword(chance)
	self._delegate:SendData(g_var(cmd).SUB_C_SAVE_PRO,cmddata)
end

function AdminLayer:onSendRefreshinfo()
	local cmddata = CCmd_Data:create(0)
	self._delegate:SendData(g_var(cmd).SUB_C_STOCK_OPERATE,cmddata)
end

function AdminLayer:onSendDeleteUser()
	local cmddata = CCmd_Data:create(4)
	cmddata:pushdword(self._currSelected)
	self._delegate:SendData(g_var(cmd).SUB_C_PRO_INQUIRY,cmddata)
	self.Btn_del:setBright(false)
	self.Btn_del:setTouchEnabled(false)
end

function AdminLayer:onCreateEditBox(index)
    local pos = {{x = 115, y = 560},{x = 115, y = 510},{x = 115, y = 460},
    			 {x = 115, y = 410},{x = 115, y = 355},{x = 115, y = 310},
    			 {x = 584, y = 520},{x = 584, y = 445},{x = 584, y = 370}}
    local str = {"输入库存一", "输入概率一", "输入库存二", "输入概率二", "输入库存三", "输入概率三", 
				 "输入GameId", "输入概率", "输入输赢分数"}
    local inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC
    if index == 9 then
        inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE
    end
    local sizeBg = cc.size(300,26)
    local editBox = ccui.EditBox:create(cc.size(sizeBg.width, sizeBg.height), "")
    	:setAnchorPoint(0, 0.5)
        :move(pos[index].x,pos[index].y)
        :setFontSize(26)
        :setFontColor(cc.BLACK)
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontSize(26)
        :setPlaceHolder(str[index])
        :setMaxLength(10)
        :setInputMode(inputMode)
        :setTag(index)
        :addTo(self._content)
    return editBox
end

return AdminLayer