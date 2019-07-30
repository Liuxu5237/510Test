local cmd = cmd or {}

--[[
******
* 结构体描述
* {k = "key", t = "type", s = len, l = {}}
* k 表示字段名,对应C++结构体变量名
* t 表示字段类型,对应C++结构体变量类型
* s 针对string变量特有,描述长度
* l 针对数组特有,描述数组长度,以table形式,一维数组表示为{N},N表示数组长度,多维数组表示为{N,N},N表示数组长度
* d 针对table类型,即该字段为一个table类型
* ptr 针对数组,此时s必须为实际长度

** egg
* 取数据的时候,针对一维数组,假如有字段描述为 {k = "a", t = "byte", l = {3}}
* 则表示为 变量a为一个byte型数组,长度为3
* 取第一个值的方式为 a[1][1],第二个值a[1][2],依此类推

* 取数据的时候,针对二维数组,假如有字段描述为 {k = "a", t = "byte", l = {3,3}}
* 则表示为 变量a为一个byte型二维数组,长度都为3
* 则取第一个数组的第一个数据的方式为 a[1][1], 取第二个数组的第一个数据的方式为 a[2][1]
******
]]

--游戏版本
cmd.VERSION 					= "7.0.1"--appdf.VersionValue(6,7,0,1)
--游戏标识
cmd.KIND_ID						= 2068
	
--游戏人数
cmd.GAME_PLAYER					= 1

--游戏开始
cmd.SUB_S_START_GAME 			= 101
--游戏空闲
cmd.SUB_S_FREE_SCENE 			= 100
cmd.SUB_S_WIN_CAIJIN			= 99

cmd.SUB_C_SCENE_START			= 1

cmd.CS_CMD_S_StatusFree =  
{
	{k = "cbGameVersion", t = "byte"},		--kGameVersion的值
	{k = "nSpecial", t = "byte"},			--特殊状态 1:免费游戏
	{k = "sGameCoin", t = "score"},
	{k = "d_wRandTime", t = "dword"},		--随机种子
	{k = "d_wTime", t = "dword"}			--时间差值
}

--------------------------------控制信息--------------------------------------------
cmd.ITEM_MAX					= 500								--最大条数

cmd.SUB_S_MCURTENTSTOCK 		= 114								--库存信息
cmd.SUB_S_XIUGAICHENGGONG		= 115								--修改成功
cmd.SUB_C_REQUEST_S_USERROSTER	= 116 								--名单信息
cmd.SUB_C_FREE_SCENE			= 200								--重连消息

cmd.SUB_C_PERSON_CONTROL		= 9              					--个人控制
cmd.SUB_C_SAVE_PRO 				= 8
cmd.SUB_C_PRO_INQUIRY			= 7									--删除
cmd.SUB_C_STOCK_OPERATE			= 6									--刷新


cmd.CMD_S_CurrentStock = 
{
	{k = "szcurrentstock", t = "score"},							--当前库存
	{k = "szprobability1", t = "word"},								--库存概率
	{k = "szupperlimitofstock1", t = "score"},						--库存上限1
	{k = "szprobability2", t = "word"},								--库存概率
	{k = "szupperlimitofstock2", t = "score"},						--库存上限2
	{k = "szprobability3", t = "word"},								--库存上限概率2
}

cmd.CMD_C_KongZhi = 
{
	{k = "lScoreLimit", t = "score"},								--输赢数量
	{k = "dwUserGameID", t = "dword"},								--用户ID
	{k = "probability", t = "word"}									--概率
}

cmd.CMD_S_KongZhi = 
{
	{k = "Counent", t = "byte"},									--信息数量
	{k = "Kongzhi", t = "table", d = cmd.CMD_C_KongZhi, l = {cmd.ITEM_MAX}},
}

return cmd