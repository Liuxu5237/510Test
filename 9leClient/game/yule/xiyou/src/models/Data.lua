--
-- Author: Your Name
-- Date: 2015-09-15 16:36:04
--
--require "cocos.init"

--local Data = class("Data")
if not Data then 
	Data = {}
	-- 事件处理
	Data.msgMgr = {}

	-- 场景消息
	Data.GS_SO_FREE = 0          		-- 等待开始
	Data.GS_SO_OPERATE = 100 		  	-- 下注
	Data.GS_SO_MAINGAME  = 101    			-- 锁定
	Data.GS_SO_ENTERBATTLE = 102      		-- 开奖
	Data.GS_SO_ENTERBATTLEBEFOR = 103      			-- 游戏结束
	Data.GS_SO_BATTER = 104 
	Data.GS_SO_BONUS = 105 
	Data.GS_SO_SHOWLOGO = 106
	Data.GS_SO_WAIT = 200

	-- 客户端命令结构
	Data.SUB_C_SCENE_ENTER = 0
	Data.SUB_C_SCENE_START = 1
	Data.SUB_C_CHANGE_CHIPS_TYPE = 2
	Data.SUB_C_ADD_CHIPS = 3
	Data.SUB_C_CLEAN = 4
	Data.SUB_C_USE_LAST = 5
	Data.SUB_C_RESET_GAMESTATE = 6
	Data.SUB_C_ROUND_END = 7
	Data.SUB_C_INFO = 8
	Data.SUB_C_INIT = 9
	Data.SUB_C_BET = 10

	-- 服务器命令结构
	Data.SUB_S_UPDATE_STATUS = 100 				-- 开始下注
	Data.SUB_S_INIT = 101 			
	Data.SUB_S_START_GAME = 102 		
	Data.SUB_S_CHANGE_CHIPS_TYPE = 103 		-- 切换筹码
	Data.SUB_S_ADD_CHIPS = 104 				-- 加注
	Data.SUB_S_CLEAN = 105 					-- 清理下注
	Data.SUB_S_USE_LASE = 106 				-- 使用上次下注
	Data.SUB_S_RESET_GAMESTATE = 107
	Data.SUB_S_BET_STATUS = 108 			-- 下注阶段
	Data.SUB_S_INFO = 109

	-- 定义游戏初始时间
	Data.DEFINE_GAME_INIT_TIME = 8
	-- 定义押注时长
	Data.DEFINE_BET_TIME = 20
	-- 锁定
	Data.DEFINE_LOCK_TIME = 6
	-- 转动
	Data.DEFINE_REWARD_TIME = 24
	-- 特殊奖励
	Data.DEFINE_SP_REWARD_TIME = 30

	Data.DEFINE_ANI_END	= -1

	Data.DE_PAI = 3.1416
	Data.COR_PAI = 3.1416*0.5

	-- 转动次数
	Data.TURN_TABLE_MAX = 26

	-- 可押注
	Data.BET_TYPE = 11
	Data.IDI_GAME = 4		--- 游戏逻辑
	-- 概率基础值
	Data.BET_MAX = 10000
	Data.BET_UNIT = 1

	-- 头像类型
	Data.ERole_Monkey = 0
	Data.ERole_Sub = 1
	Data.ERole_Sha = 2
	Data.ERole_Pi = 3

	-- 怪物
	Data.Attack_WuKong =0
	Data.Attack_ZhiZhu = 1
	Data.Attack_YangJi = 2
	Data.Attack_GongZhu = 3
	Data.Attack_LongWang = 4
	Data.Attack_Count = 5

	-- 奖励类型
	Data.Choi_None = 0
	Data.Choi_Door = 1
	Data.Choi_Hole = 2
	Data.Choi_FourInOne = 3
	Data.Choi_Line = 4
	Data.Choi_SeventyTwoChange = 5
	Data.Choi_Gods = 6
	Data.Choi_Two = 7
	Data.Choi_Three = 8
	Data.Choi_Four = 9
	Data.Choi_FourKings = 10
	Data.Choi_WuKong = 11
	Data.Choi_HongHaiEr = 12
	Data.Choi_ShaWuJing = 13
	Data.Choi_NiuMoWang = 14
	Data.Choi_Red = 15
	Data.Choi_Green = 16
	Data.Choi_Yellow = 17
	Data.Choi_Thief = 18
	Data.Choi_Flowers = 19
	Data.Choi_Count = 20

	-- 游戏相关
	Data.curBetType = 1
	-- 下注
	Data.Bets = {}
	Data.lastBets = {}
	-- 确认下注
	Data.sureBet = 0
	-- 初始赢
	Data.curWin = 0
	Data.betCur = 0
	Data.curBetType = 1
	Data.curBetTypeValue = { 1000, 10000, 100000, 1000000, 5000000, 10000000}
	Data.arrayProbability = {
	{31,15,8,5},
	{35,17,10,6},
	{40,20,11,7},
	{25,12,7,4},
	{46,23,13,8},
	{28,14,8,5}}
	-- 记录头像坐标
	Data.curHeadPos = {}

	-- 转动起始值
	Data.nTurnIndex = 0 
	Data.nBrightCount = 0
	Data.nTurnTableCurrent = 0
	Data.nTurnTableTarget = 0
	Data.nTurnTableCount = 0
	Data.nTurnTableDelay = 0
	Data.nTurnCount = 0
	Data.nTurnTransit = 0
	Data.nTurnTableLaps = 0
	Data.bTurnTable = false

	-- 历史记录列表
	--Data.HistoryList = {"long","long","long","long","long","long","long","long","long","long"}
	Data.HistoryList = {}

	Data.GameBegin = nil

	-- 头像动画
	Data.nRunAnimal = {}
	Data.ArmBattleEnter = {"ZhiZhu","YangJian","GongZhu","LongWang"}
	Data.ArmBattleEnter1 = {"ShuiLianDong_1","NanTianMen","ShuiLianDong","NanTianMen_1"}
	Data.ArmBattleWin = {"ZhiZhu_Win","YangJian_Win","GongZhu_Win","LongWang_Win"}
	Data.ArmBattleWin1 = {"ShuiLianDong_Win_1","NanTianMen_Win","ShuiLianDong_Win","NanTianMen_Win_1"}
	Data.ArmBattleLose = {"ZhiZhu_Lose","YangJian_Lose","GongZhu_Lose","LongWang_Lose"}

	Data.BattleSkill = {}
	Data.BattleSkill[0] = {"ZhiZhu_skill_1","ZhiZhu_Skill_2","ZhiZhu_Skill3"}
	Data.BattleSkill[1] = {"YangJian_skill1","YangJian_skill2","YangJian_Skill_3"}
	Data.BattleSkill[2] = {"GongZhu_skill1","GongZhu_Skill2","GongZhu_Skill3"}
	Data.BattleSkill[3] = {"LongWang_Skill_1","LongWang_Skill2","LongWang_Skill3"}
	Data.BattleSkill[4] = {"MonkeySkill1","Monkey_Skill2","Monkey_skill"}
	Data.BattleSkill[5] = {"MonkeyBaoZou_skill1","MonkeyBaoZou_Skill2","MonkeyBaoZou_Skill3"}

	Data.BattleSkillFrame = {}
	Data.BattleSkillFrame[0] = {"ZhiZhu_skill_10","ZhiZhu_Skill_20","ZhiZhu_Skill30"}
	Data.BattleSkillFrame[1] = {"YangJian_skill10","YangJian_skill20","YangJian_Skill_30"}
	Data.BattleSkillFrame[2] = {"GongZhu_skill10","GongZhu_Skill20","GongZhu_Skill30"}
	Data.BattleSkillFrame[3] = {"LongWang_Skill_10","LongWang_Skill20","LongWang_Skill30"}
	Data.BattleSkillFrame[4] = {"MonkeySkill10","Monkey_Skill20","Monkey_skill0"}
	Data.BattleSkillFrame[5] = {"MonkeyBaoZou_skill10","MonkeyBaoZou_Skill20","MonkeyBaoZou_Skill30"}

	Data.BattleSoundFrame = {}
	Data.BattleSoundFrame[0] = {"ZhiZhu/4","ZhiZhu/9","ZhiZhu/7"}
	Data.BattleSoundFrame[1] = {"YangJi/6","YangJi/10","YangJi/5"}
	Data.BattleSoundFrame[2] = {"GongZhu/11","GongZhu/11","GongZhu/6"}
	Data.BattleSoundFrame[3] = {"LongWang/8","LongWang/2","LongWang/9"}
	Data.BattleSoundFrame[4] = {"WuKong/10","WuKong/10","WuKong/7"}
	Data.BattleSoundFrame[5] = {"WuKong/10","WuKong/13","WuKong/6"}

	-- 第一个为文件名 之后为动作名
	Data.NewFileLists = {"Action","PK_Monkey","WuKongVS","PK_ZZ","PK_YJ","PK_GZ","PK_LW"}
	-- 普通进入战斗
	Data.NewBaoVs = {"ZhiZhu_vs_1","YangJian_vs_1","GongZhu_vs_1","LongWang_vs_1"}
	-- 暴走进入战斗
	Data.NewVs = {"ZhiZhu_vs","YangJian_vs","GongZhu_vs","LongWang_vs"}
	-- 赢
	Data.NewBattleWin = {"ZhiZhu_vs_1","YangJian_vs_1","GongZhu_vs_1","LongWang_vs_1"}
	Data.NewBattleLose = {"ZhiZhu_vs_0","YangJian_vs_0","GongZhu_vs_0","LongWang_vs_0"}
	-- 普通怪物攻击
	Data.NewBattleLeft = {"ZhiZhu_vs","YangJian_vs","GongZhu_vs","LongWang_vs"}
	-- 暴走怪物攻击
	Data.NewBaoBattleLeft = {"ZhiZhu_vs","YangJian_vs","GongZhu_vs","LongWang_vs"}
	-- 悟空攻击
	Data.NewWuKongBattle = {"ZhiZhu_vs_1","YangJian_vs_1","GongZhu_vs_1","LongWang_vs_1"}
	-- 要加
	Data.NewBaoWuKongBattle = {"ZhiZhu_vs_1","YangJian_vs_1","GongZhu_vs_1","LongWang_vs_1"}
	-- 站立笑
	Data.NewXiaoBattle = {"ZhiZhu_vs_Win","YangJian_vs_Win","GongZhu_vs_Win","LongWang_vs_Win"}

	Data.NewEnterSound = {"Sound/ZhiZhu/8.mp3","Sound/YangJi/14.mp3","Sound/GongZhu/8.mp3","Sound/LongWang/11.mp3"}
	Data.AttackBossSound = {"Sound/ZhiZhu/1.mp3","Sound/YangJi/1.mp3","Sound/GongZhu/1.mp3","Sound/LongWang/1.mp3"}
	Data.BossFightSound1 = {"Sound/ZhiZhu/5.mp3","Sound/YangJi/2.mp3","Sound/GongZhu/7.mp3","Sound/LongWang/2.mp3"}
	Data.BossFightSound2 = {"Sound/ZhiZhu/6.mp3","Sound/YangJi/17.mp3","Sound/GongZhu/6.mp3","Sound/LongWang/13.mp3"}
	--特殊奖励
	Data.GameTypeResult = {"普通中奖","南天门","水帘洞","四海归一","连线彩金","七十二变","封神","二连","三连","四连","四大天王",
						   "孙悟空全中","红孩儿全中","沙悟净全中","牛魔王全中","红色全中","绿色全中","黄色全中","纵横四海",
						   "天女散花","连线彩金"}


	Data.MapSpeed = 150
	Data.BackMusic = 0
	Data.NeedChange = false
	-- 
	Data.oldFrame = nil
	Data.IsClean = false
	Data.nGameState = 0
	Data.bHistory = false
	-- 下注历史
	Data.history = {}
	--打斗背景
	Data.FightBG = nil
	--开门动画
	Data.studioAni = nil
	--站立笑
	Data.studioXiaoAni = nil
	--怪物赢
	Data.aniList = {}
	--特殊奖励
	Data.TypeResult = nil
	Data.bJackpot1 = false
	Data.bJackpot2 = false
	--悟空or怪物赢(1:悟空 2:怪物)
	Data.WhoWin = 0 
	--
	Data.nFirstAttack = 0 --1:悟空先，0:怪物先
	Data.nActionNum = 0   --奇数先手赢，偶数后手赢
	Data.nBaozou = 0 	  --暴击
	--是否打斗
	Data.isFight = false
	--连线彩金
	Data.GameJackpotScore = 0
	Data.GameJackpotWin = 0
	Data.isJackpot = false
end 

return Data