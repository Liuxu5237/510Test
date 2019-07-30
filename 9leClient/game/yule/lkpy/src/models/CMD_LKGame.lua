--onSocketCallBack main
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd  = {}

--游戏版本
cmd.VERSION  			= appdf.VersionValue(1,0,0,1)
--游戏标识
cmd.KIND_ID				= 2010
--游戏人数
-- cmd.GAME_PLAYER    = 6
--房间名长度
cmd.SERVER_LEN			= 32

cmd.INT_MAX = 2147483647

cmd.Event_LoadingFish  = "Event_LoadingFinish"
cmd.Event_FishCreate   = "Event_FishCreate"

--背景音乐
cmd.bgm1 = "sound_res/bgm1.wav"
cmd.bgm2 = "sound_res/bgm2.wav"
cmd.bgm3 = "sound_res/bgm3.wav"
cmd.bgm4 = "sound_res/bgm4.wav"
--音效
cmd.bingo        = "sound_res/bingo.wav"
cmd.cannonSwitch = "sound_res/cannonSwitch.wav"
cmd.casting      = "sound_res/casting.wav"
cmd.catch        = "sound_res/catch.wav"
cmd.superarm     = "sound_res/superarm.wav"
cmd.fire         = "sound_res/fire.wav"

--cmd.gold         = "sound_res/gold.wav"
--cmd.insert       = "sound_res/insert.wav"
--cmd.ion_casting  = "sound_res/ion_casting.wav"
cmd.ion_catch    = "sound_res/ion_catch.wav"
cmd.ion_fire     = "sound_res/ion_fire.wav"
cmd.ion_get      = "sound_res/ion_get.wav"
cmd.lock         = "sound_res/lock.wav"
cmd.silver       = "sound_res/silver.wav"

cmd.wave         = "sound_res/wave.wav"

cmd.fish10_1     = "sound_res/fish10_1.wav"
cmd.fish10_2     = "sound_res/fish10_2.wav"

cmd.fish11_1     = "sound_res/fish11_1.wav"
cmd.fish11_2     = "sound_res/fish11_2.wav"

cmd.fish12_1     = "sound_res/fish12_1.wav"
cmd.fish12_2     = "sound_res/fish12_2.wav"

cmd.fish13_1     = "sound_res/fish13_1.wav"
cmd.fish13_2     = "sound_res/fish13_2.wav"

cmd.fish14_1     = "sound_res/fish14_1.wav"
cmd.fish14_2     = "sound_res/fish14_2.wav"

cmd.fish15_1     = "sound_res/fish15_1.wav"
cmd.fish15_2     = "sound_res/fish15_2.wav"

cmd.fish16_1     = "sound_res/fish16_1.wav"
cmd.fish16_2     = "sound_res/fish16_2.wav"

cmd.fish17_1     = "sound_res/fish17_1.wav"
cmd.fish17_2     = "sound_res/fish17_2.wav"
cmd.fish17_3     = "sound_res/fish17_3.wav"
cmd.fishEffect = 
{
  [10] = {cmd.fish10_1, cmd.fish10_2},
  [11] = {cmd.fish11_1, cmd.fish11_2},
  [12] = {cmd.fish12_1, cmd.fish12_2},
  [13] = {cmd.fish13_1, cmd.fish13_2},
  [14] = {cmd.fish14_1, cmd.fish14_2},
  [15] = {cmd.fish15_1, cmd.fish15_2},
  [16] = {cmd.fish16_1, cmd.fish16_2},
  [17] = {cmd.fish17_1, cmd.fish17_2, cmd.fish17_3},
}

--鱼索引
-- 正常鱼
cmd.FISH_XIAO_HUANG_YU			= 0								-- 小黄鱼
cmd.FISH_XIAO_LAN_YU			= 1								-- 小蓝鱼
cmd.FISH_XIAO_CHOU_YU			= 2								-- 小丑鱼
cmd.FISH_SI_LU_YU				= 3								-- 丝鲈鱼
cmd.FISH_SHENG_XIAN_YU			= 4								-- 神仙鱼
cmd.FISH_HE_TUN_YU				= 5								-- 河豚鱼
cmd.FISH_DENG_LONG_YU			= 6								-- 灯笼鱼
cmd.FISH_BA_ZHUA_YU				= 7								-- 八爪鱼
cmd.FISH_HAI_GUI				= 8								-- 海龟
cmd.FISH_SHUI_MU				= 9								-- 水母
cmd.FISH_JIAN_YU				= 10							-- 剑鱼
cmd.FISH_MO_GUI_YU				= 11							-- 魔鬼鱼
cmd.FISH_HAI_TUN				= 12							-- 海豚
cmd.FISH_SHA_YU					= 13							-- 鲨鱼
cmd.FISH_LAN_JING				= 14							-- 蓝鲸
cmd.FISH_YIN_JING				= 15							-- 银鲸
cmd.FISH_JIN_JING				= 16							-- 金鲸
cmd.FISH_MEI_REN_YU				= 17							-- 美人鱼


-- 特殊鱼
cmd.FISH_ZHA_DAN				= 18							-- 炸弹
cmd.FISH_XIANG_ZI				= 19							-- 补给箱

-- 鱼索引
cmd.FISH_KING_MAX				= 7								-- 最大灯笼鱼
cmd.FISH_NORMAL_MAX				= 18							-- 正常鱼索引
cmd.FISH_ALL_COUNT				= 20							-- 鱼最大数

-- 特殊鱼
cmd.SPECIAL_FISH_BOMB			= 0								-- 炸弹鱼
cmd.SPECIAL_FISH_CRAB			= 1								-- 螃蟹
cmd.SPECIAL_FISH_MAX			= 2								-- 最大数量

-- 渔网 
cmd.NET_COLOR_GREEN				= 0								-- 绿色网
cmd.NET_COLOR_BLUE				= 1								-- 蓝色网
cmd.NET_COLOR_YELLOW			= 2								-- 黄色网
cmd.NET_COLOR_RED				= 3								-- 红色网
cmd.NET_COLOR_PURPLE			= 4								-- 紫色网
cmd.NET_MAX_COLOR				= 5								-- 最大颜色数(随机值)

