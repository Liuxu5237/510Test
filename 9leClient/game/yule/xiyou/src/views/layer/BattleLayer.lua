--
-- Author: Your Name
-- Date: 2015-09-24 18:58:25
--

local BattleLayer = class("BattleLayer", function ()
    return cc.Layer:create()
end)

require "cocos.init"
local module_pre = "game.yule.xiyou.src"
local Data = appdf.req(module_pre .. ".models.Data")
local scheduler = cc.Director:getInstance():getScheduler()
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local ArmatureDataMgr = ccs.ArmatureDataManager:getInstance()
local schedulerEntry = nil 
local nFightRandom = 0
local SetX = 2.61
local SetY = 2.08

function BattleLayer:ctor(scene)
    self._scene  = scene
    self:init()
end

function BattleLayer:onEnter()
	--Data.nTurnIndex = 0
    print("BattleLayer:onEnter")
end 

function BattleLayer:onExit()
    print("BattleLayer:onExit")
    --cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("BattlePlist.plist")
end 

function BattleLayer:init()
    --cc.SpriteFrameCache:getInstance():addSpriteFrames("BattlePlist.plist")

    print("BattleLayer:init")
	self:setTouchEnabled(true)
	self:registerScriptHandler(function (event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)
    
    local arm = Data.nStartRoll[1] + 1
    -- 3 龙王 1 yang 2 zhizhu 4 gongzhu 0 houzi 5baozou

    local backList = {"2.png","1.png","4.png","3.png"}

    local houzi = "0.png"
    if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
        houzi = "5.png"
    end 
    -- 加背景
    --[[
    local backRight = cc.Sprite:createWithSpriteFrameName(houzi)
    backRight:setAnchorPoint(1,0.5)
    backRight:setPosition(cc.p(1280,375))
    self:addChild(backRight,0)
    backRight:setVisible(false)

    local backLeft = cc.Sprite:createWithSpriteFrameName(backList[arm])
    backLeft:setAnchorPoint(0,0.5)
    backLeft:setPosition(cc.p(0,375))
    self:addChild(backLeft,0)
    backLeft:setVisible(false)
    ]]

    local winMusic = nil

    --local animation = self.studioAni:getAnimation()
    local function animationEvent(armatureBack,movementType,movementID)
            local id = movementID
            --print(" movementType " .. movementType)
            --print(" id " .. id)
            if movementType == ccs.MovementEventType.complete then
                print(" id " .. id)
                for i = 1, 4 do 
                    if Data.ArmBattleEnter[i] == id then 
                        --backLeft:setVisible(true)
                        --backRight:setVisible(true)

                        local wukong = {"Sound/WuKong/16.mp3","Sound/WuKong/17.mp3"}
                        local other = {"Sound/ZhiZhu/8.mp3","Sound/YangJi/14.mp3","Sound/GongZhu/8.mp3","Sound/LongWang/11.mp3"}
                        local winlist = {"Sound/ZhiZhu/3.mp3","Sound/YangJi/3.mp3","Sound/GongZhu/3.mp3","Sound/LongWang/3.mp3"}
                        -- 播放进入音效
                        if Data.nStartType == 0 then 
                            AudioEngine.playEffect(wukong[1])
                        else 
                            AudioEngine.playEffect(other[i])
                        end 

                        winMusic = winlist[i]
                    end 
                end 
            elseif movementType == 0 then
                for i = 1, 4 do 
                    if Data.ArmBattleWin[i] == id then 
                        --backLeft:setVisible(false)
                        --backRight:setVisible(false)
                        break
                    end 
                    if Data.ArmBattleWin1[i] == id then 
                        --backLeft:setVisible(false)
                        --backRight:setVisible(false)
                        break
                    end
                    if Data.ArmBattleLose[i] == id then 
                        --backLeft:setVisible(false)
                        --backRight:setVisible(false)
                        break
                    end
                end
            end
        end

    --animation:setMovementEventCallFunc(animationEvent)

    -- 开始进入播放进入战斗
    local enterani = Data.NewVs[arm]
    if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
        enterani = Data.NewBaoVs[arm]
    end 

    -- 进场景 
    self.studioBeginAni = ccs.Armature:create("Action_1")
    self.studioBeginAni:setPosition(cc.p(667,375))
    self.studioBeginAni:setScaleX(SetX)
    self.studioBeginAni:setScaleY(SetY)
    self.studioBeginAni:setLocalZOrder(0)
    self:addChild(self.studioBeginAni)
    self.studioBeginAni:setVisible(false)

    -- 战斗 Fight 
    self.studioBattleAni = ccs.Armature:create("WuKongVS")
    self.studioBattleAni:setPosition(cc.p(667,375))
    self.studioBattleAni:setScaleX(SetX)
    self.studioBattleAni:setScaleY(SetY)
    self.studioBattleAni:setLocalZOrder(0)
    self:addChild(self.studioBattleAni)
    self.studioBattleAni:setVisible(false)

    -- 暴走悟空赢
    self.studioPK_BaoZouAni = ccs.Armature:create("PK_BaoZou")
    self.studioPK_BaoZouAni:setPosition(cc.p(667,375))
    self.studioPK_BaoZouAni:setScaleX(SetX)
    self.studioPK_BaoZouAni:setScaleY(SetY)
    self.studioPK_BaoZouAni:setLocalZOrder(0)
    self:addChild(self.studioPK_BaoZouAni)
    self.studioPK_BaoZouAni:setVisible(false)

    -- 铁扇公主赢
    self.studioPK_GZAni = ccs.Armature:create("PK_GZ_1")
    self.studioPK_GZAni:setPosition(cc.p(667,375))
    self.studioPK_GZAni:setScaleX(SetX)
    self.studioPK_GZAni:setScaleY(SetY)
    self.studioPK_GZAni:setLocalZOrder(0)
    self:addChild(self.studioPK_GZAni)
    self.studioPK_GZAni:setVisible(false)

    -- 蜘蛛精赢
    self.studioPK_ZZAni = ccs.Armature:create("PK_ZZ_1")
    self.studioPK_ZZAni:setPosition(cc.p(667,375))
    self.studioPK_ZZAni:setScaleX(SetX)
    self.studioPK_ZZAni:setScaleY(SetY)
    self.studioPK_ZZAni:setLocalZOrder(0)
    self:addChild(self.studioPK_ZZAni)
    self.studioPK_ZZAni:setVisible(false)

    -- 悟空战胜
    self.studioPK_MonkeyAni = ccs.Armature:create("PK_Monkey")
    self.studioPK_MonkeyAni:setPosition(cc.p(667,375))
    self.studioPK_MonkeyAni:setScaleX(SetX)
    self.studioPK_MonkeyAni:setScaleY(SetY)
    self.studioPK_MonkeyAni:setLocalZOrder(0)
    self:addChild(self.studioPK_MonkeyAni)
    self.studioPK_MonkeyAni:setVisible(false)

    -- 龙王赢
    self.studioPK_LWAni = ccs.Armature:create("PK_LW_1")
    self.studioPK_LWAni:setPosition(cc.p(667,375))
    self.studioPK_LWAni:setScaleX(SetX)
    self.studioPK_LWAni:setScaleY(SetY)
    self.studioPK_LWAni:setLocalZOrder(0)
    self:addChild(self.studioPK_LWAni)
    self.studioPK_LWAni:setVisible(false)

    -- 杨戬赢
    self.studioPK_YJAni = ccs.Armature:create("PK_YJ_3")
    self.studioPK_YJAni:setPosition(cc.p(667,375))
    self.studioPK_YJAni:setScaleX(SetX)
    self.studioPK_YJAni:setScaleY(SetY)
    self.studioPK_YJAni:setLocalZOrder(0)
    self:addChild(self.studioPK_YJAni)
    self.studioPK_YJAni:setVisible(false)

    -- 站立笑
    Data.studioXiaoAni = ccs.Armature:create("BossWin")
    Data.studioXiaoAni:setPosition(cc.p(667,375))
    Data.studioXiaoAni:setScaleX(SetX)
    Data.studioXiaoAni:setScaleY(SetY)
    Data.studioXiaoAni:setLocalZOrder(0)
    self:addChild(Data.studioXiaoAni)
    Data.studioXiaoAni:setVisible(false)

    local randomnum = math.random(1,1000)
    if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
        AudioEngine.playEffect("Sound/WuKong/17.mp3")
    else
        if randomnum < 500 then 
            AudioEngine.playEffect("Sound/WuKong/16.mp3")
        else
            local roleid = Data.nStartRoll[1]+1
            AudioEngine.playEffect(Data.NewEnterSound[roleid])
        end        
    end 

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.4),cc.CallFunc:create(function() 
            self:PlayGameBegin(Data.nStartRoll[1]+1)
            self:stopAllActions()
            self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                        -- 出结果 
                        print("Data.nStartActionBegin-----------:"..Data.nStartActionBegin)
                        if Data.nStartActionBegin == 5 or Data.nStartActionBegin == 6 then
                            -- 怪物和悟空相互攻击一轮之后
                            if Data.nFirstAttack == 1 and Data.nStartActionBegin == 5 then 
                                self:PlayFightSecond(1)
                            end

                            if Data.nFirstAttack == 0 and Data.nStartActionBegin == 6 then 
                                self:PlayFightSecond(2)
                            end
                        else 

                            --AudioEngine.playEffect("Sound/Zhuang.mp3")
                            local tmpNode = cc.Node:create()
                            self:addChild(tmpNode)
                            tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()              
                                            --AudioEngine.playEffect("Sound/Bomb.mp3")
                                        end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                                            tmpNode:removeFromParent(true)
                                        end )
                                    ))

                            if Data.nStartActionBegin == 1 then   --怪物攻击
                                --nFightRandom = math.random(1,2)
                                 print("============【nFirstAttack】==========:"..Data.nFirstAttack) 
                                if Data.nFirstAttack == 1 then
                                    print("====【悟空先出手】===")    
                                else
                                    print("====【怪物先出手】===") 
                                end
                                
                                --怪物和悟空打斗开始
                                --随机选择怪物和悟空首先出手权
                                if Data.nFirstAttack == 1 then
                                    self:PlayFightFirst(1)
                                else
                                    self:PlayFightFirst(2)
                                end
                            end 
                        end 


                        Data.nStartActionBegin = Data.nStartActionBegin + 1
            end ))))
    end)))
