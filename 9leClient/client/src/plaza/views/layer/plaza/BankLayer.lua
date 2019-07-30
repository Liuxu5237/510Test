--银行页面
local BankLayer = class("BankLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local ActivityIndicator = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.general.ActivityIndicator")

local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameFrameEngine")
local BankFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BankFrame")

local TransferCertificateLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.TransferCertificateLayer")
local ShopLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")

local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local WebFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.WebFrame")
local PhoneBindingLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.PhoneBinding")

--分类
local Categorys = 
{
    Take = 1,
    Save = 2,
    Transfer = 3,
    RecordIn = 4,
    RecordOut = 5,
    RewardRecord = 6,
    Count = 6,   
}

--转账类型
local TransferType = 
{
    In = 1,
    Out = 2,
    Reward = 3
}

function BankLayer:ctor(ismilit)
    
    --初始化分类按钮列表
    self._btnCategorys = {}
    --初始化分类面板列表
    self._panelCategorys = {}
    --转账记录
    self._recordLists = {}
    self._recordTableViews = {}

    --转账用户列表
    self._TrashGameIDCount = 0;
    self._TrashGameIDList = {}



    --网络处理
	self._bankFrame = BankFrame:create(self,function(result,message)
        if self.onBankCallBack then
            self:onBankCallBack(result,message)            
        end
    end)
    --GameFrameEngine:getInstance():addShotFrame(self._bankFrame)

    --节点事件
    ExternalFun.registerNodeEvent(self)

    --事件监听
    self:initEventListener()

    local csbNode = ExternalFun.loadCSB("Bank/BankLayer.csb"):addTo(self)
    self._TitopBaner = csbNode:getChildByName("Image_Tip")
   -- self._top = csbNode:getChildByName("top")
    self._content = csbNode:getChildByName("content")

    self._txtGold = csbNode:getChildByName("bank_info"):getChildByName("txt_bank")

    self._txtBank = self._content:getChildByName("Image_Bank"):getChildByName("txt_bank_0")

    --self._GameListLayter = self._content:getChildByName("Layer_TrUserList")

    local addscore = csbNode:getChildByName("bank_info"):getChildByName("Btn_Store")
    addscore:addClickEventListener(function ()
        --播放音效
        ExternalFun.playClickEffect()
        --商城跳转
        ShopLayer:create():addTo(self)
    end)

   


    --返回
    local btnBack = csbNode:getChildByName("btn_back")
    btnBack:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        self:removeFromParent()
    end)
    --分类按钮
    for i = 1, Categorys.Count do

        local btnCategory = csbNode:getChildByName("btn_category_" .. i)
        btnCategory:addEventListener(function()
            
            self:onClickCategory(i)
        end)
        --功能控制
        if ismilit == 1 and i > 2 then
            btnCategory:setVisible(false)
        end

        --苹果审核隐藏掉
        if yl.APPSTORE_VERSION and i > 2 then
            btnCategory:setVisible(false)
        end

        self._btnCategorys[i] = btnCategory
    end

    self:clearOne()

    --分类面板
    local panels = self._content:getChildByName("panels")

    for i = 1, Categorys.Count do

        --不想改界面所以单独提取 4和5,6
        if i == 4 or  i == 5 or i == 6 then
            self._panelCategorys[i] = self._content:getChildByName(i)
        else
            self._panelCategorys[i] = panels:getChildByName(i)
        end
       

        --初始化
        self:onInitCategoryPanel(i)
    end

    local btnAllTake = self._panelCategorys[3]:getChildByName("Btn_180")
    local bbxx = btnAllTake:getPositionX()
    local bbyy = btnAllTake:getPositionY()

    local btn_score4 = ccui.Button:create('Bank/JEbtnBg.png', 'Bank/JEbtnBg.png')
    :setPosition(cc.p(bbxx+176*4,bbyy))
    :addTo(self._panelCategorys[3], 1)
    :setScale(0.8)
    btn_score4:addClickEventListener(function()
        
        self._editTransferCount:setText(tonumber("7500000")*self.five)
        self.one = 1
        self.two =  1;
        self.three = 1;
        self.four = 1;
        self.five = self.five+1;   

    end)
    local label4 = cc.Label:create()
    :setAnchorPoint(cc.p(0.5,0.5))
    :setString("750万")
    :setSystemFontSize(36)
    :setPosition(cc.p(btn_score4:getContentSize().width/2-10,btn_score4:getContentSize().height/2))
    :addTo(btn_score4)

    --更新分数
    self:onUpdateScoreInfo()

    --获取分数信息
    self._bankFrame:onGetBankInfo()