-- 道具
cmd.PROP_ICE_NET				= 0								-- 冰网
cmd.PROP_BROKEN_ICE				= 1								-- 破冰器
cmd.PROP_CLOUDY_AGENT			= 2								-- 混浊剂
cmd.PROP_ARMOUR_PIERCING		= 3								-- 穿甲弹
cmd.PROP_EJECTION				= 4								-- 弹射弹
cmd.PROP_TRACKING				= 5								-- 追踪弹
cmd.PROP_SHOTGUN				= 6								-- 散弹
cmd.PROP_ACCELERA				= 7								-- 加速弹
cmd.PROP_COUNT_MAX				= 8								-- 总数

-- 倍数索引
cmd.MULTIPLE_MAX_INDEX			= 6	

cmd.S_TOP_LEFT					= 0								-- 服务器位置
cmd.S_TOP_CENTER				= 1								-- 服务器位置
cmd.S_TOP_RIGHT					= 2								-- 服务器位置
cmd.S_BOTTOM_LEFT				= 3								-- 服务器位置
cmd.S_BOTTOM_CENTER				= 4								-- 服务器位置
cmd.S_BOTTOM_RIGHT				= 5								-- 服务器位置

cmd.C_TOP_LEFT					= 0								-- 视图位置
cmd.C_TOP_CENTER				= 1								-- 视图位置
cmd.C_TOP_RIGHT					= 2								-- 视图位置
cmd.C_BOTTOM_LEFT				= 3								-- 视图位置
cmd.C_BOTTOM_CENTER				= 4								-- 视图位置
cmd.C_BOTTOM_RIGHT				= 5								-- 视图位置

-- 相对窗口
cmd.DEFAULE_WIDTH				= 1280						    -- 客户端相对宽
cmd.DEFAULE_HEIGHT				= 800							-- 客户端相对高	
cmd.OBLIGATE_LENGTH				= 300							-- 预留宽度

cmd.CAPTION_TOP_SIZE			= 25							-- 标题大小
cmd.CAPTION_BOTTOM_SIZE			= 40							-- 标题大小

-- 炮弹
cmd.BULLET_ONE				= 0								-- 一号炮
cmd.BULLET_TWO				= 1								-- 二号炮
cmd.BULLET_THREE			= 2								-- 三号炮
cmd.BULLET_FOUR				= 3								-- 四号炮
cmd.BULLET_FIVE				= 4								-- 五号炮
cmd.BULLET_SIX				= 5								-- 六号炮
cmd.BULLET_SEVEN			= 6								-- 七号炮
cmd.BULLET_EIGHT			= 7								-- 八号炮
cmd.BULLET_MAX				= 8								-- 最大炮种类


-- 最大路径
cmd.BEZIER_POINT_MAX			= 8

--千炮消耗
cmd.QIAN_PAO_BULLET				= 1
--游戏玩家
cmd.PlayChair_Max 				= 6
cmd.PlayChair_Invalid			= 0xffff
cmd.PlayName_Len				  = 32
cmd.QianPao_Bullet     		= 1
cmd.Multiple_Max  				= 6

cmd.Tag_Fish              = 10
cmd.Tag_Bullet            = 11

cmd.Fish_MOVE_TYPE_NUM    = 23
cmd.Fish_DEAD_TYPE_NUM    = 24

--枚举
----------------------------------------------------------------------------------------------
cmd.TAG_START 					= 1

local enumScoreType =
{
	
	"EST_Cold",				--游戏币
  "EST_YuanBao",   --元宝
	"EST_Laser",			--激光
	"EST_Speed",			--加速
	"EST_Gift",				--赠送
	"EST_NULL"
}

cmd.SupplyType =  ExternalFun.declarEnumWithTable(0,enumScoreType)

--房间类型
local enumRoomType = 
{
	"ERT_Unknown",						--无效
	"ERT_QianPao",						--千炮
	"ERT_Moni"							--模拟
}

cmd.RoomType = ExternalFun.declarEnumWithTable(0,enumRoomType)

local enumCannonType = 
{

  "Normal_Cannon", --正常炮
  "Bignet_Cannon",--网变大
  "Special_Cannon",--加速炮
  "Laser_Cannon",--激光炮
  "Laser_Shooting"--激光发射中
}
cmd.CannonType = ExternalFun.declarEnumWithTable(0,enumCannonType)

--道具类型
local enumPropObjectType =
{

	"POT_NULL",										-- 无效
	"POT_ATTACK",									-- 攻击
	"POT_DEFENSE",									-- 防御
	"POT_BULLET",									-- 子弹

}

cmd.PropObjectType = ExternalFun.declarEnumWithTable(0,enumPropObjectType)


local enumFishState = 
{

	  "FishState_Normal",		-- 普通鱼
    "FishState_King",		-- 鱼王
    "FishState_Killer",		-- 杀手鱼
    "FishState_Aquatic",	-- 水草鱼
}
cmd.FishState = ExternalFun.declarEnumWithTable(0,enumFishState)
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
--服务器命令结构
	  -- cmd.SUB_S_SYNCHRONOUS 	= 101					-- 同步信息101
   --  cmd.SUB_S_FISH_CREATE	= 102					  -- 鱼创建102
   --  cmd.SUB_S_FISH_CATCH  	= 103					-- 捕获鱼103
   --  cmd.SUB_S_FIRE		    = 104					  -- 开火104
   --  cmd.SUB_S_EXCHANGE_SCENE= 105					-- 转换场景105
   --  cmd.SUB_S_OVER          = 106    			-- 结算106
   --  cmd.SUB_S_DELAY_BEGIN   = 107					-- 延迟107
   --  cmd.SUB_S_DELAY	    = 108					  -- 延迟108
   --  cmd.SUB_S_BEGIN_LASER   = 109					-- 准备激光109
   --  cmd.SUB_S_LASER	    = 110					  -- 激光110
   --  cmd.SUB_S_BANK_TAKE		= 111					  -- 银行取款111
   --  cmd.SUB_S_SPEECH		= 112					    -- 语音消息112
   --  cmd.SUB_S_SYSTEM		= 113					    -- 系统消息113
   --  cmd.SUB_S_MULTIPLE		= 114					  -- 倍数消息114
   --  cmd.SUB_S_SUPPLY_TIP	= 115					  -- 补给提示115
   --  cmd.SUB_S_SUPPLY		= 116					    -- 补给消息116
   --  cmd.SUB_S_AWARD_TIP		= 117					  -- 分数提示117
   --  cmd.SUB_S_CONTROL		= 118					    -- 控制消息118
   --  cmd.SUB_S_UPDATE_GAME	= 119					  -- 更新游戏119
   --  cmd.SUB_S_STAY_FISH		= 120					  -- 停留鱼120