end

--进场景
function BattleLayer:PlayGameBegin(nRole)
    print("---------------------【开始打斗】--------------------------")
    Data.studioAni:setVisible(false)
    self.studioBeginAni:setVisible(true)
    self.studioBeginAni:getAnimation():play(Data.NewWuKongBattle[nRole], -1, 0)  -- 0:不循环 1：循环
end
-- 加载资源 动画 播动作
-- 赢
function BattleLayer:PlayWukongWin(nRole)
    self.studioBattleAni:setVisible(false)
    self.studioPK_MonkeyAni:setVisible(true)
    self.studioPK_MonkeyAni:getAnimation():play(Data.NewBaoVs[nRole], -1, 0)
end 

function BattleLayer:PlayWukongWin1(nRole)
    self.studioBattleAni:setVisible(false)
    self.studioPK_MonkeyAni:setVisible(true)
    self.studioPK_MonkeyAni:getAnimation():play(Data.NewBaoVs[nRole], -1, 0)
end 

-- 输
function BattleLayer:PlayWukongLose(nRole)
    Data.aniList = {self.studioPK_ZZAni,self.studioPK_YJAni,self.studioPK_GZAni,self.studioPK_LWAni}
    self.studioBattleAni:setVisible(false)
    Data.aniList[nRole]:setVisible(true)
    Data.aniList[nRole]:getAnimation():play(Data.NewBattleLose[nRole], -1, 0)
