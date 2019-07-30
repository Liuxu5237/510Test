--[[--
游戏命令
]]

local cmd = cmd or {}

--游戏标识
cmd.KIND_ID                 = 1040

--游戏人数
cmd.PLAYER_COUNT            = 100

--发送红包
cmd.SUB_C_SENDREDPACKET 		= 1
cmd.SUB_C_CANCEL_BANKER         = 3   --发送中雷了


cmd.SUB_C_AMDIN_COMMAND         = 5 
cmd.SUB_S_AMDIN_COMMAND         =110
cmd.SUB_C_UPDATE_STORAGE        =6
--发送红包
cmd.SendRedPacket = 
{
    {k = "wChaid", t = "word"},		--用户id
    {k = "wNumber", t = "word"},	--个数
	{k = "wPoint", t = "word"},		--雷点
	{k = "wRate", t = "double"},    --倍率
	{k = "wRedmoney", t = "score"},	--红包金额
}

cmd.SUB_S_PLACE_JETTON      =101
cmd.SUB_S_PLACE_JETTON_FAIL =107
cmd.Send_S_RedPacket =
{
    {k = "wChaid",  t = "word"},		--用户id
    {k = "wNumber", t = "word"},	--个数
	{k = "wPoint",  t = "word"},		--雷点
	{k = "wRate",   t = "double"},		--倍率
    {k = "wRedmoney", t = "score"},	--红包金额
    {k = "wIdentifier", t = "dword"},	--红包标识
    {k = "wGameID", t = "dword"},		   
    {k = "wFaceAddress",      t = "string", s = 256},      --头像地址
};


cmd.SUB_GR_USERMAILEI_REQUEST  =     30 --414
cmd.SUB_GR_USERREMOVE_REQUEST  =     415

cmd.SUB_C_APPLY_BANKER         = 2  --拆雷

cmd.SUB_S_APPLY_BANKER		   = 103   --拆雷结果

cmd.SUB_S_CANCEL_BANKER        = 108    --通知中雷了

cmd.CMD_GR_UserMaiLeiReq=
{
    {k = "wNumber", t = "word"},	--个数
	{k = "wPoint",  t = "word"},		--雷点
	{k = "wRate",   t = "double"},		--倍率
	{k = "wRedmoney", t = "score"},	--红包金额
};


cmd.LEN_SERVER = 32   
cmd.UD_GROUP_NAME = 11

--用户领包
cmd.Send_S_UserInmine =
{
    {k = "zIdentifier",     t = "dword"},			    --红包KEY
    {k = "wGameID",         t = "dword"},          
    {k = "szUserName",      t = "string", s = 16},      --用户名称
};

cmd.tatMineResult = 
{
    {k = "wGetNumber",      t = "word"},	        --已经拆个数
    {k = "wTotalNumber",    t = "word"},	        --总雷个数
    {k = "wGetmoney",       t = "int"},	            --已经被拆金额
    {k = "wTotalmoney",     t = "score"},	        --总金额
    {k = "szUserName",      t = "string", s = 16},  --用户名称
    {k = "wThunder",        t = "word"},	        --是否中雷0-1
    {k = "wWinmoney",       t = "score"},           --拆雷金额
    {k = "wTime",           t = "string" ,s = 16},  --拆雷时间
    {k = "wFaceID",         t = "word"},            --头像ID
    {k = "wGameID",         t = "dword"},			--用户标识
    {k = "wHand",           t = "word"},			--手气最佳
    {k = "wFaceAddressp",   t = "string", s = 256}, --头像地址
};

cmd.CMD_GR_ChaiLeiInfo_Result = 
{
    {k = "cbIdentifier",  t = "dword"},			--红包标识
	{k = "cbColumnCount", t = "byte"},									
	{k = "MineLeiresult", t = "table", d = cmd.tatMineResult, l = {cmd.UD_GROUP_NAME}},
}
--控制信息
cmd.CMD_S_RedControl=
{
   {k = "cbGameID",        t = "dword"},			
   {k = "cbUserName",      t = "string", s = 16},
   {k = "cbWinmoery",      t = "score"},           
   {k = "cbSendporery",    t = "word"},	        
   {k = "cbEndporery",     t = "word"},	        
}