end

function BankLayer:clearOne(  )
    self.one = 1
    self.two = 1
    self.three = 1
    self.four = 1
    self.five = 1

end
function BankLayer:onExit()
    
    --关闭网络
    if self._bankFrame:isSocketServer() then
        self._bankFrame:onCloseSocket()
    end
    GameFrameEngine:getInstance():removeShotFrame(self._bankFrame)
end

--初始化事件监听
function BankLayer:initEventListener()

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    --用户信息改变事件
    eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create(yl.RY_USERINFO_NOTIFY, handler(self, self.onUserInfoChange)),
        self
        )
end

------------------------------------------------------------------------------------------------------------
-- 事件处理

--用户信息改变
function BankLayer:onUserInfoChange(event)
    
    print("----------BankLayer:onUserInfoChange------------")

	local msgWhat = event.obj
	if nil ~= msgWhat and msgWhat == yl.RY_MSG_USERWEALTH then
		--更新财富
		self:onUpdateScoreInfo()
	end
end

--更新分数信息
function BankLayer:onUpdateScoreInfo()

    self._txtGold:setString(ExternalFun.numberThousands(GlobalUserItem.lUserScore))
    local str = ExternalFun.numberThousands(GlobalUserItem.lUserScore)
--    str = string.gsub(str,",",":")
--    self._txtGold:setString(str)
    local txtwith = self._txtGold:getContentSize().width
    local txtlen = string.len(str)
    if txtlen >= 11 then
        self._txtGold:setScale(170 / txtwith)
    end

    str = ExternalFun.numberThousands(GlobalUserItem.lUserInsure)
    --str = string.gsub(str,",",":")
    self._txtBank:setString(str)

   -- 缩放比例
   --[[local GoldBit =GetScoreNuberBit(GlobalUserItem.lUserScore)
   if GoldBit>8 then 
    -- 自动缩放
    local CurZoom = GoldBit - 8
    CurZoom = 10-(CurZoom*2)

    self._txtGold:setScale(CurZoom/10)
    else
     self._txtGold:setScale(1.0)
  end]]

   
end

--位数比例缩放
function GetScoreNuberBit( Nuber)

   local curNuber =  string.format("%d", Nuber)
   
    return string.len(curNuber)
end