end 

-- 暴走悟空赢
function BattleLayer:PlayBaoWukongWin(nRole)
    self.studioPK_BaoZouAni:setVisible(true)
    self.studioPK_BaoZouAni:getAnimation():play(Data.NewVs[nRole] .. "_MK", -1, 0)
end 

-- 加载战斗动画
function BattleLayer:LoadNewSkill(nRole)

end 

-- 怪物普通攻击
function BattleLayer:PlayNewSkill(nRole)
    self.studioBeginAni:setVisible(false)
    Data.studioAni:setVisible(false)
    self.studioBattleAni:setVisible(true)
    self.studioBattleAni:getAnimation():play(Data.NewBattleLeft[nRole], -1, 0)
    self:PlayBossMusic(nRole)
end 

function BattleLayer:PlayNewBaoZouSkill(nRole)
    self.studioBeginAni:setVisible(false)
    Data.studioAni:setVisible(false)
    self.studioBattleAni:setVisible(true)
    self.studioBattleAni:getAnimation():play(Data.NewBattleLeft[nRole], -1, 0)
    self:PlayBossMusic(nRole)
end 

--悟空普通攻击
function BattleLayer:PlayNewWuKongSkill(nRole)
    self.studioBeginAni:setVisible(false)
    Data.studioAni:setVisible(false)
    self.studioBattleAni:setVisible(true)
    self.studioBattleAni:getAnimation():play(Data.NewWuKongBattle[nRole], -1, 0)
    self:PlayWuKongMusic()
