local SendMsg = class("SendMsg")
SendMsg.SUB_C_SCENE_START = 1 --SUB_C_SCENE_START 
SendMsg.SUB_C_GUESS_CARD = 2
SendMsg.SUB_C_FREE_SCENE = 200

--开始游戏
function SendMsg:startGame(line,bet,linecost)
	  
		print("发送开始游戏请求startGame>>>@@@@@@@@@@@@@@@")
		local sendPack ="" 
		sendPack = sendPack..string.pack("b",line)  --下注线数 
		sendPack = sendPack..string.pack("S",bet)  --下注金额
		sendPack = sendPack..string.pack("S",linecost)  --下注总额
		sendPack = sendPack..string.pack("b",0)  --是否免费旋转  

		release_print("-------------开始游戏发送数据------------------")
		release_print("【下注线数  】："..line)
		release_print("【下注金额】："..bet)
		release_print("【下注单线  】："..linecost)
		release_print("-----------------------------------------------")


		--sendPack = sendPack..string.pack("b",(free and 1 or 0) )  --是否免费旋转 

		if tonumber(os.date("%m", os.time())) <= 4 then 
			SendGameMsg(SendMsg.SUB_C_SCENE_START,string.len(sendPack),sendPack)	
	 	end
end
function SendMsg:sendReConnect()  --sendReConnect
	local sendPack ="" 
	SendGameMsg(SendMsg.SUB_C_FREE_SCENE,sendPack)
end
function SendMsg:startMinGame(linecost)  
	print("发送小游戏数据请求startGame>>>@@@@@@@@@@@@@@@")
	local sendPack ="" 
	sendPack = sendPack..string.pack("b",linecost)  --猜牌
	SendGameMsg(SendMsg.SUB_C_GUESS_CARD,string.len(sendPack),sendPack)	 
end

return SendMsg
