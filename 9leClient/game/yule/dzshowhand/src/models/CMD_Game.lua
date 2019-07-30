local cmd = cmd or {}

cmd.RES 						= "game/yule/dzshowhand/res/"
--游戏版本
cmd.VERSION 					= appdf.VersionValue(6,7,0,1)
--游戏标识
cmd.KIND_ID						= 3
	
--游戏人数
cmd.GAME_PLAYER					= 8

cmd.Z_GAME_PLAYER		    = 9

--全牌数目
cmd.FULL_COUNT                      = 52 

--最大扑克数目
cmd.MAX_COUNT                   = 2

cmd.MAX_CENTERCOUNT                 = 5

--视图位置
cmd.MY_VIEWID					= 1

--空闲状态
cmd.GAME_STATUS_FREE			= 0
--游戏状态
cmd.GAME_STATUS_PLAY			= 100

--***************服务端命令结构**************--
--[[
//服务器命令结构
#define SUB_S_GAME_START        100                 //游戏开始
#define SUB_S_ADD_SCORE         101                 //加注结果
#define SUB_S_GIVE_UP			102                 //放弃跟注  
#define SUB_S_SEND_CARD         103                 //发牌消息
#define SUB_S_GAME_END          104                 //游戏结束
#define SUB_S_SIT_DOWN          105                 //用户坐下
#define SUB_S_OPEN_CARD         106                 //用户开牌
#define SUB_S_SP_USER			107                 //特殊用户
]]
SUB_S_GAME_START                = 100               --游戏开始
SUB_S_ADD_SCORE                 = 101               --加注结果
SUB_S_GIVE_UP			        = 102               --放弃跟注
SUB_S_SEND_CARD                 = 103               --发牌消息
SUB_S_GAME_END                  = 104               --游戏结束
SUB_S_SIT_DOWN                  = 105               --用户坐下
SUB_S_OPEN_CARD                 = 106               --用户开牌
SUB_S_SP_USER			        = 107               --特殊用户

--***************客户端命令结构**************--
--[[
//客户端命令结构
#define SUB_C_ADD_SCORE         1					//用户加注
#define SUB_C_GIVE_UP			2					//放弃消息
#define SUB_C_OPEN_CARD         3					//开牌消息
]]
SUB_C_ADD_SCORE                 = 1					--用户加注
SUB_C_GIVE_UP			              = 2					--放弃消息
--SUB_C_OPEN_CARD                 = 3					--开牌消息

SUB_C_CHANGE_CARD				        =4									--换牌消息
SUB_C_CHANGE_FINISH			        =5									--换牌完成
SUB_C_SIT_DOWN					        =6									--用户坐下
SUB_C_OPEN_CARD				          =	7									--用户亮牌

--****************定时器标识******************--
--开始定时器
cmd.IDI_START_GAME   			= 200
--加注定时器
cmd.IDI_USER_ADD_SCORE			= 201
--延时定时器
 cmd.IDI_GAME_END_DELAY         = 202
--*****************时间标识*****************--
--开始定时器
cmd.TIME_START_GAME				= 15
--加注定时器
cmd.TIME_USER_ADD_SCORE			= 15

-- 语音动画
cmd.VOICE_ANIMATION_KEY = "voice_ani_key"     
 
--*****************自定义数据结构*****************--	
--[[
//游戏状态
struct CMD_S_StatusFree
{
  LONGLONG              lCellMinScore;				//最小下注
  LONGLONG              lCellMaxScore;				//最大下注
  LONGLONG              lGameInitScore[cmd.Z_GAME_PLAYER];           //游戏初始积分
};
]]
  -- { k = "lCellMinScore",  t = "score" },
    -- { k = "lCellMaxScore",  t = "score" },
    -- { k = "lGameInitScore",    t = "score", l = { cmd.Z_GAME_PLAYER } }
cmd.CMD_S_StatusFree = {
  { k = "bStatus",        t = "byte"},
  { k = "lCellMinScore",  t = "score" },
  { k = "lCellMaxScore",  t = "score" },
  { k = "lTakeMoney",     t = "score", l = { cmd.Z_GAME_PLAYER } },
  { k = "TakeMoneyDef",   t = "score"}
}