-----------------------------------------------------------------------------------------------

--顶点
cmd.CDoulbePoint = 
{

	{k="x",t="double"},
	{k="y",t="double"}
}

cmd.ShortPoint = 
{

	{k="x",t="short"},
	{k="y",t="short"}
}

cmd.tagBezierPoint = 
{
 {k="BeginPoint",t="table",d=cmd.CDoulbePoint},
 {k="EndPoint",t="table",d=cmd.CDoulbePoint},
 {k="KeyOne",t="table",d=cmd.CDoulbePoint},
 {k="KeyTwo",t="table",d=cmd.CDoulbePoint},
 {k="Time",t="dword"}

}



--鱼创建完成
cmd.CMD_S_FishFinish = 
{
	{k="nOffSetTime",t="dword"}
}

--捕获鱼
cmd.CMD_S_CatchFish = 
{
	{k="nFishIndex",t="int"},
	{k="wChairID",t="word"},
	{k="nMultipleCount",t="int"},
	{k="lScoreCount",t="score"},
  {k="nFishType",t="byte"},
}

--开火
cmd.CMD_S_Fire = 
{
  {k="nBulletKey",t="int"},						-- 子弹关键值
  {k="nBulletScore",t="int"},					-- 子弹分数
  {k="nMultipleIndex",t="int"},					-- 倍数索引
  {k="nTrackFishIndex",t="int"},				-- 追踪鱼索引
  {k="wChairID",t="word"},						-- 玩家位置
  {k="ptPos",t="table",d=cmd.ShortPoint}		-- 位置

}
--补给信息
cmd.CMD_S_Supply = 
{

  {k="wChairID",t="word"},
  {k="lSupplyCount",t="score"},
  {k="nSupplyType",t="int"}
}

cmd.CMD_S_Multiple = 
{

  {k="wChairID",t="word"},
  {k="nMultipleIndex",t="int"}
}

--激光
cmd.CMD_S_Laser = 
{
	{k="wChairID",t="word"},
	{k="ptBeginPos",t="table",d=cmd.ShortPoint},
  {k="ptEndPos",t="table",d=cmd.ShortPoint}
}

--转换场景
cmd.CMD_S_ChangeSecene =
{
 {k="cbBackIndex",t="byte"}
}

cmd.CMD_S_StayFish = 
{
 {k="nFishKey",t="int"},
 {k="nStayStart",t="int"},
 {k="nStayTime",t="int"}
}

cmd.CMD_S_SupplyTip = 
{

  {k="wChairID",t="word"}
}

cmd.CMD_S_AwardTip = 
{

  {k="wTableID",t="word"},
  {k="wChairID",t="word"},
  {k="szPlayName",t="string",s=32},
  {k="nFishType",t="byte"},
  {k="nFishMultiple",t="int"},
  {k="lFishScore",t="score"},
  {k="nScoreType",t="int"}
}

cmd.CMD_S_UpdateGame = 
{
  {k="nMultipleValue",t="int",l={cmd.Multiple_Max}},
  {k="nFishMultiple",t="int",l={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}},
  {k="nBulletVelocity",t="int"},
  {k="nBulletCoolingTime",t="int"}
}

--银行
cmd.CMD_S_BankTake = 
{
  {k="wChairID",t="word"},
  {k="lPlayScore",t="score"},
}

--场景信息
cmd.GameScene = 
{
  -- {k="cbBackIndex",t="byte"},
  -- {k="lPlayScore",t="score"},
  -- {k="lPalyCurScore",t="score",l={cmd.GAME_PLAYER}},
  -- {k="lPlayStartScore",t="score",l={cmd.GAME_PLAYER}},
  -- {k="lCellScore",t="int"},
  -- {k="nBulletVelocity",t="int"},
  -- {k="nBulletCoolingTime",t="int"},
  -- {k="nFishMultiple",t="int",l={2,2,2,2,2, 2,2,2,2,2, 2,2,2,2,2, 2,2,2,2,2, 2,2,2,2,2,2}},
  -- {k="nMaxTipsCount",t="int"},
  -- {k="lBulletConsume",t="score",l={cmd.PlayChair_Max}},
  -- {k="lPlayFishCount",t="int",l={6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6}},
  -- {k="nMultipleValue",t="int",l={cmd.Multiple_Max}},
  -- {k="nMultipleIndex",t="int",l={cmd.PlayChair_Max}},
  -- {k="bUnlimitedRebound",t="bool"},
  -- {k="szBrowseUrl",t="string"}

  {k="game_version",t="dword"}, --游戏版本
  {k="fish_score",t="score"}, --鱼分数
  {k="bullet_count",t="score"}, --子弹数量
  {k="exchange_fish_score",t="score"}, --交换鱼分数
  {k="bullet_score",t="score"}, --子弹分数
  {k="bullet_price",t="table",d = cmd.BulletPrice, l = {cmd.BUY_BULLET_TYPE_MAX}}, --各种子弹的价格和数量
  {k="sceneID",t="int"}, --场景id
  --结构 cmd_table[key] = ExternalFun.readTableHelper({dTable = keys["d"], lentable = lenT, buffer = dataBuffer, strkey = key})

}

