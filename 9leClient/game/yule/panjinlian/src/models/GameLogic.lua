local Logic = class("Logic") 

local xiaoguiNum =8 --小鬼的图片ID
local daguiNum =9 --大鬼的图片ID
--中奖线 
local allline ={
	{{1,2},{2,2},{3,2},{4,2},{5,2}}, 
	{{1,3},{2,3},{3,3},{4,3},{5,3}},
	{{1,1},{2,1},{3,1},{4,1},{5,1}}, 
	{{1,3},{2,2},{3,1},{4,2},{5,3}},
	{{1,1},{2,2},{3,3},{4,2},{5,1}},
	{{1,3},{2,3},{3,2},{4,3},{5,3}},
	{{1,1},{2,1},{3,2},{4,1},{5,1}}, 
	{{1,2},{2,1},{3,1},{4,1},{5,2}},
	{{1,2},{2,3},{3,3},{4,3},{5,2}},
}
--赔率(10种牌，5出现的次数)
local ODDS={ 
	{0,0,2,5,20}, --发髻
	{0,0,3,10,40}, --扇子
	{0,0,5,15,60}, --绣花鞋
	{0,0,7,20,100}, --酒
	{0,0,10,30,160}, --武松
	{0,0,15,40,200}, --武大郎
	{0,0,20,80,400}, --西门庆
	{0,0,50,200,1000}, --潘金莲
	{0,0,0,0,0}, --小鬼 8.png
	{0,0,0,0,3000}, --大鬼 9.png
}
local ODDS_scatter={ --scatter任意位置赔率
	 0,1,5,10,100,0,0,0,0,0,0
}

function Logic:win(tab,lineNum)
	 
	local winLines ={} --那根线
	local winLinePoints ={} --线上的具体点
	local winOdds ={} --线的赔率 

	--1.判断小王 ，有多少个分散的
	-- local scatter = 1 --总数
	-- local scattePoints={}
	-- for x,x_point in pairs(tab) do
	-- 	for y,y_point in pairs(x_point) do 
	-- 		if tonumber(tab[x][y])==xiaoguiNum then
	-- 			scatter=scatter+1
	-- 			table.insert(scattePoints,{x,y})	
	-- 		end
	-- 	end	
	-- end
	-- if scatter > 1 then
	-- 	scatter = scatter - 1 
	-- end
	-- if ODDS_scatter[scatter] > 0 then
	-- 	table.insert(winLines,0) --没有线
	-- 	table.insert(winOdds,ODDS_scatter[scatter])
	-- 	table.insert(winLinePoints,scattePoints)
	-- end
	--2.判断中奖线 
	for indexKey,line in pairs(allline) do --获取线
		if  indexKey <= lineNum then --判断几根线
			--[[从左到右###################################]]--
			local startValue=-1 --开始的值
			local equlesCount=1 --相同数字
			local is_5dagui = false
			local points={}
			for index,point in pairs(line) do --获取点 
				if startValue == -1 then --开始的值 是初始值则赋值
					if tonumber(tab[point[1]][point[2]])==daguiNum then
						is_5dagui = true
						equlesCount=equlesCount+1 
					else
						startValue = tab[point[1]][point[2]]
						is_5dagui =false
					end
					table.insert(points,point)				
				else                                          --可变
					if startValue == tab[point[1]][point[2]] or tonumber(tab[point[1]][point[2]])==daguiNum then
						table.insert(points,point)	
						equlesCount=equlesCount+1 --相同则记录
					else
						break
					end 
				end 
			end
			--[[从右到左###################################]]--
			
			local startValue2=-1 --开始的值
			local equlesCount2=1 --相同数字
			local points2={} 
			local count2=#line
			for i =1,count2 do --获取点
				local point =line[count2-(i-1)]
				if startValue2 == -1 then --开始的值 是初始值则赋值
					if tonumber(tab[point[1]][point[2]])==daguiNum then
						equlesCount2=equlesCount2+1 
					else
						startValue2 = tab[point[1]][point[2]]
					end
					table.insert(points2,point)				
				else                                          --可变
					if startValue2 == tab[point[1]][point[2]] or tonumber(tab[point[1]][point[2]])==daguiNum then
						table.insert(points2,point)	
						equlesCount2=equlesCount2+1 --相同则记录
					else
						break
					end 
				end 
			end 

			if is_5dagui then 
				startValue = 9
				equlesCount = 5
			end
			--两边同时中奖
			print("equlesCount...."..equlesCount)
			if ODDS[startValue+1][equlesCount] >0  then
				-- if startValue == 10 then
				-- 	table.insert(winLines,0) --没有线
				-- else
				-- 	table.insert(winLines,indexKey)
				-- end
				table.insert(winLines,indexKey)
				table.insert(winOdds,ODDS[startValue+1][equlesCount])
				table.insert(winLinePoints,points)
			end
			--同时中5个不能重复算
			if(#points < 5) then
				if ODDS[startValue2+1][equlesCount2] >0  then
					-- if startValue2 == 10 then
					-- 	table.insert(winLines,0) --没有线
					-- else
					-- 	table.insert(winLines,indexKey)
					-- end
					table.insert(winLines,indexKey)
					table.insert(winOdds,ODDS[startValue2+1][equlesCount2])
					table.insert(winLinePoints,points2)
				end 
			end
		end
	end 
	return winLines,winOdds,winLinePoints
end
	  
return Logic
