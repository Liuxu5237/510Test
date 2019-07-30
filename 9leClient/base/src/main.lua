
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("base/src/")
cc.FileUtils:getInstance():addSearchPath("base/res/")
cc.FileUtils:getInstance():addSearchPath("client/src/")
cc.FileUtils:getInstance():addSearchPath("client/res/")
cc.FileUtils:getInstance():addSearchPath("./")

require "config"
require "cocos.init"

cc.FileUtils:getInstance():addSearchPath(device.writablePath, true)
if cc.FileUtils:getInstance():isFileExist(device.writablePath .. "base/src/") then

    cc.FileUtils:getInstance():addSearchPath(device.writablePath .. "base/src/", true)
end
if cc.FileUtils:getInstance():isFileExist(device.writablePath .. "base/res/") then
    
   
    cc.FileUtils:getInstance():addSearchPath(device.writablePath .. "base/res/", true)
end

local function main()
    
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