----------------------------------------------------------------------------------------------
--客户端命令结构
cmd.SUB_C_CATCH_FISH = 101              --捕鱼信息
cmd.SUB_C_FIRE       = 102              --开火
cmd.SUB_C_DELAY      = 103              -- 延迟
cmd.SUB_C_BEGIN_LASER= 104              -- 准备激光
cmd.SUB_C_LASER      = 105              -- 激光
cmd.SUB_C_SPEECH     = 106              -- 语音消息
cmd.SUB_C_MULTIPLE   = 107              -- 倍数消息
cmd.SUB_C_CONTROL    = 108              -- 控制消息


-----------------------------------------------------------------------------------------------
----------------------------------------------------------new add-------------------------------------
cmd.WSCALE = cc.Director:getInstance():getVisibleSize().width / 1334
cmd.HSCALE = cc.Director:getInstance():getVisibleSize().height / 750
--服务器发过来的命令
cmd.SUB_S_GAME_CONFIG             = 100         --配置信息
cmd.SUB_S_FISH_TRACE              = 122         --鱼跟踪
cmd.SUB_S_EXCHANGE_FISHSCORE      = 123         --用户上分
cmd.SUB_S_FIRE                    = 124         -- 开火104
cmd.SUB_S_FISH_CATCH              = 113--125         -- 捕获鱼103
cmd.SUB_S_BULLET_ION_TIMEOUT      = 126         -- 能量炮结束
cmd.SUB_S_LOCK_TIMEOUT            = 127         -- 定屏结束
cmd.SUB_S_CATCH_SWEEP_FISH_RESULT = 129         -- 扫描捕获鱼结果
cmd.SUB_S_HIT_FISH_LK             = 130         -- 李逵倍数变更
cmd.SUB_S_EXCHANGE_SCENE          = 131         -- 转换场景105
cmd.SUB_S_SCENE_END               = 133         -- 场景结束
cmd.SUB_S_FISHSCORETOBULLET       = 134         -- 用户下分
cmd.SUB_S_GET_TASK_FISH_PROGRESS  = 138         -- 鱼任务信息下发
cmd.SUB_S_GET_TASK_FISH_PRIZE     = 139         -- 领取捕鱼任务奖励



--zzy服务器命令
cmd.SUB_S_CHANGE_SCENE = 100        --切换场景
cmd.SUB_S_BUY_BULLET_SUCCESS = 101  --购买子弹成功
cmd.SUB_S_BUY_BULLET_FAILED = 102   --购买子弹失败
cmd.SUB_S_SEND_BULLET       = 109   --开火
cmd.SUB_S_SEND_BIRD         = 107   --创建鱼
cmd.SUB_S_FISH_CATCH        = 113   --捕鱼

cmd.SUB_S_SEND_BIRD_LINEAR		=		132		--发送特殊鱼阵
cmd.SUB_S_SEND_BIRD_ROUND		=		133
cmd.SUB_S_SEND_BIRD_PAUSE_LINEAR=		137
cmd.SUB_S_CATCH_BIRD_CHAIN		=		134		--闪电鱼

--zzy客户端命令
cmd.SUB_C_BUY_BULLET			=		200		--兑换鱼币
cmd.SUB_C_FIRE					=		201		--/开炮

--客户端命令结构
cmd.SUB_C_EXCHANGE_FISHSCORE = 111              --交换鱼得分
cmd.SUB_C_USER_FIRE       = 112                 --用户开火
cmd.SUB_C_CATCH_FISH      = 113                 -- 捕到鱼
cmd.SUB_C_CATCH_SWEEP_FISH= 114                 -- 捕获扫描鱼
cmd.SUB_C_HIT_FISH_I      = 115                 -- 打中鱼
cmd.SUB_C_STOCK_OPERATE     = 116               -- 语音消息
cmd.SUB_C_USER_FILTER   = 117                   -- 用户过滤
cmd.SUB_C_ANDROID_STAND_UP    = 118             -- 手机的
cmd.SUB_C_FISH20_CONFIG    = 119                -- 20种鱼的配置
cmd.SUB_C_BUY_BULLETS    = 121                  -- 购买子弹
cmd.SUB_C_CALE_FISHSCORETOBULLETS    = 122      -- 结算
cmd.SUB_C_GET_TASK_FISH_PROGRESS    = 123       -- 取捕鱼任务信息
cmd.SUB_C_GET_TASK_FISH_PRIZE    = 124          -- 领取捕鱼任务奖励
cmd.SUB_C_EERVER_CMD_TEST    = 125              -- 取服务端交易测试
cmd.SUB_C_GET_TASK_FISH_TYPE_PRIZE    = 126     -- 领取某种捕鱼任务奖励

------------------------------------------------------------------------------------------------
cmd.APPNAME             = "李逵劈鱼"
cmd.GAME_PLAYER         = 8   --最大游戏人数
cmd.MAX_FISH_COUNT      = 300 --场景最大支持鱼数量
cmd.MAX_FISH_TASK_COUNT = 21  --捕鱼任务数量
cmd.kResolutionWidth    = 1366--分辨率宽
cmd.kResolutionHeight   = 768 --分辨率高
cmd.BUY_BULLET_TYPE_MAX = 3 --子弹购买界面，有多少种子弹
cmd.FISH_KIND_HAVE_SCORE = 23 --有分鱼种类数量

cmd.M_PI   = 3.14159265358979323846
cmd.M_PI_2 = 1.57079632679489661923
cmd.M_PI_4 = 0.785398163397448309616
cmd.M_1_PI = 0.318309886183790671538
cmd.M_2_PI = 0.636619772367581343076
cmd.kChairDefaultAngle = {cmd.M_PI, cmd.M_PI, cmd.M_PI, -cmd.M_PI_2, 0, 0, 0, cmd.M_PI_2}

cmd.FPOINTNUM = 5 -- 鱼顶点坐标数量
cmd.GAMECONFIGNUM = 6 -- 配置数据长度

--跟踪类型
cmd.TraceType = 
{
    TRACE_LINEAR = 0, --跟踪直线
    TRACE_BEZIER = 1, --跟踪曲线
}

cmd.FPoint = --
{
    {k="x",t="float"},
    {k="y",t="float"}
}