--[[
//游戏状态
struct CMD_S_StatusPlay
{
  //加注信息
  LONGLONG              lCellScore;					//单元下注
  LONGLONG              lTurnMaxScore;				//最大下注
  LONGLONG              lTurnLessScore;				//最小下注
  LONGLONG              lCellMaxScore;				//最大下注
  LONGLONG              lAddLessScore;				//加最小注
  LONGLONG              lTableScore[cmd.Z_GAME_PLAYER];   //下注数目
  LONGLONG              lTotalScore[cmd.Z_GAME_PLAYER];   //累计下注
  LONGLONG              lCenterScore;				//中心筹码

  //状态信息
  WORD					wDUser;						//D玩家
  WORD					wMinChipInUser;				//小盲注用户
  WORD					wCurrentUser;				//当前玩家
  BYTE					cbPlayStatus[cmd.Z_GAME_PLAYER];  //游戏状态
  BYTE                  cbBalanceCount;				//平衡次数

  //扑克信息
  BYTE					cbCenterCardData[cmd.MAX_CENTERCOUNT ];	//扑克数目
  BYTE					cbHandCardData[cmd.Z_GAME_PLAYER];			//桌面扑克
  LONGLONG               lGameInitScore[cmd.Z_GAME_PLAYER];    //游戏初始积分
  LONGLONG             lUserMaxScore[cmd.Z_GAME_PLAYER];  //玩家携带初始积分
};
]]
cmd.CMD_S_StatusPlay = {
    { k = "bStatus",      t = "byte"},

    --//加注信息
    { k = "lCellScore",     t = "score" },
    { k = "lTurnMaxScore",  t = "score" },
    { k = "lTurnLessScore", t = "score" },
    { k = "lCellMaxScore",  t = "score" },
    { k = "lAddLessScore",  t = "score" },
    { k = "lTableScore",    t = "score", l = { cmd.Z_GAME_PLAYER } },
    { k = "lTotalScore",    t = "score", l = { cmd.Z_GAME_PLAYER } },
    { k = "lTakeMoney",     t = "score", l = { cmd.Z_GAME_PLAYER } },
    { k = "lCenterScore",   t = "score" },
    --状态信息
    { k = "wDUser",         t = "word" },
   -- { k = "wMinChipInUser", t = "word" },
    { k = "wCurrentUser",   t = "word" },
    { k = "cbPlayStatus",   t = "byte",  l = { cmd.Z_GAME_PLAYER } },
    { k = "cbBalanceCount", t = "byte" },
    --扑克信息
    { k = "cbCenterCardData",t = "byte", l = { cmd.MAX_CENTERCOUNT  } },
    { k = "cbHandCardData", t = "byte",  l = { cmd.MAX_COUNT   } },
    { k = "TakeMoneyDef", t = "score" },
    -- { k = "lGameInitScore",    t = "score", l = { cmd.Z_GAME_PLAYER } },
    -- { k = "lUserMaxScore",    t = "score", l = { cmd.Z_GAME_PLAYER } }
}

--[[
//发送扑克
struct CMD_S_GameStart
{
  WORD					wCurrentUser;				//当前玩家
  WORD					wDUser;						//D玩家
  WORD					wMinChipInUser;				//小盲注用户
  WORD					wMaxChipInUser;				//大盲注玩家
  LONGLONG              lCellScore;					//单元下注
  LONGLONG              lTurnMaxScore;				//最大下注
  LONGLONG              lTurnLessScore;				//最小下注
  LONGLONG              lAddLessScore;				//加最小注
  BYTE					cbCardData[cmd.Z_GAME_PLAYER][cmd.MAX_COUNT  ]; //用户扑克
  LONGLONG               lGameInitScore[cmd.Z_GAME_PLAYER];  //玩家初始积分
  LONGLONG             lUserMaxScore[cmd.Z_GAME_PLAYER];  //玩家携带初始积分
};
]]
cmd.CMD_S_GameStart = {
    { k = "wCurrentUser",       t = "word" },
    { k = "wDUser",             t = "word" },
    --{ k = "wMinChipInUser",     t = "word" },
    { k = "wMaxChipInUser",     t = "word" },
    { k = "lCellScore",         t = "score" },
    { k = "lTurnMaxScore",      t = "score" },
    { k = "lTurnLessScore",     t = "score" },
    { k = "lAddLessScore",      t = "score" },
    { k = "lTakeMoney",         t = "score", l = {cmd.Z_GAME_PLAYER} },
    { k = "cbCardData",         t = "byte", l = {2,2,2,2,2,2,2,2,2 } },
    { k = "cbAllData",         t = "byte", l = { 2,2,2,2,2,2,2,2,2 } },
    { k = "PreScore",           t = "int"},
  
}

--[[
//发送扑克
struct CMD_S_SpUser
{
  BYTE					cbAllData[cmd.Z_GAME_PLAYER][cmd.MAX_COUNT  ];  //用户扑克
  BYTE					cbCenterCardData[cmd.MAX_CENTERCOUNT ];  //中心扑克
};
]]
-- cmd.CMD_S_SpUser = {
--     { k = "cbAllData",          t = "byte", l = { cmd.MAX_COUNT  , cmd.MAX_COUNT  , cmd.MAX_COUNT  , cmd.MAX_COUNT  ,
--     cmd.MAX_COUNT  , cmd.MAX_COUNT  , cmd.MAX_COUNT  , cmd.MAX_COUNT   } },
--     { k = "cbCenterCardData",   t = "byte", l = { cmd.MAX_CENTERCOUNT  } },
-- }