--初始化分类面板
function BankLayer:onInitCategoryPanel(index)
    local panel = self._panelCategorys[index]
    local spEditBg = nil

    if index == Categorys.Take then         --取款
        
        --取款数量
        spEditBg = panel:getChildByName("sp_edit_take_count_bg")
        self._editTakeCount = self:onCreateEditBox(spEditBg, false, true, 12 , 2)

        --银行密码
        spEditBg = panel:getChildByName("sp_edit_bank_pwd_bg")
        self._editTakePwd = self:onCreateEditBox(spEditBg, true, false, 18,1)
        self._editTakePwd:setText(GlobalUserItem.szInsurePass)


         --清理
        local btnAllTake = panel:getChildByName("Btn_Clrear")
        btnAllTake:addClickEventListener(function()
           self._editTakeCount:setText("")
        end)

         --180W
        local btnAllTake = panel:getChildByName("Btn_180")
        btnAllTake:addClickEventListener(function()
            self._editTakeCount:setText("1500000")
        end)

         --360W
        local btnAllTake = panel:getChildByName("Btn_360")
        btnAllTake:addClickEventListener(function()
            self._editTakeCount:setText("3000000")
        end)

         --1800W
        local btnAllTake = panel:getChildByName("Btn_1800")
        btnAllTake:addClickEventListener(function()
            self._editTakeCount:setText("7500000")
        end)
        --全部取出
        local btnAllTake = panel:getChildByName("Btn_ALL")
        btnAllTake:addClickEventListener(function()
            self:onClickAllTake()
        end)

        --取出
        local btnTake = panel:getChildByName("btn_take")
        btnTake:addClickEventListener(function()
            self:onClickTake()
        end)

    elseif index == Categorys.Save then     --存款

        --存款数量
        spEditBg = panel:getChildByName("sp_edit_save_count_bg")
        self._editSaveCount = self:onCreateEditBox(spEditBg, false, true, 12,3)

        --全部存入
        local btnAllSave = panel:getChildByName("Btn_ALL")
        btnAllSave:addClickEventListener(function()
            self:onClickAllSave()
        end)



   --清理
        local btnAllTake = panel:getChildByName("Btn_Clear")
        btnAllTake:addClickEventListener(function()
           self._editSaveCount:setText("")
        end)

         --180W
        local btnAllTake = panel:getChildByName("Btn_180")
        btnAllTake:addClickEventListener(function()
           self._editSaveCount:setText("1500000")
        end)

         --360W
        local btnAllTake = panel:getChildByName("Btn_360")
        btnAllTake:addClickEventListener(function()
            self._editSaveCount:setText("3000000")
        end)

         --1800W
        local btnAllTake = panel:getChildByName("Btn_1800")
        btnAllTake:addClickEventListener(function()
            self._editSaveCount:setText("7500000")
        end)


        --存入
        local btnSave = panel:getChildByName("btn_save")
        btnSave:addClickEventListener(function()
            self:onClickSave()
        end)

    elseif index == Categorys.Transfer then --赠送

        --赠送ID
        spEditBg = panel:getChildByName("sp_edit_transfer_id_bg")
        self._editTransferID = self:onCreateEditBox(spEditBg, false, true, 8,4)

        --赠送数量
        spEditBg = panel:getChildByName("sp_edit_transfer_count_bg")
        self._editTransferCount = self:onCreateEditBox(spEditBg, false, true, 12,5)

        --银行密码
        spEditBg = panel:getChildByName("sp_edit_bank_pwd_bg")
        self._editTransferPwd = self:onCreateEditBox(spEditBg, true, false, 18,1)
        self._editTransferPwd:setText(GlobalUserItem.szInsurePass)



       --常用ID
        local lGameChangyongList = panel:getChildByName("Btn_GameIDList")
        lGameChangyongList:addClickEventListener(function()
        --显示节点
        for i = 1, 3 do
            if self._TrashGameIDList[i] ~= nil and self._TrashGameIDList[i] ~= "" then
                panel:getChildByName("Btn_GameID_"..i):getChildByName("Text_18"):setString(tostring(self._TrashGameIDList[i]))
            else
                panel:getChildByName("Btn_GameID_"..i):getChildByName("Text_18"):setString("无")
            end
            panel:getChildByName("Btn_GameID_"..i):setVisible(true)
        end     
    end)





        local btnGameID1 = panel:getChildByName("Btn_GameID_1")
        btnGameID1:addClickEventListener(function()
       
        if self._TrashGameIDList[1] == 0 then
            self._editTransferID:setText("")
        else
            self._editTransferID:setText(tostring(self._TrashGameIDList[1]))
           end

           SetUserGameList(panel,false)
          
       end)


        local btnGameID2 = panel:getChildByName("Btn_GameID_2")
        btnGameID2:addClickEventListener(function()

        if self._TrashGameIDList[2] == 0 then
            self._editTransferID:setText("")
        else
            self._editTransferID:setText(tostring(self._TrashGameIDList[2]))
           end

           SetUserGameList(panel,false)
          
        end)


        local btnGameID3 = panel:getChildByName("Btn_GameID_3")
        btnGameID3:addClickEventListener(function()
        if self._TrashGameIDList[3] == 0 then
            self._editTransferID:setText("")
        else
            self._editTransferID:setText(tostring(self._TrashGameIDList[3]))
           end

           SetUserGameList(panel,false)
          
        end)


         --全部赠送
        --local btnAllSave = panel:getChildByName("Btn_ALL")
        --btnAllSave:addClickEventListener(function()
        --     self._editTransferCount:setText(GlobalUserItem.lUserInsure)
        --end)

   --清理
        local btnAllTake = panel:getChildByName("Btn_Clear")
        btnAllTake:addClickEventListener(function()
          self._editTransferCount:setText("")
          self:clearOne()
        end)

        self._Capital = panel:getChildByName("Text_Capital")
        self._Capital:setString("")
        --self._Capital:setVisible(false)

         --180W
        local btnAllTake = panel:getChildByName("Btn_180")
        btnAllTake:getChildByName("Text_18"):setString("15万")
        btnAllTake:addClickEventListener(function()
           self._editTransferCount:setText(tonumber("150000")*self.one)
           self.one = self.one +1
            self.two = 1;
            self.three = 1;
            self.four = 1;
            self.five = 1;
        end)
        btnAllTake:setScale(0.8)
        local bbxx = btnAllTake:getPositionX()
        local bbyy = btnAllTake:getPositionY()
        btnAllTake:setPosition(cc.p(bbxx,bbyy))

         --360W
        local btnAllTake = panel:getChildByName("Btn_360")
        btnAllTake:getChildByName("Text_18"):setString("45万")
        btnAllTake:addClickEventListener(function()
            self._editTransferCount:setText(tonumber("450000")*self.two)
            self.one = 1
            self.two = self.two + 1;
            self.three = 1;
            self.four = 1;
            self.five = 1;

        end)
        btnAllTake:setScale(0.8)
        btnAllTake:setPosition(cc.p(bbxx+176,bbyy))
         --1800W
        local btnAllTake = panel:getChildByName("Btn_1800")
        btnAllTake:getChildByName("Text_18"):setString("75万")
        btnAllTake:addClickEventListener(function()
            self._editTransferCount:setText(tonumber("750000")*self.three)
            self.one = 1
            self.two =  1;
            self.three = self.three + 1;
            self.four = 1;
            self.five = 1;
        end)
        btnAllTake:setScale(0.8)
        btnAllTake:setPosition(cc.p(bbxx+176*2,bbyy))
        --赠送
        local btnTransfer = panel:getChildByName("btn_transfer")
        btnTransfer:addClickEventListener(function()
            self:onClickTransfer()
        end)


   panel:addTouchEventListener(function(ref,tType)
     if tType == ccui.TouchEventType.ended then 

            SetUserGameList(panel,false)
    end
end)
       

          --常用ID
        local btnCommon = panel:getChildByName("Btn_Common")
        btnCommon:addClickEventListener(function()
        --显示节点

       
      
        for i = 1, 3 do

        if self._TrashGameIDList[i] ~=0 then
          panel:getChildByName("Btn_GameID_"..i):getChildByName("Text_18"):setText(tostring(self._TrashGameIDList[i]))
        else
         panel:getChildByName("Btn_GameID_"..i):getChildByName("Text_18"):setText("无")

         end
         panel:getChildByName("Btn_GameID_"..i):setVisible(true)
       end
      

        end)

         --常用ID
        local btnAllSave = panel:getChildByName("Btn_ALL")
        btnAllSave:getChildByName("Text_18"):setString("150万")
        btnAllSave:addClickEventListener(function()
            self._editTransferCount:setText(tonumber("1500000")*self.four)
            self.one = 1
            self.two =  1;
            self.three = 1;
            self.four = self.four + 1;
            self.five = 1;
        end)
        btnAllSave:setScale(0.8)
        btnAllSave:setPosition(cc.p(bbxx+176*3,bbyy))

    elseif index == Categorys.RecordIn or 
           index == Categorys.RecordOut or 
           index == Categorys.RewardRecord then --转入、转出,奖励记录

        --tableview 回调
        local numberOfCellsInTableView = function(view)
            return self:numberOfCellsInTableView(view)
        end
        local cellSizeForTable = function(view, idx)
            return self:cellSizeForTable(view, idx)
        end
        local tableCellAtIndex = function(view, idx)	
            return self:tableCellAtIndex(view, idx)
        end
        local tableCellTouched = function(view, cell)
            return self:tableCellTouched(view, cell)
        end



        --转账列表
	    local tableView = cc.TableView:create(cc.size(1124, 520))
	    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
        tableView:setAnchorPoint(cc.p(0, 0))
	    tableView:setPosition(cc.p(-75, 25))
        tableView:setContentSize(1124, 494)
	    tableView:setDelegate()
	    tableView:addTo(panel)
	    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)

        tableView:reloadData()

        --保存
        if index == Categorys.RecordIn then
            print("转入记录")
            tableView:setTag(TransferType.In)
            self._recordTableViews[TransferType.In] = tableView
        elseif index == Categorys.RecordOut then
             print("转出记录")
            tableView:setTag(TransferType.Out)
            self._recordTableViews[TransferType.Out] = tableView
        elseif index == Categorys.RewardRecord then
            print("奖励记录")
            tableView:setTag(TransferType.Reward)
            self._recordTableViews[TransferType.Reward] = tableView
        end
    end

