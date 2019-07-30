--
-- Author: zhong
-- Date: 2016-11-02 17:46:07
--
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local Define = {}
local TAG_START             = 100
local enumTable = 
{
    "BT_EXIT",
    "BT_RULE",
    "BT_RECORD",
    "BT_SENDRED",
    "BT_MENU",
    "BT_ADMIN",
}
Define.TAG_ENUM = ExternalFun.declarEnumWithTable(TAG_START, enumTable)

local zorders = 
{
    "CHAT_ZORDER",
    "RESULT_ZORDER",
    "EFFECT_ZORDER",
    "SET_ZORDER",
    "MENU_ZORDER"
}
Define.TAG_ZORDER = ExternalFun.declarEnumWithTable(1, zorders)


return Define