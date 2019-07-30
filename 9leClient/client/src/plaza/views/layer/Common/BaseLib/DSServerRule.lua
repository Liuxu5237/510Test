module("DSServerRule", package.seeall)
--聊天规则
local SR_FORFEND_GAME_CHAT      =  0x00000001                          --禁止公聊
local SR_FORFEND_ROOM_CHAT      =  0x00000002                          --禁止公聊
local SR_FORFEND_WISPER_CHAT    =  0x00000004                          --禁止私聊
local SR_FORFEND_WISPER_ON_GAME =  0x00000008                          --禁止私聊

--高级规则
local SR_ALLOW_DYNAMIC_JOIN      = 0x00000010                          --动态加入
local SR_ALLOW_OFFLINE_TRUSTEE   = 0x00000020                          --断线代打
local SR_ALLOW_AVERT_CHEAT_MODE  = 0x00000040                          --隐藏信息
local SR_ALLOW_QUICK_MODE        = 0x00000080                          --快速模式

--游戏规则
local SR_RECORD_GAME_SCORE      =  0x00000100                          --记录积分
local SR_RECORD_GAME_TRACK      =  0x00000200                          --记录过程
local SR_DYNAMIC_CELL_SCORE     =  0x00000400                          --动态底分
local SR_IMMEDIATE_WRITE_SCORE  =  0x00000800                          --即时写分

--房间规则
local SR_FORFEND_ROOM_ENTER     =  0x00001000                          --禁止进入
local SR_FORFEND_GAME_ENTER     =  0x00002000                          --禁止进入
local SR_FORFEND_GAME_LOOKON    =  0x00004000                          --禁止旁观

--银行规则
local SR_FORFEND_TAKE_IN_ROOM   =  0x00010000                          --禁止取款
local SR_FORFEND_TAKE_IN_GAME   =  0x00020000                          --禁止取款
local SR_FORFEND_SAVE_IN_ROOM   =  0x00040000                          --禁止存钱
local SR_FORFEND_SAVE_IN_GAME   =  0x00080000                          --禁止存款

--其他规则
local SR_FORFEND_GAME_RULE      =  0x00100000                          --禁止配置
local SR_FORFEND_LOCK_TABLE     =  0x00200000                          --禁止锁桌
local SR_ALLOW_ANDROID_ATTEND   =  0x00400000                          --允许陪玩
local SR_ALLOW_ANDROID_SIMULATE =  0x00800000                          --允许占位

--聊天规则

--禁止公聊
function IsForfendGameChat(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_GAME_CHAT) ~=0;end
--禁止公聊
function IsForfendRoomChat(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_ROOM_CHAT)~=0;end
--禁止私聊
function IsForfendWisperChat(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_WISPER_CHAT)~=0;end
--禁止私聊
function IsForfendWisperOnGame(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_WISPER_ON_GAME)~=0;end

--模式规则

--动态加入
function IsAllowDynamicJoin(dwServerRule)return bit._and(dwServerRule, SR_ALLOW_DYNAMIC_JOIN)~=0;end
--断线代打
function IsAllowOffLineTrustee(dwServerRule)return bit._and(dwServerRule, SR_ALLOW_OFFLINE_TRUSTEE)~=0;end
--隐藏信息
function IsAllowAvertCheatMode(dwServerRule)return bit._and(dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE)~=0;end
--快速模式
function IsAllowQuickMode(dwServerRule)return bit._and(dwServerRule, SR_ALLOW_QUICK_MODE) ~=0;end

--游戏规则

--记录积分
function IsRecordGameScore(dwServerRule)return bit._and(dwServerRule, SR_RECORD_GAME_SCORE) ~=0;end
--记录过程
function IsRecordGameTrack(dwServerRule)return bit._and(dwServerRule, SR_RECORD_GAME_TRACK) ~=0;end
--动态底分
function IsDynamicCellScore(dwServerRule)return bit._and(dwServerRule, SR_DYNAMIC_CELL_SCORE) ~=0;end
--即时写分
function IsImmediateWriteScore(dwServerRule)return bit._and(dwServerRule, SR_IMMEDIATE_WRITE_SCORE) ~=0;end