end


--设置GAMEID状态
function SetUserGameList(GameLayer , bshow )

      for i = 1, 3 do
        GameLayer:getChildByName("Btn_GameID_"..i):setVisible(bshow)
    end


    
end
function BankLayer:ShowTopBanker(bshow)

    self._content:getChildByName("Image_Bank"):setVisible(bshow)
    --分类面板
    local panels = self._content:getChildByName("panels")
    panels:setVisible(bshow)
end
--创建编辑框
function BankLayer:onCreateEditBox(spEditBg, isPassword, isNumeric, maxLength , nPushIndex)
    
    local inputMode = isNumeric and cc.EDITBOX_INPUT_MODE_NUMERIC or cc.EDITBOX_INPUT_MODE_SINGLELINE

    local sizeBg = spEditBg:getContentSize()

        --设置提示文本
      local PlaceHolder = "";
    --初始字体
    if nPushIndex == 1 then
      PlaceHolder = "输入银行密码"
    elseif nPushIndex == 2 then
       PlaceHolder = "输入取金币数量"
    elseif nPushIndex == 3 then
       PlaceHolder = "输入存金币数量"
    elseif nPushIndex == 4 then
       PlaceHolder = "输入对方ID"
    elseif nPushIndex == 5 then
       PlaceHolder = "输入赠送金币数量"
    end
    
    local nEditWidth = sizeBg.width - 16

    if nPushIndex == 4 then
        nEditWidth = 270
    end
    
    local editBox = ccui.EditBox:create(cc.size(nEditWidth, sizeBg.height - 16), "")
		:move(sizeBg.width / 2, sizeBg.height / 2)
        :setFontSize(27)
        :setFontColor(cc.WHITE)
		:setFontName("fonts/round_body.ttf")
		:setMaxLength(maxLength)
        :setInputMode(inputMode)
		:addTo(spEditBg) 
        :setPlaceHolder(PlaceHolder)
    --密码框
    if isPassword then
        editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    end
    if nPushIndex == 5 then
        editBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxEventHandler(eventname,sender) end)
    end
    return editBox
