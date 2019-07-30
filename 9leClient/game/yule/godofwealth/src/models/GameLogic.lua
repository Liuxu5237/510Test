local Logic = class("Logic") 

local xiaoguiNum =8 --scatte鬼的图片ID
local HongNum = 10 --大鬼的图片ID
local daguiNum =9 --小鬼的图片ID
--中奖线 
local allline ={
	{{1,2},{2,2},{3,2},{4,2},{5,2}}, 
	{{1,3},{2,3},{3,3},{4,3},{5,3}},
	{{1,1},{2,1},{3,1},{4,1},{5,1}}, 
	{{1,3},{2,2},{3,1},{4,2},{5,3}},
	{{1,1},{2,2},{3,3},{4,2},{5,1}},
	{{1,3},{2,3},{3,2},{4,3},{5,3}},
	{{1,1},{2,1},{3,2},{4,1},{5,1}}, 
	{{1,2},{2,3},{3,3},{4,3},{5,2}},
	{{1,2},{2,1},{3,1},{4,1},{5,2}},
}
--赔率(10种牌，5出现的次数)
local ODDS={ 
	{0,0,2,5,20}, -- 铜钱
	{0,0,3,10,40}, -- 鞭炮
	{0,0,5,15,60}, --玉佩
	{0,0,7,20,100}, -- 鼓

	{0,0,10,30,160}, --美女
	{0,0,15,40,200}, --帅哥
	{0,0,20,80,400}, --蓝财神
	{0,0,50,200,1000}, --红财神
	{0,0,0,0,0},    --SCATTER
	{0,0,0,0,5000}, --蓝发财                 2 单个为2特殊处理，线的时候不处理
	{0,0,0,0,5000}, --红发财
	{0,0,0,0,0}, --11.png
	{0,0,0,0,0}  --12.png
}
local ODDS_scatter={ --scatter任意位置赔率
	 0,0,0,0,0,0,0,0,0,0,0,0,0,0
}

function Logic:win(tab,lineNum)
	
	
	local winLines ={} --那根线
	local winLinePoints ={} --线上的具体点
	local winOdds ={} --线的赔率 
	--printf("判断是否中奖")
	--0.判断刀，第10个图标为1的情况
	--[[
	local ten = 0
	local TenPoints={}
	for x,x_point in pairs(tab) do
		for y,y_point in pairs(x_point) do 
			if tonumber(tab[x][y])== 9 then
				ten = ten + 1 
				table.insert(TenPoints,{x,y})	
			end
		end	
	end
	if ten >= 1 then  --如果是多个就按单个算 n*2
		table.insert(winLines,-1) --没有线
		table.insert(winOdds, 2 * ten) --如果是多个就按单个算 n*2
		table.insert(winLinePoints,TenPoints)
	end
	]]
	--1.判断小王 ，有多少个分散的 
	local scatter = 1 --总数
	local scattePoints={}
	for x,x_point in pairs(tab) do
		for y,y_point in pairs(x_point) do 
			if tonumber(tab[x][y])==xiaoguiNum then
				scatter=scatter+1
				--print("-------scatter  " ..scatter)
				table.insert(scattePoints,{x,y})	
			end
		end	
	end
	if scatter > 1 then
		scatter = scatter - 1 
	end
	if ODDS_scatter[scatter] > 0 then
		--print("ODDS_scatter[scatter]---- "..ODDS_scatter[scatter])
		table.insert(winLines,0) --没有线
		table.insert(winOdds,ODDS_scatter[scatter])
		table.insert(winLinePoints,scattePoints)
	end
	--2.判断中奖线 
	for indexKey,line in pairs(allline) do --获取线
		if  indexKey <= lineNum then --判断几根线
			--[[从左到右###################################]]--
			local startValue=-1 --开始的值
			local equlesCount=1 --相同数字
			local points={}
			for index,point in pairs(line) do --获取点 
				
				if startValue == -1 then --开始的值 是初始值则赋值
					--print("--tonumber-->>--  "..tonumber(tab[point[1]][point[2]]))
					if tonumber(tab[point[1]][point[2]])==daguiNum or tonumber(tab[point[1]][point[2]]) ==HongNum then
						equlesCount=equlesCount+1 
					else
						startValue = tab[point[1]][point[2]]
						--print("---startValue-->>>--- "..startValue)
					end
					table.insert(points,point)
					-- for i,v in ipairs(point) do
					-- 		print(i.."  --------point-----   "..v)
					-- 	end	
							
				else                                          --可变
					--print("-------startValue----- "..startValue)
					--print("------tab[point[1]][point[2]]------ "..tab[point[1]][point[2]])
					if startValue == tab[point[1]][point[2]] or tonumber(tab[point[1]][point[2]])==daguiNum or tonumber(tab[point[1]][point[2]])==HongNum  then
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
					if tonumber(tab[point[1]][point[2]])==daguiNum or tonumber(tab[point[1]][point[2]])==HongNum then
						--print("--tonumber-->>--  "..tonumber(tab[point[1]][point[2]]))
						equlesCount2=equlesCount2+1 
					else
						--print("-----")
						startValue2 = tab[point[1]][point[2]]
					end
					table.insert(points2,point)				
				else                                          --可变
					if startValue2 == tab[point[1]][point[2]] or tonumber(tab[point[1]][point[2]])==daguiNum or  tonumber(tab[point[1]][point[2]])==HongNum then
						table.insert(points2,point)	
						equlesCount2=equlesCount2+1 --相同则记录
					else
						break
					end 
				end 
			end
		
			
		
			--两边同时中奖
			if ODDS[startValue+1][equlesCount] >0  then
				-- print("----indexKey --- >>  "..indexKey)
				-- print("----ODDS --- >>  "..ODDS[startValue+1][equlesCount])
				-- print("----points --- >>  "..#points)
				table.insert(winLines,indexKey)
				table.insert(winOdds,ODDS[startValue+1][equlesCount])
				table.insert(winLinePoints,points)
			end
			--同时中5个不能重复算
			if(#points < 5) then
				if ODDS[startValue2+1][equlesCount2] >0  then
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
