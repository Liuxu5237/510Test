 
local LoadScene = class("LoadScene", cc.load("mvc").ViewBase)
local system = import(".system")
--需要加载的界面
LoadScene.RESOURCE_FILENAME = "LoadScene.csb"
LoadScene._self=nil;

function LoadScene:onCreate()
	LoadScene._self = self;
	system:showTextWin(LoadScene._self);
	system:SetVisible(LoadScene._self,false);

	LoadScene._self:runAction(cc.Sequence:create( 
				cc.DelayTime:create(0.1),cc.CallFunc:create(
					function()
						 LoadScene:load();
					end 
				))); 
end  
function LoadScene:load()
	local view =LoadScene._self:getApp():createView("MainScene") 
	local scene = display.newScene("Loading")
	scene:addChild(view)  
	cc.Director:getInstance():replaceScene(scene)
end
 
return LoadScene