end
function BankLayer:editboxEventHandler(eventType,sender)
    if eventType == "began" then
        -- 点击编辑框,输入法显示
        sender:setText("")
    elseif eventType == "ended" then
        -- 当编辑框失去焦点并且键盘消失的时候被调用
    elseif eventType == "changed" then
        -- 输入内容改变时调用
        local str = ExternalFun.numberTransiform(sender:getText())
        print(str)
        self._Capital:setString(str)
        printf("输入内容改变时调用")
    elseif eventType == "return" then
        -- 用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
    end
end

--清空编辑框
function BankLayer:onClearEditBoxs()
    
    local editBoxs = {
        self._editTakeCount, self._editSaveCount, self._editTransferID, self._editTransferCount
    }

    for i = 1, #editBoxs do
        editBoxs[i]:setText("")
    end

    --读取密码
    if GlobalUserItem.szInsurePass ~= "" then
        self._editTakePwd:setText(GlobalUserItem.szInsurePass)
        self._editTransferPwd:setText(GlobalUserItem.szInsurePass)
    end
end

--点击分类按钮
function BankLayer:onClickCategory(index)
    self:clearOne()
    --播放按钮音效
    ExternalFun.playClickEffect()

    for i = 1, Categorys.Count do
        self._btnCategorys[i]:setSelected(index == i)
        self._panelCategorys[i]:setVisible(index == i)
    end

    --清空文本框
    self:onClearEditBoxs()

    --获取转账记录
    if index == Categorys.RecordIn then
        self:ShowTopBanker(false)
        self._TitopBaner:setVisible(true)
        self:requestBankRecord(TransferType.In)
    elseif index == Categorys.RecordOut then
        self:ShowTopBanker(false)
        self._TitopBaner:setVisible(true)
        self:requestBankRecord(TransferType.Out)
    elseif index == Categorys.RewardRecord then
        self:ShowTopBanker(false)
        self._TitopBaner:setVisible(true)
        self:requestBankRecord(TransferType.Reward)
    else
         self:ShowTopBanker(true)
         self._TitopBaner:setVisible(false)
    end