--房间规则

--禁止进入
function IsForfendRoomEnter(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_ROOM_ENTER) ~=0;end
--禁止进入
function IsForfendGameEnter(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_GAME_ENTER) ~=0;end
--禁止旁观
function IsForfendGameLookon(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_GAME_LOOKON) ~=0;end

--银行规则

--禁止取款
function IsForfendTakeInRoom(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_TAKE_IN_ROOM) ~=0;end
--禁止取款
function IsForfendTakeInGame(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_TAKE_IN_GAME) ~=0;end
--禁止存钱
function IsForfendSaveInRoom(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_SAVE_IN_ROOM) ~=0;end
--禁止存钱
function IsForfendSaveInGame(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_SAVE_IN_GAME) ~=0;end

--其他规则

--禁止配置
function IsForfendGameRule(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_GAME_RULE)~=0;end
--禁止锁桌
function IsForfendLockTable(dwServerRule)return bit._and(dwServerRule, SR_FORFEND_LOCK_TABLE)~=0;end
--允许陪玩
function IsAllowAndroidAttend(dwServerRule)return bit._and(dwServerRule, SR_ALLOW_ANDROID_ATTEND)~=0;end
--允许占位
function IsAllowAndroidSimulate(dwServerRule)return bit._and(dwServerRule, SR_ALLOW_ANDROID_SIMULATE)~=0;end

--聊天规则

--禁止公聊
function SetForfendGameChat(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_GAME_CHAT)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_GAME_CHAT)
    end
    return mdwServerRule
end
--禁止公聊
function SetForfendRoomChat(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_ROOM_CHAT)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_ROOM_CHAT)
    end
    return mdwServerRule
end
--禁止私聊
function SetForfendWisperChat(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_WISPER_CHAT)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_WISPER_CHAT)
    end
    return mdwServerRule
end
--禁止私聊
function SetForfendWisperOnGame(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_WISPER_ON_GAME)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_WISPER_ON_GAME)
    end
    return mdwServerRule
end

--模式规则

--动态加入
function SetAllowDynamicJoin(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_ALLOW_DYNAMIC_JOIN)
    else
        mdwServerRule = bit._not(dwServerRule, SR_ALLOW_DYNAMIC_JOIN)
    end
    return mdwServerRule
end
--断线代打
function SetAllowOffLineTrustee(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_ALLOW_OFFLINE_TRUSTEE)
    else
        mdwServerRule = bit._not(dwServerRule, SR_ALLOW_OFFLINE_TRUSTEE)
    end
    return mdwServerRule
end
--隐藏信息
function SetAllowAvertCheatMode(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE)
    else
        mdwServerRule = bit._not(dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE)
    end
    return mdwServerRule
end
--快速模式
function SetAllowQuickMode(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_ALLOW_QUICK_MODE)
    else
        mdwServerRule = bit._not(dwServerRule, SR_ALLOW_QUICK_MODE)
    end
    return mdwServerRule
end

--游戏规则

--记录积分
function SetRecordGameScore(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_RECORD_GAME_SCORE)
    else
        mdwServerRule = bit._not(dwServerRule, SR_RECORD_GAME_SCORE)
    end
    return mdwServerRule
end
--记录过程
function SetRecordGameTrack(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_RECORD_GAME_TRACK)
    else
        mdwServerRule = bit._not(dwServerRule, SR_RECORD_GAME_TRACK)
    end
    return mdwServerRule
   -- (bEnable==true)?dwServerRule|=SR_RECORD_GAME_TRACK:dwServerRule&=~SR_RECORD_GAME_TRACK;
end
--动态底分
function SetDynamicCellScore(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_DYNAMIC_CELL_SCORE)
    else
        mdwServerRule = bit._not(dwServerRule, SR_DYNAMIC_CELL_SCORE)
    end
    return mdwServerRule