end 

function BattleLayer:PlayNewWuKongBaoZouSkill(nRole)
    self.studioBeginAni:setVisible(false)
    Data.studioAni:setVisible(false)
    self.studioBattleAni:setVisible(true)
    self.studioBattleAni:getAnimation():play(Data.NewWuKongBattle[nRole], -1, 0)
    self:PlayWuKongMusic()
end 

--怪物赢
function BattleLayer:PlayBosskillWuKong(nRole)
    self.studioBattleAni:setVisible(false)
    self:PlayWukongLose(nRole)
    self:PlayEndSkillMusic(nRole)
end

--悟空赢
function BattleLayer:PlayEndSkill(nRole)
    self.studioBattleAni:setVisible(false)
    -- 战斗
    --AudioEngine.playEffect("Sound/WuKongWin.mp3")
    if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
        self:PlayBaoWukongWin(nRole)
        self:PlayEndSkillMusicWKBaoZou(nRole)
    else 
        if (math.random(1,99) %2 == 0 ) then  -- 原本卡牌悟空赢，有两种播放方式
                                              -- 改成动画后，只有一种，如要增加，修改PlayWukongWin1
            --self:PlayWukongWin(nRole)
            --self:PlayEndSkillMusicWK0(nRole)
            self:PlayWukongWin(nRole)
            self:PlayEndSkillMusicWK0(nRole)
        else
            self:PlayWukongWin1(nRole)
            self:PlayEndSkillMusicWK0(nRole)
        end 
    end
end 

----------------------------------------------------------------------
--第一轮打斗  悟空和怪物互相攻击
function BattleLayer:PlayFightFirst(number)
    -- 悟空打斗和暴走悟空打斗动画统一一套
    -- 如要增加，修改PlayNewWuKongBaoZouSkill
    if number == 1 then
        -- 【悟空先出手】
        if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
            self:PlayNewWuKongBaoZouSkill(Data.nStartRoll[1]+1)
        else 
            self:PlayNewWuKongSkill(Data.nStartRoll[1]+1)
        end 

        self:runAction(cc.Sequence:create(cc.DelayTime:create(3.4),cc.CallFunc:create(function()
            if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
                self:PlayNewBaoZouSkill(Data.nStartRoll[1]+1)
            else 
                self:PlayNewSkill(Data.nStartRoll[1]+1)
            end
        end )))
    else
        -- 【怪物先出手】
        if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
            self:PlayNewBaoZouSkill(Data.nStartRoll[1]+1)
        else 
            self:PlayNewSkill(Data.nStartRoll[1]+1)
        end

        self:runAction(cc.Sequence:create(cc.DelayTime:create(2.6),cc.CallFunc:create(function()
            -- 暴走状态
            if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
                self:PlayNewWuKongBaoZouSkill(Data.nStartRoll[1]+1)
            else 
                self:PlayNewWuKongSkill(Data.nStartRoll[1]+1)
            end 
        end )))
    end
end

