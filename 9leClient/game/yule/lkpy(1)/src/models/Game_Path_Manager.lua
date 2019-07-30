--
-- Author: Liuxu
-- Date: 2018-08-25 10:26:25
-- 路径管理
local module_pre = "game.yule.lkpy.src"	

local Game_Path_Manager = class("Game_Path_Manager")
local Move_Poiots 		= appdf.req(module_pre .. ".models.Move_Point_Manager")
local Action_Move		= appdf.req(module_pre .. ".models.Action_Move_Point")

appdf.req(module_pre .. ".models.god")
appdf.req(module_pre .. ".models.god2")


msInstance = nil

function Game_Path_Manager:shared()
    
    if nil == msInstance then
		msInstance = self
		self._paths  = nil
		self._map   = {}
    end
    return msInstance
end

function Game_Path_Manager:ctor()
    print("初始化")
    return
end

function Game_Path_Manager:game_get_string_line( path , all , start_pos )
	path = ""
	local end_pos = 0
	local n = string.len( all )
	if start_pos >= 0 and start_pos < n then
		end_pos = string.find(all, "\n" , start_pos)
		if end_pos < 0 and end_pos > n then
			end_pos = n
		end

		local a =  string.sub( all, start_pos,end_pos - start_pos )
		path = path .. a
		
	end

	--self.start_pos = end_pos +1
	self._sData = string.sub( all,end_pos+1 ,-1)
	self.line = path 
	if path == "" then
		return false
	else
		return true
	end
	
end


function Game_Path_Manager:game_path_load( paths ,count , format )

	
	paths = {}
	local sData	= {}
	self.line = ""

	for i=0,count do
		local str_ = string.format(format,i)
		--获取绝对路径
		local filepath = cc.FileUtils:getInstance():fullPathForFilename(str_)
		local sData		= cc.FileUtils:getInstance():getStringFromFile(filepath)

		function split( str,reps )
			local resultStrList = {}
			string.gsub(str,'[^'..reps..']+',function ( w )
				table.insert(resultStrList,w)
			end)
			return resultStrList
		end

		--每行读取
		self.start_pos = 0;
		self._sData = sData
		--dump(sData)
		self:game_get_string_line(self.line,self._sData,self.start_pos)

		local paths2 = {}

		while self:game_get_string_line(self.line,self._sData,self.start_pos) do
			local x,y,staff , angle 
			--dump(self.line)
			--dump(self.start_pos)
			--print(type(self.line))
			local indexfirst  = 1
			local indexend = string.find(self.line,")")
			if indexend == nil then
				dump(self.line)
				dump(self._sData)
			end
			local str = string.sub(self.line,indexfirst+1,indexend-1)
			--print("" .. str)
			local tab_str = split(str,",")
			x = tab_str[1]
			y = tab_str[2]
			angle = tab_str[3]
			staff = tab_str[4]
			
			local move_points  = Move_Poiots:create(x,y,angle)
			--dump(move_points)
			table.insert( paths2, move_points)
		end
		--dump(paths)
		table.insert( paths, paths2)
	end

	self._paths = paths
	
    return true;
end

function Game_Path_Manager:initialise_paths( )
	local directory = "resources_path.plist"

	local fullpath =  cc.FileUtils:getInstance():fullPathForFilename(directory)
	
	local arr4_	   = cc.FileUtils:getInstance():getValueVectorFromFile(fullpath)
	dump(arr4_)

	for i=1,#arr4_ do
		if arr4_[i] ~= nil then
			local type = arr4_[i]["path_type"]
			local num  = arr4_[i]["path_num"]
			local path = arr4_[i]["path"]
			--if self._map[type] == nil then
				local save_paths = {}
				local save_paths2 
				--self:game_path_load(save_paths,num,path)
				if i == 1 then
					save_paths2 = god["1"]
				elseif i == 2 then 
					 save_paths2 = god2["2"]
				elseif i == 3 then 
					 save_paths2 = god2["3"]
				elseif i == 4 then 
					 save_paths2 = god2["4"]
				elseif i == 5 then 
					 save_paths2 = god2["5"]	
				end
				
				--print(save_paths2)
				--local save_path3 = {}
				--save_path3[type] = save_paths2
				--dump(save_path3)
				self._map[type] = save_paths2
				--table.insert( self._map, save_path3)
			--end
		end
	end


    return true;
end


function Game_Path_Manager:get_paths( path_id , path_type )

	path_type = "" .. path_type
	local it = self._map[path_type]
	--dump(it)
	for i=1,#it do
		if i > path_id then
			return it[i]
		end
	end
end

return Game_Path_Manager