--场景类型
cmd.SceneKind = 
{
    SCENE_KIND_1 = 0,
    SCENE_KIND_2 = 1,
    SCENE_KIND_3 = 2,
    SCENE_KIND_4 = 3,
    SCENE_KIND_5 = 4,

    SCENE_KIND_COUNT = 5
}

--子弹类型
cmd.BulletKind = 
{
    BULLET_KIND_1_NORMAL = 0,   --子弹类型1正常
    BULLET_KIND_2_NORMAL = 1,
    BULLET_KIND_3_NORMAL = 2,
    BULLET_KIND_4_NORMAL = 3,
    BULLET_KIND_1_ION    = 4,        --子弹类型1离子
    BULLET_KIND_2_ION    = 5,
    BULLET_KIND_3_ION    = 6,
    BULLET_KIND_4_ION    = 7,

    BULLET_KIND_COUNT    = 8
}

--购买子弹的种类
cmd.BuyBulletKind = 
{
    BUY_BULLET_1   = 0,
    BUY_BULLET_2   = 1,
    BUY_BULLET_3   = 2,
    BUY_BULLET_MAX = 3,
    BUY_BULLET_ALL = 4      --玩家携带的金币全部购买子弹
}

cmd.BulletPrice = --wyf
{

    {k="price",t="int"}, --价格     金币
    {k="bullets",t="int"}--子弹数量 鱼币
}

cmd.kBulletIonTime = 8  --发射子弹离子时间
cmd.kLockTime      = 10 --锁定时间
cmd.kMaxCatchFishCount = 1 --最大捕鱼计数
--鱼类型
cmd.FishKind = 
{
    FISH_KIND_1 = 0,
    FISH_KIND_2 = 1,
    FISH_KIND_3 = 2,
    FISH_KIND_4 = 3,
    FISH_KIND_5 = 4,
    FISH_KIND_6 = 5,
    FISH_KIND_7 = 6,

    FISH_KIND_8 = 7,
    FISH_KIND_9 = 8,
    FISH_KIND_10 = 9,
    FISH_KIND_11 = 10,
    FISH_KIND_12 = 11,
    FISH_KIND_13 = 12,
    FISH_KIND_14 = 13,

    FISH_KIND_15 = 14,
    FISH_KIND_16 = 15,--小银沙
    FISH_KIND_17 = 16,--小金沙
    FISH_KIND_18 = 17,-- 鲸鱼
    FISH_KIND_19 = 18, -- 龙
    FISH_KIND_20 = 19, -- 企鹅
    FISH_KIND_21 = 20, -- 李逵
    
    FISH_KIND_22 = 21, -- 定屏炸弹
    FISH_KIND_23 = 22, -- 局部炸弹
    FISH_KIND_24 = 23, -- 超级炸弹

    FISH_KIND_25 = 24, -- 大三元1
    FISH_KIND_26 = 25, -- 大三元2
    FISH_KIND_27 = 26, -- 大三元3
    
    FISH_KIND_28 = 27, -- 大四喜1
    FISH_KIND_29 = 28, -- 大四喜2
    FISH_KIND_30 = 29, -- 大四喜3

    FISH_KIND_31 = 30, -- 鱼王1
    -- FISH_KIND_32 = 31, -- 鱼王2
    -- FISH_KIND_33 = 32, -- 鱼王3
    -- FISH_KIND_34 = 33, -- 鱼王4
    -- FISH_KIND_35 = 34, -- 鱼王5
    -- FISH_KIND_36 = 35, -- 鱼王6
    -- FISH_KIND_37 = 36, -- 鱼王7
    -- FISH_KIND_38 = 37, -- 鱼王8
    -- FISH_KIND_39 = 38, -- 鱼王9
    -- FISH_KIND_40 = 39, -- 鱼王10

    FISH_KIND_COUNT = 40
}

--移植消息
cmd.Role_Net_Object=
	{
        {k="chair_id_",         t="word"},
        {k="catch_gold_",       t="score"},
        {k="cannon_type_",      t="word"},
        {k="cannon_mulriple_",  t="int"},
		--< 椅子id
		--< 捕获金币
		--< 捕获类型
		--< 大炮倍数
	};
	--子弹配置
    cmd.Bullet_Config=
    {
        {k="speed",                     t="float"},
        {k="bounding_radius",           t="float"},
        {k="fire_interval",             t="float"},
		--速度
		--半径
		--开炮间隔
	};

    cmd.CMD_S_StatusFree=
	{
        {k="scene_",                        t="byte"},
        {k="ex_ratio_userscore_",           t="int"},
        {k="ex_ratio_birdscore_",           t="int"},
        {k="exchange_count_",               t="int"},
        {k="cannon_mulriple_",              t="int" ,       l = {cmd.FishKind.FISH_KIND_COUNT}},
        {k="mulriple_count_",               t="int"},
        {k="scene_special_time_",           t="word"},

        {k="role_objects_",                 t="table",      d = cmd.Role_Net_Object, l = {6} },
        {k="bullet_config_",                t="table",      d = cmd.Bullet_Config,  l = {6} },
        {k="energy_value_",                 t="word",       l = {30} },
        {k="energy_countdown_",             t="word"},
        {k="wServerID",                     t="int"},
		--场景
		--兑换比例  金币 = 鱼币 * ex_ratio_userscore_ / ex_ratio_birdscore_
		--int ex_ratio_birdscore_;
		--单位兑换
		--大炮倍数
		--倍数
		--特殊鱼阵时间（未使用 禁止开炮）
		--玩家信息
		--子弹配置
		--每条鱼的能量值
		--能量炮发射倒计时
		--房间ID


    };
    

--场景信息
cmd.GameStatus = 
{
    {k="sceneID",t="int"}, --场景id
    {k="game_version",t="dword"}, --游戏版本
   -- {k="ffss",t="bu4"}, --游戏版本
    {k="fish_score"  ,t="score", l = {cmd.GAME_PLAYER}}, --鱼分数
    {k="bullet_count",t="score", l = {cmd.GAME_PLAYER}},     --玩家渔币
    {k="exchange_fish_score",t="score", l = {cmd.GAME_PLAYER}}, --交换鱼分数
    {k="bullet_score",t="score", l = {cmd.GAME_PLAYER}}, --子弹分数
    {k="bullet_price",t="table",d = cmd.BulletPrice, l = {cmd.BUY_BULLET_TYPE_MAX}}, --各种子弹的价格和数量

}