--第二轮打斗  悟空赢 or 怪物赢
function BattleLayer:PlayFightSecond(number)
    if number == 1 then
        -- 悟空赢：第三轮悟空击杀怪物(击杀模式)，游戏结束
        -- 怪物赢(暴走)：第三轮悟空普通攻击怪物后，怪物击杀悟空(击杀模式),游戏结束
        if Data.nActionNum == 3 then 
            Data.WhoWin = 1
            print("================【悟空打赢】==============")
            self:PlayEndSkill(Data.nStartRoll[1]+1)
            if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
                self:PlayWhoXiao(true,9)
            else 
                self:PlayWhoXiao(true,5.2)
            end
        else
            self:PlayNewWuKongSkill(Data.nStartRoll[1]+1)
            self:runAction(cc.Sequence:create(cc.DelayTime:create(2.6),cc.CallFunc:create(function()
                Data.WhoWin = 2
                print("================【怪物打赢】==============")
                self:PlayBosskillWuKong(Data.nStartRoll[1]+1)
                self:PlayWhoXiao(false,3.5)
            end )))
        end 
    else
        -- 怪物赢：第三轮怪物击杀悟空(击杀模式)，游戏结束
        -- 悟空赢(暴走)：第三轮怪物普通攻击悟空后，悟空击杀怪物(击杀模式),游戏结束
        local n = math.random(1,10)
        if Data.nActionNum == 3 then --怪物赢
            Data.WhoWin = 2
            print("================【怪物打赢】==============")
            self:PlayBosskillWuKong(Data.nStartRoll[1]+1)
            self:PlayWhoXiao(false,3.5)
        else
            self:PlayNewSkill(Data.nStartRoll[1]+1)
            self:runAction(cc.Sequence:create(cc.DelayTime:create(2.7),cc.CallFunc:create(function()
                Data.WhoWin = 1
                print("================【悟空打赢】==============")
                    self:PlayEndSkill(Data.nStartRoll[1]+1)
                    if Data.nStartIndex[1] == 0 or Data.nStartIndex[1] == 13 then 
                        self:PlayWhoXiao(true,9)
                    else 
                        self:PlayWhoXiao(true,5.2)
                    end 
            end )))
        end
    end
end
----------------------------------------------------------------------

function BattleLayer:PlayWhoXiao(nWho,nTime)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(nTime),cc.CallFunc:create(function()
        print("****************【战斗结束 - 播放站立笑】****************")
        if nWho then
            self:PlayWuKongXiao()
        else
            self:PlayBossXiao(Data.nStartRoll[1]+1)
        end
        self:PlayFightEnd()
    end )))
end

--怪物赢后站立笑
function BattleLayer:PlayBossXiao(nRole)
    Data.isFight = true
    Data.aniList[nRole]:setVisible(false)
    Data.studioXiaoAni:setVisible(true)
    Data.studioXiaoAni:getAnimation():play(Data.NewXiaoBattle[nRole], -1, 1)  
end

--悟空赢后站立笑
function BattleLayer:PlayWuKongXiao()
    Data.isFight = true
    self.studioPK_MonkeyAni:setVisible(false)
    Data.studioXiaoAni:setVisible(true)
    Data.studioXiaoAni:getAnimation():play("WuKong_vs_Win", -1, 1)  
end

--游戏结束 - 切换模式
function BattleLayer:PlayFightEnd()
    --self:stopAllActions()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.ScaleTo:create(0.5,1),cc.CallFunc:create(function()      
        local event = cc.EventCustom:new("EndTurnNext")
        eventDispatcher:dispatchEvent(event)
    end )))
end

-----------------------------【音频处理】----------------------------------
function BattleLayer:PlayEndSkillMusic(nRole)
    if nRole == 1 then
        self:PlayEndSkillMusicZZ()
    elseif nRole == 2 then 
        self:PlayEndSkillMusicYJ()
    elseif nRole == 3 then 
        self:PlayEndSkillMusicGZ()
    elseif nRole == 4 then 
        self:PlayEndSkillMusicLW()
    end  
end 

-- 蜘蛛音效
function BattleLayer:PlayEndSkillMusicZZ()
    local tmpNode = cc.Node:create()
    self:addChild(tmpNode)
    AudioEngine.playEffect("Sound/ZhiZhu/9.mp3")
    AudioEngine.playEffect("Sound/Zhuang.mp3")
    tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()              
                    AudioEngine.playEffect("Sound/ZhiZhu/12.mp3")
                end ),cc.DelayTime:create(3.2),cc.CallFunc:create(function()
                    AudioEngine.playEffect("Sound/ZhiZhu/10.mp3")
                end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                    tmpNode:removeFromParent(true)
                end )
            ))
end 

-- 杨戬音效
function BattleLayer:PlayEndSkillMusicYJ()
    local tmpNode = cc.Node:create()
    self:addChild(tmpNode)
    AudioEngine.playEffect("Sound/YangJi/4.mp3")
    AudioEngine.playEffect("Sound/Zhuang.mp3")
    tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()              
                    AudioEngine.playEffect("Sound/YangJi/18.mp3")
                end ),cc.DelayTime:create(3.5),cc.CallFunc:create(function()
                    AudioEngine.playEffect("Sound/YangJi/3.mp3")
                end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                    tmpNode:removeFromParent(true)
                end )
            ))
end 