end

--点击全部取出
function BankLayer:onClickAllTake()
    
    --播放按钮音效
    ExternalFun.playClickEffect()

    self._editTakeCount:setText(GlobalUserItem.lUserInsure)
end

--点击取出
function BankLayer:onClickTake()
    
    --播放按钮音效
    ExternalFun.playClickEffect()

    --参数判断
	local szScore =  string.gsub(self._editTakeCount:getText(),"([^0-9])","")
    szScore = string.gsub(szScore, "[.]", "")
	local szPass = self._editTakePwd:getText()
    if #szScore < 1 then 
        showToast(self,"请输入取款数量！",2)
        return
    end

	local lOperateScore = tonumber(szScore)
	if lOperateScore < 1 then
		showToast(self,"请输入正确的取款数量！",2)
		return
	end

    if lOperateScore > tonumber(GlobalUserItem.lUserInsure) then
        showToast(self,"您银行游戏币的数目余额不足,请重新输入游戏币数量！",2)
        return
    end

	if #szPass < 1 then 
		showToast(self,"请输入银行密码！",2)
		return
	end
	if #szPass <5 then
		showToast(self,"密码至少为6个字符，请重新输入！",2)
		return
	end

    --保存临时密码
    self._szTmpPass = szPass

	showPopWait()
	self._bankFrame:onTakeScore(lOperateScore,szPass)
end

--点击全部存入
function BankLayer:onClickAllSave()
    
    --播放按钮音效
    ExternalFun.playClickEffect()

    self._editSaveCount:setText(GlobalUserItem.lUserScore)
end

--点击存入
function BankLayer:onClickSave()
    
    --播放按钮音效
    ExternalFun.playClickEffect()

    	--参数判断
	local szScore =  string.gsub(self._editSaveCount:getText(),"([^0-9])","")	
    szScore = string.gsub(szScore, "[.]", "")
	if #szScore < 1 then 
		showToast(self,"请输入存款数量！",2)
		return
	end
	
	local lOperateScore = tonumber(szScore)
	
	if lOperateScore<1 then
		showToast(self,"请输入正确的存款数量！",2)
		return
	end
    print(""..GlobalUserItem.lUserScore)
    if lOperateScore > tonumber(GlobalUserItem.lUserScore) then
        showToast(self,"您所携带游戏币的数目余额不足,请重新输入游戏币数量!",2)
        return
    end

    showPopWait()
    
	self._bankFrame:onSaveScore(lOperateScore)
end

