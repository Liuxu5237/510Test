module("DSTableView", package.seeall)

local DSTableView = class("DSTableView")
DSTableView.__index = DSTableView

function DSTableView.extend(size)
	local target = cc.TableView:create(size)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, DSTableView)
    return target
end

--有滚动时的响应函数
function DSTableView:scrollViewDidScroll(func)
	if (self ~= nil) then
		self:registerScriptHandler(func, cc.SCROLLVIEW_SCRIPT_SCROLL)
	end
end

--有缩放时的响应函数
function DSTableView:scrollViewDidZoom(func)
	if (self ~= nil) then
		self:registerScriptHandler(func, cc.SCROLLVIEW_SCRIPT_ZOOM)
	end
end

--点击cell响应的函数
function DSTableView:tableCellTouched(func)
	if (self ~= nil) then
		self:registerScriptHandler(func, cc.TABLECELL_TOUCHED)
	end
end

--设置每个cell的大小（height,width）
function DSTableView:cellSizeForTable(func)
	if (self ~= nil) then
		self:registerScriptHandler(func, cc.TABLECELL_SIZE_FOR_INDEX)
	end
end

--填充cell的内容
function DSTableView:tableCellAtIndex(func)
	if (self ~= nil) then
		self:registerScriptHandler(func, cc.TABLECELL_SIZE_AT_INDEX)
	end
end

--设置cell的个数
function DSTableView:numberOfCellsInTableView(func)
	if (self ~= nil) then
		self:registerScriptHandler(func, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	end
end

--设置高亮状态
function DSTableView:tableCellHighlight(func)
	if (self ~= nil) then
		self:registerScriptHandler(func, cc.TABLECELL_HIGH_LIGHT)
	end
end

--取消高亮状态
function DSTableView:tableCellUnhighlight(func)
	if (self ~= nil) then
		self:registerScriptHandler(func, cc.TABLECELL_UNHIGH_LIGHT)
	end
end

--循环使用cell
function DSTableView:tableCellWillRecycle(func)
	if (self ~= nil) then
		self:registerScriptHandler(func, cc.TABLECELL_WILL_RECYCLE)
	end
end

--设置横向拖拉
function DSTableView:SetDirectionOfHorizontal()
	if (self ~= nil) then
		self:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	end
end

--设置纵向拖拉
function DSTableView:SetDirectionOfVeritical()
	if (self ~= nil) then
		self:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	end
end

--设置360度拖拉
function DSTableView:SetDirectionOfAll()
	if (self ~= nil) then
		self:setDirection(cc.SCROLLVIEW_DIRECTION_BOTH)
	end
end

--设置cell填充的方向：从头到尾
function DSTableView:SetOrderFromTopToDown()
	if (self ~= nil) then
		self:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	end
end

--设置cell填充的方向：从下到上
function DSTableView:SetOrderFromBottomToUp()
	if (self ~= nil) then
		self:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
	end
end


function create(size)
	local TableView = DSTableView.extend(size)
    if (TableView == nil) then
    	TableView = cc.TableView:create(size)
    	ds.log("TableView is null")
    end
    return TableView
end























