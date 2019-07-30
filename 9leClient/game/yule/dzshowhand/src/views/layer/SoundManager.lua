local SoundManager = class("SoundManager")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
function SoundManager:ctor()
    self.soundRes = {

        ["userSound"] = {
            --1:加注
            {
                "raise.mp3",
            },
            --2:allin
            {
                "allin.mp3",
            },
            --3:跟注
            {
                "call.mp3",
            },
            --4:弃牌
            {
                "fold.mp3",
            },
            --5:过
            {
                "guo.mp3",
            }
        },
    ["gameEffect"] = 
    {
        --1：下注筹码的声音
        {
            "sound/chipfly.mp3",
            "sound/hechip.mp3",
        },
        --2：allin
        {
            "sound/allin.mp3",
        },
        --3:发牌
        {
            "sound/fapai.mp3",
            "sound/fapai1.mp3",
            "sound/fapai2.mp3",
            "sound/fapai3.mp3",
            "sound/fapaia.mp3",
            "sound/fapaib.mp3",
        },
        --4:出牌提示
        {
            "sound/TISHICHUPAI.mp3",
        },
        --5:时间过半提示
        {
            "sound/half_time.mp3"
        },
        --6：弃牌（牌飞出的声音）
        {
            "sound/foldpai.mp3",
        },
        --7：赢
        {
            "sound/ying.mp3",
        },
        --8:输
        {
            "sound/lose.mp3"

        },
        --9:结算
        {
            "sound/SETTLEMENT.mp3",
        },
        --10:葫芦
        {
            "sound/cardtype_hulu.mp3"
        },
        --11:金刚
        {
            "sound/cardtype_jingang.mp3",
        },
        --12:同花顺
        {
            "sound/cardtype_tonghua.mp3",
        },
        --13:皇家同花顺
        {

            "sound/cardtype_huangjiatonghua.mp3",
        },
        --14：血拼
        {
            "sound/xuepinbg.mp3",

        },
    },
    ["bg"] = 
        {
            "sound/back.mp3",
        }
    }
end

--根据性别播放音效
function SoundManager:playUserSound(useritem,soundID,frist)
    if useritem == nil then
        return
    end
    local soundStr = "userSound"
    if self.soundRes[soundStr][soundID] then
        if #self.soundRes[soundStr][soundID] == 1 or frist == nil then
            ExternalFun.playSoundEffect(self.soundRes[soundStr][soundID][1],useritem)
        elseif self.soundRes[soundStr][soundID][frist] then
            ExternalFun.playSoundEffect(self.soundRes[soundStr][soundID][frist],useritem)
        else
            ExternalFun.playSoundEffect(self.soundRes[soundStr][soundID][1],useritem)
        end
    end
end

--播放游戏的通用音效
function SoundManager:playEffectCommon(soundID,frist)
    local soundStr = "gameEffect"
    if self.soundRes[soundStr][soundID] then
        if #self.soundRes[soundStr][soundID] == 1 or frist == nil then
            ExternalFun.playSoundEffect(self.soundRes[soundStr][soundID][1],useritem)
        elseif self.soundRes[soundStr][soundID][frist] then
            ExternalFun.playSoundEffect(self.soundRes[soundStr][soundID][frist],useritem)
        else
            ExternalFun.playSoundEffect(self.soundRes[soundStr][soundID][1],useritem)
        end
    end
end

--播放背景
function SoundManager:playBackgroudAudio()
    ExternalFun.playBackgroudAudio(self.soundRes["bg"][1])
end

return SoundManager