--游戏配置
cmd.GameConfig = 
{
    {k="exchange_ratio_userscore",t="int"}, --兑换比例(金币值)
    {k="exchange_ratio_fishscore",t="int"}, --兑换比例(鱼币值)
    {k="exchange_count",t="int"}, --每次兑换数量
    {k="min_bullet_multiple",t="int"}, --最小炮火
    {k="max_bullet_multiple",t="int"}, --最大炮火
    {k="bomb_range_width",t="int"}, --炸弹打中范围宽
    {k="bomb_range_height",t="int"}, --炸弹打中范围高
    {k="fish_multiple",t="int", l = {cmd.FishKind.FISH_KIND_COUNT} }, --各种鱼倍数分
    {k="fish_speed",t="int", l = {cmd.FishKind.FISH_KIND_COUNT} }, --鱼速度
    {k="fish_bounding_box_width",t="int", l = {cmd.FishKind.FISH_KIND_COUNT} }, --鱼边界框宽度
    
    {k="fish_bounding_box_height",t="int", l = {cmd.FishKind.FISH_KIND_COUNT}}, --鱼边界框高度
    {k="fish_hit_radius",t="int", l = {cmd.FishKind.FISH_KIND_COUNT}}, --能打中鱼的半径
    {k="fish18_max_multiple",t="int"}, --鱼18最大倍数分
    {k="fish19_max_multiple",t="int"}, --鱼19最大倍数分
    {k="fishLK_max_multiple",t="int"}, --李逵最大倍数分
    {k="bullet_speed",t="int", l = {cmd.BulletKind.BULLET_KIND_COUNT}}, --子弹速度
    {k="net_radius",t="int",   l = {cmd.BulletKind.BULLET_KIND_COUNT}}, --子弹半径
    {k="bIsSuper",t="bool"}, --是否是超端
    {k="show_help_tip",t="bool"}, --是否显示帮助
    {k="show_task_tip",t="bool"}, --是否显示任务

    {k="bb",t="bu1"}, --部位
    {k="FireInterval",t="int"}, --发炮间隔
    -- {k="gamestatus",t="table",d = cmd.GameStatus, l = {cmd.GAMECONFIGNUM}}, --游戏设置
    {k="gamestatus",t="table",d = cmd.GameStatus}, --游戏设置
}

--鱼创建
cmd.FishTrace =
{
--   {k="init_pos",        t="table",    d=cmd.FPoint,   l={cmd.FPOINTNUM}},       --初始鱼顶点
--   {k="init_count",      t="int"},                             --初始绘画数量
--   {k="fish_kind",       t="int"},                             --鱼种类
--   {k="fish_id",         t="int"},                             --鱼ID
--   {k="trace_type",      t="int"}                              --鱼轨迹类型
    {k = "id_" ,        t ="int"},
    {k = "type_" ,      t ="byte"},
    {k = "item_" ,      t ="byte"},
    {k = "path_id_" ,   t ="word"},
    {k = "path_type_" , t ="byte"},
    {k = "path_delay_" ,t ="float"},
    {k = "path_offset_" ,t ="table" , d = cmd.FPoint},
    {k = "elapsed_" ,   t ="float"},
    {k = "speed_" ,     t ="float"},
    {k = "time_" ,      t ="int"},
    {k = "gold_" ,      t ="int"},

    

}

cmd.CMD_C_TimeCheck =
{
    {k = "chair_id_" ,           t ="word"},    --椅子od
    {k = "time_" ,                  t ="int"},     --链接时间（用户）
    {k = "is_game_status_" ,        t ="bool"},     --游戏状态
};
    
--时间校准
cmd.CMD_S_TimeCheck =
{
    {k = "chair_id_" ,           t ="word"},    --椅子od
    {k = "client_time_" ,        t ="int"},     --链接时间（用户）
    {k = "server_time_" ,        t ="int"},     --服务器时间
}

--用户上分
cmd.ExchangeFishScore =
{
    {k="count_",              t="score"},  
    {k="chair_id_",              t="word"},  
    -- {k="chair_id",              t="word"},                                  --待定 --玩家ID
    -- {k="bb",                    t="word"},                                  --补位
    -- {k="bbbb",                  t="int"},                                   --补位
    -- {k="swap_fish_score",       t="score"},                                 --交换鱼分数
    -- {k="exchange_fish_score",   t="score"},                                 --改变鱼分类
    -- {k="bullet_count",          t="score",      l={cmd.GAME_PLAYER}},       --玩家渔币
    -- {k="UserScore",             t="score"},                                 --玩家分数(去除渔币后的分数)
}

--交换鱼分数(下分)
cmd.FishScoreToBullet =
{
    {k="chair_id",              t="short"},                                 --待定 --玩家ID
    -- {k="bb",                    t="word"},                                  --补位
    -- {k="bbbb",                  t="int"},                                   --补位
    -- {k="User_Bullet_Count",     t="score"},                                 --子弹数
    -- {k="fish_score",            t="score"},                                 --获得鱼分
    -- {k="bullet_count",          t="score",      l={cmd.GAME_PLAYER}},       --玩家渔币
    {k="UserScore",             t="score"},                                 --玩家分数(去除渔币后的分数)
}