cmd.CMD_C_RedControl = 
{
    {k = "Counent",  t = "byte"},			
    {k = "Kongzhi",  t = "table", d = cmd.CMD_S_RedControl, l = {150}},
};

--非法视图
cmd.INVALID_VIEWID          = 0
--左边玩家视图
cmd.LEFT_VIEWID             = 1
--自己玩家视图
cmd.MY_VIEWID               = 2
--右边玩家视图
cmd.RIGHT_VIEWID            = 3

--最大数目
cmd.MAX_COUNT               = 20
--全牌数目
cmd.FULL_COUNT              = 54
--常规数目
cmd.NORMAL_COUNT            = 17
--派发数目
cmd.DISPATCH_COUNT          = 51

--游戏状态
cmd.GAME_SCENE_FREE     	= 0  			--等待开始
cmd.GAME_SCENE_CALL 		= 100  			--叫分状态
cmd.GAME_SCENE_PLAY 		= 101  			--游戏进行
cmd.GAME_SCENE_END          = 255           --游戏结束

-- 倒计时
cmd.TAG_COUNTDOWN_READY     = 1
cmd.TAG_COUNTDOWN_CALLSCORE = 2
cmd.TAG_COUNTDOWN_OUTCARD   = 3
-- 游戏倒计时
cmd.COUNTDOWN_READY         = 30            -- 准备倒计时
cmd.COUNTDOWN_CALLSCORE     = 20            -- 叫分倒计时
cmd.COUNTDOWN_OUTCARD       = 20            -- 出牌倒计时
cmd.COUNTDOWN_HANDOUTTIME   = 30            -- 首出倒计时

-- 游戏胜利方
cmd.kDefault                = -1
cmd.kLanderWin              = 0
cmd.kLanderLose             = 1
cmd.kFarmerWin              = 2
cmd.kFarmerLose             = 3

-- 春天标记
cmd.kFlagDefault            = 0
cmd.kFlagChunTian           = 1
cmd.kFlagFanChunTian        = 2
---------------------------------------------------------------------------------------
--服务器命令结构
cmd.SUB_S_GAME_START        = 100           --游戏开始
cmd.SUB_S_CALL_SCORE        = 101           --用户叫分
cmd.SUB_S_BANKER_INFO       = 102           --庄家信息
cmd.SUB_S_OUT_CARD          = 103           --用户出牌
cmd.SUB_S_PASS_CARD         = 104           --用户放弃
cmd.SUB_S_GAME_CONCLUDE     = 105           --游戏结束
cmd.SUB_S_TRUSTEE           = 108           --用户托管


cmd.SUB_S_TRUSTEE           = 108           --用户托管
cmd.SUB_S_SEND_RECORD       = 106           --变颜色
cmd.SUB_GR_USERMAILEI_REQUEST  = 30 --414        --游戏记录
--服务端消息结构
------
--埋雷记录
cmd.CMD_GR_UserMaiLeiRecord = 
{
    {k = "wRedmoney",       t = "score"},       --金额
	{k = "wPoint",          t = "word"},	    --
	{k = "wRate",           t = "double"},	        --
    {k = "wChaimoney",      t = "score"},       --金额
    {k = "wHandair",        t = "bool"},       --手气最佳
    {k = "wThunder",        t = "bool"},       --中雷标识
    {k = "wThunmoney",      t = "score"},       --中雷金额
    {k = "wTime",           t = "string",s = 16},  --拆雷时间
}

