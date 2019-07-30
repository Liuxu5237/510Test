local Logic = class("Logic") 
local xiaoguiNum =11 --小鬼的图片ID
local daguiNum =12 --大鬼的图片ID
--中奖线 左下角为0,0
local allline ={
	--123
	{{1,2},{2,2},{3,2},{4,2},{5,2}}, 
	{{1,3},{2,3},{3,3},{4,3},{5,3}},
	{{1,1},{2,1},{3,1},{4,1},{5,1}}, 
	--45
	{{1,3},{2,2},{3,1},{4,2},{5,3}},
	{{1,1},{2,2},{3,3},{4,2},{5,1}},
	--67
	{{1,3},{2,3},{3,2},{4,3},{5,3}},
	{{1,1},{2,1},{3,2},{4,1},{5,1}}, 
	--89
	{{1,2},{2,3},{3,3},{4,3},{5,2}},
	{{1,2},{2,1},{3,1},{4,1},{5,2}},
	--1011
	{{1,2},{2,3},{3,2},{4,3},{5,2}},
	{{1,2},{2,1},{3,2},{4,1},{5,2}},
	--1213
	{{1,3},{2,2},{3,3},{4,2},{5,3}},
	{{1,1},{2,2},{3,1},{4,2},{5,1}},
	--1415
	{{1,2},{2,2},{3,3},{4,2},{5,2}},
	{{1,2},{2,2},{3,1},{4,2},{5,2}},
	--1617
	{{1,3},{2,2},{3,2},{4,2},{5,3}},
	{{1,1},{2,2},{3,2},{4,2},{5,1}},
	--1819
	{{1,3},{2,2},{3,1},{4,1},{5,1}},
	{{1,1},{2,2},{3,3},{4,3},{5,3}},
	--2021
	{{1,3},{2,1},{3,3},{4,1},{5,3}},
	{{1,1},{2,3},{3,1},{4,3},{5,1}},
	--2223
	{{1,2},{2,3},{3,1},{4,3},{5,2}},
	{{1,2},{2,1},{3,3},{4,1},{5,2}},
	--2425
	{{1,3},{2,3},{3,2},{4,1},{5,1}},
	{{1,1},{2,1},{3,2},{4,3},{5,3}},
}
--赔率(10种牌，5出现的次数)
local ODDS={ 
	{0,0,5,20,100},  --9 
	{0,0,5,20,100},  --10
	
	{0,0,10,25,150},  --j
	{0,0,10,25,150},  --Q
	
	{0,0,15,50,200}, --k
	{0,0,15,50,200}, --a
	
	{0,0,25,100,500}, --蜜蜂
	{0,0,25,100,500}, --篮子
	
	{0,4,50,300,1000}, --松鼠
	{0,5,100,1000,5000}, --猎人
	
	{0,0,0,0,0}, --10.png 
	{0,0,0,0,0},  --11.png--任意位置
	{0,0,0,0,0},  --12.png--可变位置 
	{0,0,0,0,0}, 
}
local ODDS_scatter={ --scatter任意位置赔率
	 0,1,5,20,100,0,0,0,0,0,0,0,0,0,0
}
--判断可变的行数。比如有3列以上出现了A，就中奖了
function Logic:SteryScatter(tab,nSteryScatter) 
	local scatter = 1
	local scattePointXs={}
	for x,x_point in pairs(tab) do
		for y,y_point in pairs(x_point) do 
			if tonumber(tab[x][y])==nSteryScatter then
				scatter=scatter+1
				table.insert(scattePointXs,x)
				break				
			end
		end	
	end
	if scatter > 1 then
		scatter = scatter - 1 
	end
	if ODDS[nSteryScatter+1][scatter]>0 then
		return scattePointXs
	else 
		return nil
	end
end 
function Logic:win(tab,lineNum)
	 
	local winLines ={} --那根线
	local winLinePoints ={} --线上的具体点
	local winOdds ={} --线的赔率 
	printf("判断是否中奖")
	--1.判断小王 ，有多少个分散的
	local scatter = 1
	local scattePoints={}
	for x,x_point in pairs(tab) do
		for y,y_point in pairs(x_point) do 
			if tonumber(tab[x][y])==xiaoguiNum then
				scatter=scatter+1
				table.insert(scattePoints,{x,y})	
			end
		end	
	end
	if scatter > 1 then
		scatter = scatter - 1 
	end
	if ODDS_scatter[scatter]>0 then
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
					if tonumber(tab[point[1]][point[2]])==daguiNum then
						startValue=-1 -- 
						equlesCount=equlesCount+1 
					else
						startValue = tab[point[1]][point[2]]
					end
					table.insert(points,point)				
				else                                          --可变
					if startValue == tab[point[1]][point[2]] or tonumber(tab[point[1]][point[2]])==daguiNum then --可变 11 12 都是可变的
						table.insert(points,point)	
						equlesCount=equlesCount+1 --相同则记录
					else
						break
					end 
				end
				--printf(tab[1][2].."###"..equlesCount..":::"..startValue)
			end
			 
			--中奖
			if ODDS[startValue+1][equlesCount] >0  then
				table.insert(winLines,indexKey) 
				table.insert(winLinePoints,points)
 
				--local includeDAGUI =false
				--for index,point in pairs(points) do --获取点 
				--	if tonumber(tab[point[1]][point[2]]) == daguiNum then
				--		includeDAGUI=true
				--		break
				--	end
				--end
				--if includeDAGUI then --包含大鬼则翻倍
				--	table.insert(winOdds,ODDS[startValue+1][equlesCount]*2)
				--else
					table.insert(winOdds,ODDS[startValue+1][equlesCount])
				--end 
			end
			 
		end
	end 
	return winLines,winOdds,winLinePoints
end
	  
return Logic