--点击赠送
function BankLayer:onClickTransfer()
    
    --播放按钮音效
    ExternalFun.playClickEffect()

    --参数判断
	local szScore =  string.gsub(self._editTransferCount:getText(),"([^0-9])","")
	local szPass = self._editTransferPwd:getText()
	local szTarget = self._editTransferID:getText()
	local byID = 1--self.cbt_TransferByID:isSelected() and 1 or 0;

    if #szTarget < 1 then 
		showToast(self,"请输入赠送用户ID！",2)
		return
	end

	if #szScore < 1 then 
		showToast(self,"请输入赠送数量！",2)
		return
	end

	local lOperateScore = tonumber(szScore)
	if lOperateScore<1 then
		showToast(self,"请输入正确的数量！",2)
		return
    end
   
    if lOperateScore > GlobalUserItem.lUserInsure then
		showToast(self," 银行余额不足，赠送失败！",2)
		return
	end

	if #szPass < 1 then 
		showToast(self,"请输入银行密码！",2)
		return
	end
	if #szPass <5 then
		showToast(self,"密码至少为6个字符，请重新输入！",2)
		return
	end

    --保存临时密码
    self._szTmpPass = szPass

    --判断是否有资格
    local phonelen = string.len(GlobalUserItem.szMobilePhone)
    dump(GlobalUserItem.szMobilePhone)
    dump(phonelen)
    if (GlobalUserItem.szMobilePhone == "" or phonelen ~= 11) and (GlobalUserItem.cbTransfer == 1 or GlobalUserItem.cbTransfer == nil) then
        QueryDialog:create("您的帐号未绑定手机，暂时不能使用保险箱赠送功能。",function(bReTry)
            if bReTry == true then
                showPopupLayer(PhoneBindingLayer:create(self))
            end
        end,nil,QueryDialog.QUERY_SURE)
        :addTo(self)
    else
        showPopWait()
	    self._bankFrame:onTransferScore(lOperateScore,szTarget,szPass,byID)
    end

end

--------------------------------------------------------------------------------------------------------------------
-- TableView 数据源

--子视图数量
function BankLayer:numberOfCellsInTableView(view)
    
    local tag = view:getTag()
   
    if self._recordLists[tag] == nil  then
        return 0
    end
    return #self._recordLists[tag]
end

--子视图大小
function BankLayer:cellSizeForTable(view, idx)

    return 1124, 48
end