--记录结果
cmd.CMD_GR_MaiLeiGame_Rcord = 
{
    {k = "cbColumnCount",       t = "byte"},       --中雷金额
	{k = "Record", t = "table", d = cmd.CMD_GR_UserMaiLeiRecord, l = {30}},
}
--
cmd.LeiUser = 
{
     {k = "NickName",           t = "string",s = 16},  --拆雷时间
}
--游戏场景
cmd.CMD_S_StatusFree =  
{
    {k = "szUserName",      t = "string",s = 16},  --用户名称
    {k = "wNumber",         t = "word"},	        --
    {k = "wPoint",          t = "word"},	        --
    {k = "wFaceID",         t = "word"},	        --死人脑壳
    {k = "wRate",           t = "double"},	        --
    {k = "wRedmoney",       t = "score"},       --金额
    {k = "wIdentifier",     t = "dword"},	   --埋雷标识
    {k = "wZJComplete",     t = "bool"},	   --是否拆过
    {k = "wComplete",       t = "bool"},	   --是否领完
    {k = "wGameID",         t = "dword"},	
    {k = "wzUserName",      t = "table", d = cmd.LeiUser, l = {10}},
    {k = "wFaceAdd",        t = "string", s = 256},      --头像地址
    {k = "szUserID",        t = "dword"},	             --用户标识

}
--排行榜
cmd.CMD_S_UserlRanKing = 
{
 {k = "wMoney",       t = "score"},               --金额
 {k = "wFace",        t = "word"},       
 {k = "wUserID",      t = "dword"},       
 {k = "wNickName",    t = "string", s = 16},      --用户名称	   
 {k = "wFaceAddress", t = "string", s = 256},     --微信地址
}
--场景数据
cmd.CMD_S_StatusPlay=
{   
    {k = "wRobotsend",        t = "word"},       
    {k = "wRobotgrab",        t = "word"},       
    {k = "wSendprobability",  t = "word"},       
    {k = "wRobprobability",   t = "word"},       
    {k = "moneyone",          t = "score"},       --金额
    {k = "moneytwo",          t = "score"},       --金额
    {k = "moneyThree",        t = "score"},       --金额
    {k = "Count",             t = "byte" },       --金
    {k = "StatusFree",        t = "table", d = cmd.CMD_S_StatusFree, l = {5}},
    {k = "cbColumnCount",     t = "byte" },       --金
	{k = "wRanKing",          t = "table", d = cmd.CMD_S_UserlRanKing, l = {3}},
}
--发送扑克/游戏开始
cmd.CMD_S_GameStart = 
{
    {k = "wStartUser", t = "word"},                             --开始玩家
    {k = "wCurrentUser", t = "word"},                           --当前玩家
    {k = "cbValidCardData", t = "byte"},                        --明牌扑克
    {k = "cbValidCardIndex", t = "byte"},                       --明牌位置
    {k = "cbCardData", t = "byte", l = {cmd.NORMAL_COUNT}},     --扑克列表
}

--用户叫分
cmd.CMD_S_CallScore = 
{
    {k = "wCurrentUser",   t = "word"},                           --当前玩家
    {k = "wCallScoreUser", t = "word"},                         --叫分玩家
    {k = "cbCurrentScore", t = "byte"},                         --当前叫分
    {k = "cbUserCallScore",t = "byte"},                        --上次叫分
}
--庄家信息
cmd.CMD_S_BankerInfo = 
{
    {k = "wBankerUser",   t = "word"},                            --庄家玩家
    {k = "wCurrentUser",  t = "word"},                           --当前玩家
    {k = "cbBankerScore", t = "byte"},                          --庄家叫分
    {k = "cbBankerCard",  t = "byte", l = {3}},                  --庄家扑克
}

--用户出牌
cmd.CMD_S_OutCard = 
{
    {k = "cbCardCount",  t = "byte"},                            --出牌数目
    {k = "wCurrentUser", t = "word"},                           --当前玩家
    {k = "wOutCardUser", t = "word"},                           --出牌玩家
    {k = "cbCardData",   t = "byte", l = {cmd.MAX_COUNT}},      --扑克列表
    --{k = "wCardType", t = "byte"}                               --出牌类型
}