--用户开火
cmd.UserFire =
{
    {k="id_",                   t="int"},                               --子弹ID
    {k="scened_",               t="byte"},                              --场景 --by new 
    {k="rotation_",             t="float"},                             --角度
    {k="position_",             t="table" , d = cmd.FPoint},            --位置 --by new 
    {k="cannon_type_",          t="word"},                              --子弹种类
    {k="chair_id_",             t="word"},                              --玩家ID

    {k="time_",                 t="int"},                               --by new 
    {k="speed_",                t="float"},                             --by new 
    {k="bullet_mulriple",       t="int"},                               --子弹倍数
    {k="lock_bird_id_",         t="int"},                               --锁鱼ID


    --待定{k="android_chairid",       t="word"},                              --机器人信息
    
    -- {k="bullet_kind",           t="int"},                               --子弹种类
    -- {k="bullet_id",             t="int"},                               --子弹ID
    -- {k="chair_id",              t="word"},                              --玩家ID
    -- {k="android_chairid",       t="word"},                              --机器人信息
    -- {k="angle",                 t="float"},                             --角度
    -- {k="bullet_mulriple",       t="int"},                               --子弹倍数
    -- {k="lock_fishid",           t="int"},                               --锁鱼ID
    -- {k="fish_score",            t="score"},                             --鱼分数
    -- {k="iRand",                 t="int"},                               --随机值用来确定是否切换锁定鱼
    -- {k="iClientBtlletID",       t="int"},                               --客户端ID
    -- {k="bullet_count",          t="score",      l={cmd.GAME_PLAYER}},   --玩家渔币
    -- {k="UserScore",             t="score"},                             --玩家分数(去除渔币后的分数)
}


cmd.CMD_S_Special_Catch_Bird=
{
    {k="chair_id_",             t="word"}, 
    {k="cannon_type_",          t="word"}, 
    {k="catch_gold_",           t="int"}, 
    {k="bird_id_",              t="int"}, 
    {k="award_type_",           t="word"}, 
    {k="award_count_",          t="word"}, 
    {k="medal_",                t="int"}, 
    {k="link_bird_id_",         t="int"}, 
    {k="thread_id",             t="int"}, 

};
    
cmd.Catch_Bird=
{
    {k="catch_gold_",           t="int"}, --抓住金币
    {k="bird_id_",              t="int"},    --抓住鱼id
    {k="award_type_",           t="word"},--奖励类型
    {k="award_count_",          t="word"},--奖励数量
    {k="medal_",                t="int"},--奖章
    {k="link_bird_id_",         t="int"},--链接的鱼id

};

--捕到鱼
cmd.CatchFish =
{
    {k="count_",                t="byte"},  -- //对齐
    {k="chair_id",              t="byte"},  --
    {k="cannon_type_",          t="word"},  -- 大炮类型
    {k="catch_bird_",            t="table",      d = cmd.Catch_Bird, l = {2} },
    {k="bullet_id",             t="int"},   -- 子弹id

}

--闪电鱼
cmd.CMD_S_Catch_Bird_Chain=
{
    {k="count_",                t="byte"},
    {k="chair_id_",             t="word"},
    {k="cannon_type_",          t="word"},
    {k="catch_bird_",           t="table",      d = cmd.Catch_Bird, l = {2} },
    {k="bullet_id_",            t="int"},

};

--发射子弹超时
cmd.BulletIonTimeout =
{
    {k="chair_id",              t="word"},                              --玩家座位
    {k="bb",                    t="word"},                              --补位
}

--捕获扫描鱼结果
cmd.CatchSweepFishResult =
{
    {k="chair_id",              t="word"},                              --玩家座位
    {k="bb",                    t="word"},                              --补位
    {k="fish_id",               t="int"},                               --鱼ID
    {k="fish_score",            t="score"},                             --鱼分数
    {k="catch_fish_count",      t="int"},                               --捕鱼数量
    {k="bbbb",                  t="int"},                               --补位
    {k="catch_fish_id",         t="int",        l={cmd.MAX_FISH_COUNT}},--捕到鱼的ID
    {k="bullet_count",          t="score",      l={cmd.GAME_PLAYER}},   --玩家渔币
    {k="UserScore",             t="score"},                             --玩家分数(去除渔币后的分数)
}

--李逵倍数下发
cmd.HitFishLK =
{
    {k="chair_id",              t="word"},          --玩家座位
    {k="bb",                    t="word"},          --补位
    {k="fish_id",               t="int"},           --鱼ID
    {k="fish_mulriple",         t="int"},           --鱼倍数
}



--特殊鱼镇1
cmd.CMD_S_Send_Bird_Linear = --size = 42
	{
        {k = "id_" ,        t ="int"},      --< id
        {k = "type_" ,      t ="byte"},     --< 类型
        {k = "item_" ,      t ="byte"},     --< 特效

        {k = "path_delay_" ,   t ="float"},--< 路径延迟
        {k = "elapsed_" ,   t ="float"},    --< 逝去的时间
        {k = "speed_" ,     t ="float"},    --< 速度

        {k = "start_" ,     t ="table" , d = cmd.FPoint},-- 开始位置
        {k = "end_" ,       t ="table" , d = cmd.FPoint},--< 结束位置

        {k = "time_" ,      t ="int"},      --< 时间
        {k = "gold_" ,      t ="int"},      --< 金币

	};
--特殊鱼镇2
cmd.CMD_S_Send_Bird_Round = --size = 54
	{
        {k = "id_" ,        t ="int"},              --< id
        {k = "type_" ,      t ="byte"},             --< 鱼类型
		{k = "item_" ,      t ="byte"},             --< 鱼特效
        {k = "path_delay_" ,   t ="float"},         --< 路径延迟
        {k = "elapsed_" ,   t ="float"},            --< 时间延迟
        {k = "speed_" ,     t ="float"},            --< 速度

        {k = "center_" ,     t ="table" , d = cmd.FPoint},--中心店
        
        {k = "radius_" ,   t ="float"},  --半径
        {k = "rotate_duration_" ,   t ="float"},    --旋转时间
        {k = "start_angle_" ,   t ="float"},        -- 开始角度
        {k = "rotate_angle_" ,   t ="float"},       --旋转角度
        {k = "move_duration_" ,   t ="float"},      --移动时间

		{k = "time_" ,      t ="int"},              --< 时间
        {k = "gold_" ,      t ="int"},              --< 金币
    };

    --特殊鱼镇3