end
    --(bEnable==true)?dwServerRule|=SR_DYNAMIC_CELL_SCORE:dwServerRule&=~SR_DYNAMIC_CELL_SCORE;end
--即时写分
function SetImmediateWriteScore(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_DYNAMIC_CELL_SCORE)
    else
        mdwServerRule = bit._not(dwServerRule, SR_DYNAMIC_CELL_SCORE)
    end
    return mdwServerRule
end
    --(bEnable==true)?dwServerRule|=SR_IMMEDIATE_WRITE_SCORE:dwServerRule&=~SR_IMMEDIATE_WRITE_SCORE;end

--房间规则

--禁止进入
function SetForfendRoomEnter(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_ROOM_ENTER)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_ROOM_ENTER)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_FORFEND_ROOM_ENTER:dwServerRule&=~SR_FORFEND_ROOM_ENTER;end
--禁止进入
function SetForfendGameEnter(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_GAME_ENTER)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_GAME_ENTER)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_FORFEND_GAME_ENTER:dwServerRule&=~SR_FORFEND_GAME_ENTER;end
--禁止旁观
function SetForfendGameLookon(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_GAME_LOOKON)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_GAME_LOOKON)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_FORFEND_GAME_LOOKON:dwServerRule&=~SR_FORFEND_GAME_LOOKON;end

--银行规则

--禁止取款
function SetForfendTakeInRoom(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_TAKE_IN_ROOM)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_TAKE_IN_ROOM)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_FORFEND_TAKE_IN_ROOM:dwServerRule&=~SR_FORFEND_TAKE_IN_ROOM;end
--禁止取款
function SetForfendTakeInGame(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_TAKE_IN_GAME)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_TAKE_IN_GAME)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_FORFEND_TAKE_IN_GAME:dwServerRule&=~SR_FORFEND_TAKE_IN_GAME;end
--禁止存钱
function SetForfendSaveInRoom(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_SAVE_IN_ROOM)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_SAVE_IN_ROOM)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_FORFEND_SAVE_IN_ROOM:dwServerRule&=~SR_FORFEND_SAVE_IN_ROOM;end
--禁止存钱
function SetForfendSaveInGame(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_SAVE_IN_GAME)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_SAVE_IN_GAME)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_FORFEND_SAVE_IN_GAME:dwServerRule&=~SR_FORFEND_SAVE_IN_GAME;end

--其他规则

--禁止配置
function SetForfendGameRule(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_GAME_RULE)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_GAME_RULE)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_FORFEND_GAME_RULE:dwServerRule&=~SR_FORFEND_GAME_RULE;end
--禁止锁桌
function SetForfendLockTable(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_FORFEND_LOCK_TABLE)
    else
        mdwServerRule = bit._not(dwServerRule, SR_FORFEND_LOCK_TABLE)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_FORFEND_LOCK_TABLE:dwServerRule&=~SR_FORFEND_LOCK_TABLE;end
--允许陪玩
function SetAllowAndroidAttend(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_ALLOW_ANDROID_ATTEND)
    else
        mdwServerRule = bit._not(dwServerRule, SR_ALLOW_ANDROID_ATTEND)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_ALLOW_ANDROID_ATTEND:dwServerRule&=~SR_ALLOW_ANDROID_ATTEND;end
--允许占位
function SetAllowAndroidSimulate(dwServerRule, bEnable)
    local mdwServerRule = dwServerRule
    if (bEnable==true) then
        mdwServerRule = bit._or(dwServerRule, SR_ALLOW_ANDROID_SIMULATE)
    else
        mdwServerRule = bit._not(dwServerRule, SR_ALLOW_ANDROID_SIMULATE)
    end
    return mdwServerRule
end
--(bEnable==true)?dwServerRule|=SR_ALLOW_ANDROID_SIMULATE:dwServerRule&=~SR_ALLOW_ANDROID_SIMULATE;end