-- 公主音效
function BattleLayer:PlayEndSkillMusicGZ()
    local tmpNode = cc.Node:create()
    self:addChild(tmpNode)
    
    AudioEngine.playEffect("Sound/GongZhu/4.mp3")
    AudioEngine.playEffect("Sound/Zhuang.mp3")
    tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.2),cc.CallFunc:create(function()              
                    AudioEngine.playEffect("Sound/GongZhu/14.mp3")
                end ),cc.DelayTime:create(3.05),cc.CallFunc:create(function()
                    AudioEngine.playEffect("Sound/GongZhu/15.mp3")
                end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                    tmpNode:removeFromParent(true)
                end )
            ))
end 

-- 龙王音效
function BattleLayer:PlayEndSkillMusicLW()
    local tmpNode = cc.Node:create()
    self:addChild(tmpNode)
    AudioEngine.playEffect("Sound/LongWang/4.mp3")
    AudioEngine.playEffect("Sound/Zhuang.mp3")
    tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()              
                    AudioEngine.playEffect("Sound/LongWang/12.mp3")
                end ),cc.DelayTime:create(2.75),cc.CallFunc:create(function()
                    AudioEngine.playEffect("Sound/LongWang/3.mp3")
                end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                    tmpNode:removeFromParent(true)
                end )
            ))
end 

-- 悟空0音效
function BattleLayer:PlayEndSkillMusicWK0(nRole)
    local tmpNode = cc.Node:create()
    self:addChild(tmpNode)
     AudioEngine.playEffect("Sound/WuKong/7.mp3")
    tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()              
                    AudioEngine.playEffect("Sound/WuKong/27.mp3")
                end ),cc.DelayTime:create(3),cc.CallFunc:create(function()              
                    AudioEngine.playEffect("Sound/WuKong/3.mp3")
                    AudioEngine.playEffect(Data.AttackBossSound[roleid])
                end ),cc.DelayTime:create(5),cc.CallFunc:create(function()
                    tmpNode:removeFromParent(true)
                end )
            ))

end 

-- 悟空1音效
function BattleLayer:PlayEndSkillMusicWK1(nRole)
    local tmpNode = cc.Node:create()
    self:addChild(tmpNode)
    AudioEngine.playEffect("Sound/WuKong/7.mp3")
    tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()              
                    AudioEngine.playEffect("Sound/WuKong/27.mp3")
                end ),cc.DelayTime:create(3),cc.CallFunc:create(function()              
                    AudioEngine.playEffect("Sound/WuKong/3.mp3")
                end ),cc.DelayTime:create(5),cc.CallFunc:create(function()
                    tmpNode:removeFromParent(true)
                end )
            ))

end 

-- 悟空暴走音效
function BattleLayer:PlayEndSkillMusicWKBaoZou(nRole)
    local tmpNode = cc.Node:create()
    self:addChild(tmpNode)
    AudioEngine.playEffect("Sound/Zhuang.mp3")
    tmpNode:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()              
                    AudioEngine.playEffect("Sound/WuKong/28.mp3")
                end ),cc.DelayTime:create(3),cc.CallFunc:create(function()
                    AudioEngine.playEffect("Sound/WuKong/29.mp3")
                end ),cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                    tmpNode:removeFromParent(true)
                end )
            ))
end 

function BattleLayer:PlayBossMusic(nRole) --怪物普通攻击音效
    if nRole == 1 then 
        self:PlayBossFightMusic(nRole)
    elseif nRole == 2 then 
        self:PlayBossFightMusic(nRole)
    elseif nRole == 3 then 
        self:PlayBossFightMusic(nRole)
    elseif nRole == 4 then 
        self:PlayBossFightMusic(nRole)
    end 
end

function BattleLayer:PlayBossFightMusic(nRole)
    AudioEngine.playEffect(Data.BossFightSound1[nRole])
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()
        AudioEngine.playEffect(Data.BossFightSound2[nRole])
        AudioEngine.playEffect("Sound/WuKong/1.mp3")
    end )))
end

function BattleLayer:PlayWuKongMusic() --悟空普通攻击音效
    AudioEngine.playEffect("Sound/WuKong/12.mp3")
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),cc.CallFunc:create(function()
        AudioEngine.playEffect("Sound/WuKong/13.mp3")
    end )))

    local roleid = Data.nStartRoll[1]+1
    self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
         AudioEngine.playEffect(Data.AttackBossSound[roleid])
    end )))
end


return BattleLayer