cmd.CMD_S_Send_Bird_Pause_Linear = -- 58 
{
    {k = "id_" ,        t ="int"},              --< id
    {k = "type_" ,      t ="byte"},             --< 鱼类型
    {k = "item_" ,      t ="byte"},             --< 鱼特效

    {k = "path_delay_" ,   t ="float"},         --< 路径延迟
    {k = "elapsed_" ,   t ="float"},            --< 时间延迟
    {k = "speed_" ,     t ="float"},            --< 速度
    
    {k = "start_angle_" ,   t ="float"},        -- 开始角度

    {k = "start_" ,     t ="table" , d = cmd.FPoint},-- 开始位置
    {k = "pause_" ,       t ="table" , d = cmd.FPoint},--< 结束位置
    {k = "end_" ,       t ="table" , d = cmd.FPoint},--< 结束位置

    {k = "pause_time_" ,   t ="float"},      --移动时间

    {k = "time_" ,      t ="int"},              --< 时间
    {k = "gold_" ,      t ="int"},              --< 金币

};

--场景切换鱼潮
cmd.SwitchScene =
{
    {k="scene_",            t="byte"},                                      
    {k="special_time",            t="word"},                                     
    -- {k="scene_kind",            t="int"},                                       --场景种类
    -- {k="fish_count",            t="int"},                                       --鱼数量
    -- {k="fish_kind",             t="int" ,        l={cmd.MAX_FISH_COUNT}},        --鱼种类
    -- {k="fish_id",               t="int" ,        l={cmd.MAX_FISH_COUNT}},        --鱼ID
}

--捕鱼任务
cmd.Fish_Progress =
{
    {k="fish_type_id",          t="int"},       --鱼种类ID
    {k="task_fish_count",       t="int"},       --任务需要捕鱼数
    {k="kill_fish_count",       t="int"},       --已经捕鱼数
    {k="task_prize",            t="int"},       --任务奖励
    {k="bgetprize",             t="int"},       --是否已领取奖励
}

--玩家任务数据
cmd.GetTaskFishProgress =
{
    {k="chair_id",              t="word"},                                                              --玩家座位
    {k="task_fish_progress",    t="table",      d=cmd.Fish_Progress,    l={cmd.MAX_FISH_TASK_COUNT}},   --游戏设置
}

--领取任务(全部)
cmd.GetTaskFishPrize =
{
    {k="ret",                   t="int"},                       --0-成功
    {k="smsg",                  t="tchar",      l={260}},       --消息
    {k="chair_id",              t="word"},                      --座位号
    {k="bb",                    t="word"},                      --补位
    {k="task_prize",            t="int"},                       --奖励鱼币数
}

--领取任务(单个)
cmd.GetTaskFishTypePrize =
{
    {k="ret",                   t="int"},                       --0-成功
    {k="smsg",                  t="tchar",      l={260}},       --消息
    {k="chair_id",              t="word"},                      --座位号
    {k="fish_type",             t="word"},                      --鱼种类
    {k="task_prize",            t="int"},                       --奖励鱼币数
}
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
--------------------------客户端请求消息结构----------------------
------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------

--上分 客户端给服务器发数据
cmd.C_ExchangeFishScore =
{
    {k="count_",             t="score"}
    -- {k="buyType",               t="byte"},
    -- {k="b",                     t="byte"},      --补位
    -- {k="bb",                    t="word"},      --补位
    -- {k="bbbb",                  t="int"},       --补位
    -- {k="time",                  t="score"},
    -- {k="checkTime",             t="score"},
}

--下分
cmd.C_ExchangeFishScoreToBullets =
{
    {k="bExChange",               t="bool"},
}

--开火 客户端给服务器发数据
cmd.C_UserFire =
{
    {k="rote_",                 t="float"},     --角度
    {k="time_",                 t="int"}, 
    {k="speed_",                t="float"}, 
    {k="bullet_mulriple_",      t="int"},       --子弹倍数
    {k="lock_bird_id_",         t="int"},       --锁鱼ID
    {k="bullet_type",           t="word"},       --子弹种类
    

    -- {k="bullet_kind",           t="int"},       --子弹种类
    -- {k="angle",                 t="float"},     --角度
    -- {k="bullet_mulriple",       t="int"},       --子弹倍数
    -- {k="lock_fishid",           t="int"},       --锁鱼ID
    -- {k="iClientBtlletID",       t="int"},       --客户端子弹ID
}
--击中李逵
cmd.C_HitFishLK =
{
    {k="chair_id",               t="word"},
    {k="bb",                     t="word"},
    {k="fish_id",                t="int"},
    {k="bullet_kind",            t="int"},       --子弹种类
    {k="bullet_mulriple",        t="int"},       --子弹倍数
}
--捕鱼(非扫描) 客户端给服务器发数据
cmd.C_CatchFish =
{
    {k="chair_id",              t="word"},       --玩家ID
    {k="bu",                    t="word"},       --玩家ID
    {k="fish_id",               t="int"},     --鱼ID
    {k="bullet_kind",           t="int"},       --子弹种类
    {k="bullet_id",             t="int"},       --子弹ID
    {k="bullet_client_id",      t="int"},       --客户端子弹ID
    {k="bullet_mulriple",       t="int"},       --客户端子弹ID
}
--捕鱼 扫描鱼
cmd.C_CatchSweepFish =
{
    {k="chair_id",              t="word"},       --玩家ID
    {k="bu",                    t="word"},       --补位
    {k="bullet_id",             t="int"},       --子弹ID
    {k="bullet_client_id",      t="int"},       --客户端子弹ID
    {k="bullet_kind",           t="int"},       --子弹种类
    {k="bullet_mulriple",       t="int"},       --客户端子弹ID
    {k="fish_id",               t="int"},     --鱼ID
    {k="catch_fish_count",      t="int"},     --捕鱼数量
    {k="catch_fish_id",         t="int",        l={cmd.MAX_FISH_COUNT}},--捕到鱼的ID
}

--鱼特效
cmd.CMD_S_Bird_Effect =
	{
        {k = "effect_" ,      t ="byte"}, -- 1:金币x2 2:Lucky概率加成
        {k = "bird_id_" ,      t ="byte"}, --非0打中的鱼id, 0:特效结束

	};
----------------------------------------------------------new add-------------------------------------
----print("********************************************************load cmd");
return cmd