--获取子视图
function BankLayer:tableCellAtIndex(view, idx)	
    
    --修正下标
    idx = idx + 1

    local cell = view:dequeueCell()
    if nil == cell then

        cell = cc.TableViewCell:create()

        local widths = { 105, 246, 170, 235}
        local posXs = { 118, 342, 575, 805}

        for i = 1, 4 do
            
            local txtColumn = ccui.Text:create("", "fonts/round_body.ttf", 27)
            txtColumn:setTag(i)
            txtColumn:setPosition(posXs[i], 20)
            txtColumn:setContentSize(widths[i], 35)
            txtColumn:setColor(cc.c3b(201,216,241))
            txtColumn:addTo(cell)
        end
    end

    local tag = view:getTag()
    local item = self._recordLists[tag][idx]
    local contents = {}
    --[[[LUA-print] -response-{"code":0,"msg":null,"data":{"valid":true,"list":[{"LB":"
奖励发放","TypeName":"朋友圈奖励","Reward":"1000金币,0.20红包","CollectDate":"20
17/12/28 9:37:21","NickName":null,"GameID":0,"SwapScore":0}]}}]]
    if tag == TransferType.Reward then
        contents = { item.NickName, item.TypeName, item.Score,item.WriteTime  }
    else
        contents = { item.NickName, item.GameID, item.Score,item.WriteTime ,item.TypeName }
        local icon = cc.Sprite:create(string.format("Bank/ztIcon%d.png",contents[5]))
        icon:setPosition(1030, 20)
        icon:addTo(cell)
    end
    for i = 1, 4 do
    
        local txtColumn = cell:getChildByTag(i)
        txtColumn:setString(contents[i]) 

    end

         --分割线   
    self._lsPaceLine = cc.Sprite:create("Bank/log_line.png")
        :setPosition(45,45)
        :setAnchorPoint(0,0.5)
        :setScaleX(2)
        :addTo(cell)


    return cell
end

--子视图点击
function BankLayer:tableCellTouched(view, cell)
    
end

--------------------------------------------------------------------------------------------------------------------
-- BankFrame 事件处理

--操作结果
function BankLayer:onBankCallBack(result,message)

    dismissPopWait()
    --print(message.wPeopleone)
    dump(message)
    print(self._bankFrame._oprateCode,BankFrame.OP_QUERY_USER)
    if message ~= nil and message ~= "" then
        print("=========================")
		showToast(nil,message,2)
	end

    if result == 1 then

        if self._bankFrame._oprateCode == BankFrame.OP_TAKE_SCORE then
            
            --保存密码
            GlobalUserItem.szInsurePass = self._editTakePwd:getText()

        elseif self._bankFrame._oprateCode == BankFrame.OP_SEND_SCORE then
            self:clearOne()
            --保存密码
            GlobalUserItem.szInsurePass = self._editTransferPwd:getText()

            local tabTarget = self._bankFrame._tabTarget
            local tt = os.date("*t", tabTarget.opTime)

            -- 转账凭证
            local info = {
                SourceNickName = GlobalUserItem.szNickName,
                SourceGameID = GlobalUserItem.dwGameID,
                TargetNickName = tabTarget.opTargetAcconts,
                TargetGameID = tabTarget.opTargetID,
                Score = tabTarget.opScore,
                ScoreCN = ExternalFun.numberTransiform(tabTarget.opScore),
                Date = string.format("%d.%02d.%02d-%02d:%02d:%02d", tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec),
                CerID = md5(tabTarget.opTime)
            }

            showPopupLayer(TransferCertificateLayer:create(info))
        elseif self._bankFrame._oprateCode == BankFrame.OP_QUERY_USER then
            local str = "\n您确定要给【"..message["NickName"].."】，ID:"..message["GameID"].."赠送"..self._bankFrame._lOperateScore.."金币吗?"
            QueryDialog:create(str,function(bReTry)
                if bReTry == true then
                    self._bankFrame._oprateCode = BankFrame.OP_SEND_SCORE
                    self._bankFrame:sendTransferScore()
                else
                    self._bankFrame:onCloseSocket()
                end
            end)
            :addTo(self,100)

        end
    --更新常用转账表
    elseif  result == 5 then
       --转账用户列表
        self._TrashGameIDCount = #message
        table.insert(self._TrashGameIDList, message[1])
        table.insert(self._TrashGameIDList, message[2])
        table.insert(self._TrashGameIDList, message[3])
        --清空文本框
        self:onClearEditBoxs()
    end
end

--------------------------------------------------------------------------------------------------------------------
-- 网络请求

--请求银行记录
function BankLayer:requestBankRecord(transfertype)

    showPopWait()

    local t_webframe = WebFrame:create(self, function(result, message) 
        if self.recordCallBack then
			self:recordCallBack(result,message,transfertype)
		end
	end)
	
	local action = {}
	action["type"] =transfertype
    local pargams = {1,26,action}
    local action2 = cjson.encode(pargams)
    t_webframe:wsSendString(action2) 
    
end

function BankLayer:recordCallBack( result , message2 ,transfertype )
    print("银行记录回调" .. transfertype)
    print(message2)
    local action2 = cjson.encode(message2)
    local message = cjson.decode(message2)
    dismissPopWait()
    
    local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")
    RequestManager.requestUserScoreInfo(nil)

    if message[1] == 1 and message[2] == 126  then
        if type(message[3]) == "table" then
            --保存并刷新数据
            self._recordLists[transfertype] = message[3]
            self._recordTableViews[transfertype]:reloadData()
        end
    else
        showToast(nil,"抱歉，获取银行记录信息失败！",2)        
    end
end

return BankLayer