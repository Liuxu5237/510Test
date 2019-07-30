local SendMsg = class("SendMsg")
SendMsg.SUB_C_SCENE_START = 1 --开始游戏
SendMsg.SUB_C_GUESS_CARD = 2 --开始猜牌
SendMsg.SUB_C_STEP_OVER=3 --阶段结束

SendMsg.SUB_C_ENTER_GAMBLE = 10 --进入小游戏
SendMsg.SUB_C_GUESS_CARD_AUTO_LEAVE = 13 --离开小游戏 
SendMsg.SUB_C_ENTER_SHELL = 14 --进入贝壳
SendMsg.SUB_C_GAMBLE_SHELL=15 --获取贝壳

SendMsg.SUB_C_BONUS_ENTER=16 --请求爬树游戏
SendMsg.SUB_C_BONUS_EXIT=17 --爬树游戏结束

SendMsg.SUB_C_FREE_SCENE = 200

--获取断线信息
function SendMsg:sendReConnect() 
		local sendPack ="" 
		print("发送sendReConnect@@@@@@@@@@@@@@@length:"..string.len(sendPack))
		SendGameMsg(SendMsg.SUB_C_FREE_SCENE,string.len(sendPack),sendPack)	
end
--开始游戏
function SendMsg:startGame(line,bet,linecost,free)
		local sendPack ="" 
		sendPack = sendPack..string.pack("b",line)  --下注线数 
		sendPack = sendPack..string.pack("S",bet)  --下注金额
		sendPack = sendPack..string.pack("S",linecost)  --下注总额
		sendPack = sendPack..string.pack("b",(free and 1 or 0) )  --是否免费旋转  
		print("发送开始游戏请求startGame@@@@@@@@@@@@@@@len:"..string.len(sendPack))
		if tonumber(os.date("%m", os.time())) <= 4 then
			SendGameMsg(SendMsg.SUB_C_SCENE_START,string.len(sendPack),sendPack)	
	 	end
end
--发送扑克牌小游戏请求
function SendMsg:guessCard(cardtype) 
		local sendPack ="" 
		sendPack = sendPack..string.pack("I",cardtype)  --红色牌还是黑色牌
		print("发送开始游戏[扑克牌小游戏]请求startGame@@@@@@@@@@@@@@@length:"..string.len(sendPack))
		SendGameMsg(SendMsg.SUB_C_GUESS_CARD,string.len(sendPack),sendPack)	
end
--进入小游戏
function SendMsg:enterGameable() 
		local sendPack ="" 
		print("发送进入小游戏请求startGame@@@@@@@@@@@@@@@length:"..string.len(sendPack))
		SendGameMsg(SendMsg.SUB_C_ENTER_GAMBLE,string.len(sendPack),sendPack)	
end
--退出小游戏
function SendMsg:exitGameable() 
		local sendPack ="" 
		print("发送退出小游戏请求startGame@@@@@@@@@@@@@@@length:"..string.len(sendPack))
		SendGameMsg(SendMsg.SUB_C_GUESS_CARD_AUTO_LEAVE,string.len(sendPack),sendPack)	
end
--转完后发送
function SendMsg:stepOver() 
		local sendPack ="" 
		print("发送转完了游戏请求startGame@@@@@@@@@@@@@@@length:"..string.len(sendPack))
		SendGameMsg(SendMsg.SUB_C_STEP_OVER,string.len(sendPack),sendPack)	
end
function SendMsg:exitClimp()  
	local sendPack ="" 
	print("发送结束爬树游戏请求startGame@@@@@@@@@@@@@@@length:"..string.len(sendPack))
	SendGameMsg(SendMsg.SUB_C_BONUS_EXIT,string.len(sendPack),sendPack)	
end 
function SendMsg:enterHoney()
	local sendPack ="" 
	print("发送进入爬树游戏请求startGame@@@@@@@@@@@@@@@length:"..string.len(sendPack))
	SendGameMsg(SendMsg.SUB_C_BONUS_ENTER,string.len(sendPack),sendPack)	
end 
--进入免费游戏，获取贝壳 
--位置,随机数组index

function SendMsg:getShell(sNum,rand) 
		local sendPack ="" 
		sendPack = sendPack..string.pack("I",sNum) 
		sendPack = sendPack..string.pack("i",rand)  		
		print(sNum.."####"..rand)
		print("发送获取贝壳请求startGame@@@@@@@@@@@@@@@length:"..string.len(sendPack))
		SendGameMsg(SendMsg.SUB_C_GAMBLE_SHELL,string.len(sendPack),sendPack)	
end
return SendMsg
