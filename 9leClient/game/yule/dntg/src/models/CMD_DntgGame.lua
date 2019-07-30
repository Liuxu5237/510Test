--
-- Author: Tang
-- Date: 2016-08-08 14:27:52
--

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd  = {}

--游戏版本
cmd.VERSION  			= "7.0.1"--appdf.VersionValue(6,7,0,1)
--游戏标识
cmd.KIND_ID				= 601
--游戏人数
cmd.GAME_PLAYER   		= 6
--房间名长度
cmd.SERVER_LEN			= 32

cmd.INT_MAX = 2147483647


print("********************************************************load cmd");
return cmd