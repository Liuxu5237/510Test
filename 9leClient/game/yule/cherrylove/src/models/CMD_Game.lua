local cmd = cmd or {}


cmd.SUB_S_START_GAME =101
cmd.SUB_GR_USER_SCORE =101
cmd.SUB_S_GUESS_RESULT=109
cmd.SUB_S_GAMBLE_LEAVE=111
cmd.SUB_S_FREE_SCENE=200
cmd.SUB_S_WIN_CAIJIN=99

cmd.SUB_C_FREE_SCENE = 200
cmd.SUB_C_SCENE_START = 1 --SUB_C_SCENE_START 
cmd.SUB_C_GUESS_CARD = 2   --开始猜牌


cmd.SUB_GR_USER_SCORE =101

cmd.SUB_S_GAMBLE_LEAVE=111 
cmd.SUB_S_BONUS_ENTER=106 

cmd.SUB_S_SHELL_RESULT = 113
cmd.SUB_S_GOD_ROLLING_RESULT =112
cmd.SUB_S_GOD_BIG_ROLLING_RESULT =113
cmd.SUB_S_GOD_BIG_WIN =114		--众神游戏全屏游戏得分


cmd.SUB_S_SCENE_BONUS=210	--Bonus场景
cmd.SUB_S_SCENE_FEVER=211	--Fever场景
--红包消息
cmd.SUB_S_RED_BOUNS 		=  11001 --有红包
cmd.SUB_S_RED_BOUNS_OPEN  =  11002 --红包金额


cmd.SUB_C_ENTER_GAMBLE = 10 --进入小游戏
cmd.SUB_C_GUESS_CARD_AUTO_LEAVE = 11 --离开小游戏
cmd.SUB_C_GOD_ROLLING =12 --众神听令
cmd.SUB_C_GOD_BIG_ROLLING =13 --全屏游戏转动
cmd.SUB_C_GOD_BIG_WIN =14 --众神游戏全屏游戏得分

cmd.SUB_C_SCENE_BONUS=210	--Bonus场景
cmd.SUB_C_SCENE_FEVER=211	--Fever场景
-- 红包消息
cmd.SUB_C_RED_BOUNS_OPEN  = 11001 -- 已经点击红包

return cmd


