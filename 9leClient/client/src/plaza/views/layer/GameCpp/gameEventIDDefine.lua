module("RoomEventIDDefine", package.seeall)
ds = ds or {}
ds.GameEventIDDefine ={
	
	--关闭游戏场景
	GAME_EVENT_ID_CLOSE_GAME_CLIENT = 1,
	
	--游戏从后台切入到前台
	GAME_EVENT_ID_ENTER_FOREGROUND = 2,
	
	--进入重连状态
	GAME_EVENT_ID_DETECT_NET_DOWN = 3,
	
	--游戏关闭
	GAME_EVENT_ID_GAME_CLOSE = 4,
	
	--离开游戏确认
	GAME_EVENT_ID_CLOSE_GAME_CONFIRM = 5,
	
	--游戏金币不够
	GAME_EVENT_ID_GOLD_NOT_ENOUGH = 6,
	
	--重连发生错误
	GAME_EVENT_ID_RECONNECT_NET_ERROR = 7,
	
	--重连未知错误
	GAME_EVENT_ID_RECONNECT_UNKNOWN = 8,
	
	--重新检测到网络
	GAME_EVENT_ID_DETECT_NET_AGAIN = 9,
	
	--检测网络超时
	GAME_EVENT_ID_DETECT_NET_TIME_OUT = 10,
	
	--显示充值界面
	GAME_EVENT_ID_SHOW_PAY = 11,
	
	--服务器通知关闭客户端
	GAME_EVENT_ID_SERVER_NOTIFY_CLOSE_CLIENT = 12,
	
	--发送系统消息
	GAME_EVENT_ID_SYSTEM_MSG = 13,	
	
	--系统消息
	GAME_EVENT_ID_SUB_SYSTEM_MSG = 14,
	--微信头像加载
	GAME_EVENT_ID_DOWN_HTTPIMG = 15,
	--都市点不足，领取低保弹框
	GAME_EVENT_ID_JUDGE_LOW_INSURE = 16,
}