--[[
//用户下注
struct CMD_S_AddScore
{
  WORD					wCurrentUser;				//当前用户
  WORD					wAddScoreUser;				//加注用户
  LONGLONG              lAddScoreCount;				//加注数目
  LONGLONG              lTurnLessScore;				//最少加注
  LONGLONG              lTurnMaxScore;				//最大下注
  LONGLONG              lAddLessScore;				//加最小注
  BYTE					cbShowHand[cmd.Z_GAME_PLAYER];    //梭哈用户
};
]]
cmd.CMD_S_AddScore = {
    { k = "wCurrentUser",       t = "word" },
    { k = "wAddScoreUser",      t = "word" },
    { k = "lAddScoreCount",     t = "score" },
    { k = "lTurnLessScore",     t = "score" },
    { k = "lTurnMaxScore",      t = "score" },
    { k = "lAddLessScore",      t = "score" },
    { k = "bAddGiveUp",         t = "bool"},
    { k = "cbShowHand",         t = "byte", l = { cmd.Z_GAME_PLAYER } },
}

--[[
//用户放弃
struct CMD_S_GiveUp
{
  WORD					wGiveUpUser;				//放弃用户
  LONGLONG              lLost;						//输掉金币
};
]]
cmd.CMD_S_GiveUp = {
    { k = "wGiveUpUser",    t = "word" },
    { k = "lLost",          t = "score" },
}

--[[
//发牌数据包
struct CMD_S_SendCard
{
  BYTE					cbPublic;					//是否公牌
  WORD					wCurrentUser;				//当前用户
  BYTE					cbSendCardCount;			//发牌数目
  BYTE					cbCenterCardData[cmd.MAX_CENTERCOUNT ];  //中心扑克
};
]]
cmd.CMD_S_SendCard = {
    { k = "cbPublic",         t = "byte" },
    { k = "wCurrentUser",     t = "word" },
    { k = "cbSendCardCount",  t = "byte" },
    { k = "cbCenterCardData", t = "byte", l = { cmd.MAX_CENTERCOUNT  } },
    { k = "cbLastCardKind" ,  t = "byte", l = {cmd.Z_GAME_PLAYER}}
}

--[[
//游戏结束
struct CMD_S_GameEnd
{
  BYTE					cbTotalEnd;					//强退标志
  LONGLONG				lGameTax[cmd.Z_GAME_PLAYER];      //游戏税收
  LONGLONG				lGameScore[cmd.Z_GAME_PLAYER];    //游戏得分
  BYTE					cbCardData[cmd.Z_GAME_PLAYER][cmd.MAX_COUNT  ]; //用户扑克
  BYTE					cbLastCenterCardData[cmd.Z_GAME_PLAYER][cmd.MAX_CENTERCOUNT ];//最后扑克
  BYTE					cbDelayOverGame;
  BYTE                  cbEndCardKind[cmd.Z_GAME_PLAYER];                 //最后的牌型
  LONGLONG            lGameInitScore[cmd.Z_GAME_PLAYER];                //游戏积分
};
]]
cmd.CMD_S_GameEnd = {
    { k = "cbPublic",            t = "byte" },
    { k = "lGameTax",            t = "score", l = { cmd.Z_GAME_PLAYER } },
    { k = "lGameScore",          t = "score", l = { cmd.Z_GAME_PLAYER } },	
    { k = "lTakeMoney",          t = "score" , l ={cmd.Z_GAME_PLAYER}},
    { k = "cbCardData",          t = "byte", l = { cmd.MAX_COUNT  , cmd.MAX_COUNT  , cmd.MAX_COUNT  , cmd.MAX_COUNT  ,
    cmd.MAX_COUNT  , cmd.MAX_COUNT  , cmd.MAX_COUNT  , cmd.MAX_COUNT , cmd.MAX_COUNT  } },
    { k = "cbLastCenterCardData",t = "byte", l = { cmd.MAX_CENTERCOUNT , cmd.MAX_CENTERCOUNT , cmd.MAX_CENTERCOUNT , cmd.MAX_CENTERCOUNT ,
    cmd.MAX_CENTERCOUNT , cmd.MAX_CENTERCOUNT , cmd.MAX_CENTERCOUNT , cmd.MAX_CENTERCOUNT,cmd.MAX_CENTERCOUNT  } },
   -- { k = "cbDelayOverGame",     t = "byte" },

    { k = "cbLastCardKind",       t = "byte" ,l = { cmd.Z_GAME_PLAYER }},
    { k = "UserRank",             t = "byte", l = {cmd.Z_GAME_PLAYER}}
    --{ k = "lGameInitScore",      t = "score", l = { cmd.Z_GAME_PLAYER } }
} 

--[[
//游戏结束
struct CMD_S_OpenCard
{
  WORD					wWinUser;					//用户开牌
};
]]
cmd.CMD_S_OpenCard = {
    --{ k = "wWinUser",            t = "word" },
    {k = "wChairID" , t = "word"},
    {k = "card"     ,  t = "byte" , l = {cmd.MAX_COUNT}}
}

return cmd