--放弃出牌
cmd.CMD_S_PassCard = 
{
    {k = "cbTurnOver",   t = "byte"},                             --一轮结束
    {k = "wCurrentUser", t = "word"},                           --当前玩家
    {k = "wPassCardUser",t = "word"},                          --放弃玩家
}

--游戏结束
cmd.CMD_S_GameConclude = 
{
    --积分变量
    {k = "lCellScore",    t = "int"},                              --单元积分
    {k = "lGameScore",    t = "score", l = {3}},                   --游戏积分

    --春天标识
    {k = "bChunTian",    t = "byte"},                              --春天
    {k = "bFanChunTian", t = "byte"},                           --反春天

    --炸弹信息
    {k = "cbBombCount", t = "byte"},                            --炸弹个数
    {k = "cbEachBombCount", t = "byte",l = {cmd.PLAYER_COUNT}},--炸弹个数

    --游戏信息
    {k = "cbBankerScore",   t = "byte"},                          --叫分数目
    {k = "cbCardCount",     t = "byte",  l = {cmd.PLAYER_COUNT}},    --扑克数目
    {k = "cbHandCardData",  t = "byte", l = {cmd.FULL_COUNT}},   --扑克列表
}
--客户端命令结构
cmd.SUB_C_CALL_SCORE        = 1             --用户叫分
cmd.SUB_C_OUT_CARD          = 2             --用户出牌
cmd.SUB_C_PASS_CARD         = 3             --用户放弃
cmd.SUB_C_TRUSTEE           = 4             --用户托管
cmd.SUB_C_HONGBAO           = 5             --拆红包
cmd.SUB_C_HONG_CONGT        = 6             
cmd.SUB_GR_REDPACKET_RECORD  = 31--416          --发包记录
cmd.SUB_GR_RECORD_REDLIST		 =	130--417	

--当前局数
cmd.CMD_C_HongCoent =
{
    {k = "wChairID", t = "word"}, 
    {k = "wNumber",  t = "byte"}, 
}



cmd.CMD_GR_UserDismantlingred =
{
    {k = "wRedmoney", t = "score"},		
    {k = "wEndmoney", t = "score"},	
	{k = "wIdention", t = "dword"},		
	{k = "wNumber", t = "word"},    
	{k = "wPoint", t = "word"},	
    {k = "wRate", t = "double"},	
    {k = "wTime",           t = "string" ,s = 16},  --拆雷时间
};
--拆雷记录结果
cmd.CMD_GR_ChaiHong_Rcord=
{
    {k = "cbColumnCount", t = "byte"},									
	{k = "cbRecord", t = "table", d = cmd.CMD_GR_UserDismantlingred, l = {30}},
};


--记录数据
cmd.CMD_GR_UserDismanhongRed=
{
    {k = "wGetNumber",      t = "word"},	        --已经拆个数
    {k = "wTotalNumber",    t = "word"},	        --总雷个数
    {k = "wGetmoney",       t = "int"},	            --已经被拆金额
    {k = "wTotalmoney",     t = "score"},	        --总金额
    {k = "szUserName",      t = "string", s = 16},  --用户名称
    {k = "wThunder",        t = "word"},	        --是否中雷0-1
    {k = "wWinmoney",       t = "score"},           --拆雷金额
    {k = "wTime",           t = "string" ,s = 16},  --拆雷时间
    {k = "wFaceID",         t = "word"},            --头像ID
    {k = "wGameID",         t = "dword"},			--用户标识
    {k = "wHand",           t = "word"},			--手气最佳
    {k = "wFaceAddressp",   t = "string", s = 256}, --头像地址

};

--记录数据结果
cmd.CMD_GR_RedData_Results=
{
    {k = "cbColumnCount", t = "byte"},									
	{k = "cbRecord", t = "table", d = cmd.CMD_GR_UserDismanhongRed, l = {11}},
}

------
return cmd