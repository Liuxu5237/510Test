--游戏交互层 onSocketCallBack
cc.FileUtils:getInstance():addSearchPath("game/yule/lkpys/res")

local GameLayer = class("GameLayer", function(frameEngine,scene)
    --创建物理世界
      --cc.Director:getInstance():setDisplayStats(true)
      --cc.Director:getInstance():getRunningScene():destryPhysicWorld()
    cc.Director:getInstance():getRunningScene():initWithPhysics()

      --cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0,-100))
    local gameLayer = display.newLayer()
    
    return gameLayer
end)  

local TAG_ENUM = 
{
  Tag_Fish = 200
}
local FISH_TTYPE = 
{
  fish_normal = 1,
  fish_linear = 2,
  fish_round  = 3,
  fish_pause  = 4,
}

require("cocos.init")
local module_pre = "game.yule.lkpy.src"     
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local QueryDialog = appdf.req("app.views.layer.other.QueryDialog")
local cmd = module_pre..".models.CMD_LKGame"
local game_cmd = appdf.CLIENT_SRC..".plaza.models.CMD_GameServer"
local g_var = ExternalFun.req_var
local GameFrame = module_pre..".models.GameFrame"
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local GameViewLayer = module_pre..".views.layer.GameViewLayer"
local Fish = module_pre..".views.layer.Fish"
local CannonLayer = module_pre..".views.layer.CannonLayer"
local PRELOAD = require(module_pre..".views.layer.PreLoading")
local scheduler = cc.Director:getInstance():getScheduler()

local TimestampManager 		= appdf.req(module_pre .. ".models.TimestampManager")

local delayLeaveTime = 0.3 

local exit_timeOut = 3 --退出超时时间

local SYNC_SECOND = 1

function GameLayer:ctor( frameEngine,scene )
    cc.SpriteFrameCache:getInstance():addSpriteFrames("loading/bg.png")
    self.m_infoList = {}
    self.selectFishList = {}
    self.selectFishAngle = false
    self.m_scheduleUpdate = nil
    self.m_secondCountSchedule = nil
    self._scene = scene
    self.m_bScene = false
    self.m_bSynchronous = false
    self.m_nSecondCount = 120
    self.m_catchFishCount = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self._gameFrame = frameEngine
    self._gameFrame:setKindInfo(cmd.KIND_ID,cmd.VERSION)
    self._gameView = g_var(GameViewLayer):create(self) --加载所需资源
    :addTo(self)

    self._dataModel = g_var(GameFrame):create()

    self.m_pUserItem = self._gameFrame:GetMeUserItem()
    self.m_nTableID  = self.m_pUserItem.wTableID
    self.m_nChairID  = self.m_pUserItem.wChairID  

    self:setReversal()

    --准备炮台
    self.m_cannonLayer = g_var(CannonLayer):create(self) 
    self._gameView:addChild(self.m_cannonLayer, 7)

    --鱼层
    self.m_fishLayer = cc.Layer:create()
    self._gameView:addChild(self.m_fishLayer, 5)
    if self._dataModel.m_reversal then
        -- self.m_fishLayer:setRotation(180)
    end
    
    --自己信息
    -- self._gameView:initUserInfo()

    --创建定时器 刷鱼
    self:onCreateSchedule()

    --60秒未开炮倒计时
    self:createSecoundSchedule()

    --注册事件
    ExternalFun.registerTouchEvent(self,true)

    --注册通知
    self:addEvent()

  
    --打开调试模式
    -- cc.Director:getInstance():getRunningScene():getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    ----------------new add------------
    self.firstInTime = 0
    self.musicCount = 0
    self.changeSceneTimes = 1
    self.current_bullet_kind_ = 2
    self.createFishList = {}
    self.fish_multiple_ = {}  --各种鱼倍数分
    self.fish_speed_ = {} --鱼速度
    self.fish_bounding_box_width_ = {} --鱼边界框的宽度
    self.fish_bounding_box_height_ = {} --鱼边界框的高度
    self.fish_hit_radius_ = {} --击中鱼的半径
    self.bullet_speed_ = {}
    self.net_radius_ = {}
    self.fish18_max_multiple_ = 0
    self.fish19_max_multiple_ = 0
    self.fishLK_max_multiple_ = 0
    self.lock_fish_id_ = {}
    self.fishkindNum = {}
    self.sceneFishPos = {}
    for i=1, 8 do
        self.lock_fish_id_[i] = 0
    end

    self.GameingScore = 0

    --self:sceneKindTrace()
    --特效test
    -- local ding = cc.ParticleSystemQuad:create("ding.plist")
    -- ding:setPosition(cc.p(750,375))
    -- ding:retain()
    -- local batch = cc.ParticleBatchNode:createWithTexture(ding:getTexture())
    -- batch:addChild(ding)
    -- self:addChild(batch, 10)
    -- local function sss(  )
    --     local boomAnim = cc.AnimationCache:getInstance():getAnimation("WaterAnim")
    --     --print("boomAnim ",boomAnim)
    --     local bomb = cc.Sprite:create()
    --     bomb:setPosition(667,375)
    --     bomb:runAction(cc.Animate:create(boomAnim))
    --     self:addChild(bomb)
    -- end
    
end
--保存鱼潮坐标点
function GameLayer:sceneKindTrace()
    local M_PI   = 3.14159265358979323846
    local M_PI_2 = 1.57079632679489661923
    local M_PI_4 = 0.785398163397448309616
    local M_1_PI = 0.318309886183790671538
    local M_2_PI = 0.636619772367581343076
    
    local screen_width, screen_height = cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height
-- * @brief  创建一个圆
-- * @param [in] center_x       中心x坐标
-- * @param [in] center_y       中心y坐标
-- * @param [in] radius         半径
-- * @param [in] fish_pos       圆各顶点 no need
-- * @param [in] fish_count     画多少个点
    local function buildCircle( center_x, center_y, radius, fish_count )
        if fish_count <= 0 then return end
        local fp = {}
        local cell_radian = 2 * M_PI / fish_count
        for i=1, fish_count do 
            fp[i] = cc.p(center_x + radius * math.cos( (i-1) * cell_radian), center_y + radius * math.sin( (i-1) * cell_radian) )
        end

        return fp
    end
    local function buildCircle1( center_x, center_y, radius, fish_count, rotate, rotate_speed )
        if fish_count <= 0 then return end
        local cell_radian = 2 * M_PI / fish_count
        local last_pos = cc.p(0,0)
        -- local fp = {x=0,y=0,angle=0}
        local fp = {}
        for i=1, fish_count do
            last_pos.x = center_x + radius * math.cos((i-1) * cell_radian + rotate - rotate_speed)
            last_pos.y = center_y + radius * math.sin((i-1) * cell_radian + rotate - rotate_speed)

            fp[i] = {x= center_x + radius * math.cos( (i-1) * cell_radian + rotate ),y = center_y + radius * math.sin( (i-1) * cell_radian + rotate ),angle=0}

            local temp_dis = cc.pGetDistance( cc.p( fp[i].x, fp[i].y ) , cc.p( last_pos.x, last_pos.y ) )
            if temp_dis ~= 0 then
                local temp_value = (fp[i].x - last_pos.x) / temp_dis
                if fp[i].y - last_pos.y >= 0 then
                    fp[i].angle = math.acos(temp_value)
                else
                    fp[i].angle = -math.acos(temp_value)
                end
            else
                fp[i].angle = M_PI_2
            end
        end

        return fp
    end
    local function angle_range( angle )
        while angle <= -M_PI * 2 do 
            angle = angle + M_PI * 2
        end

        if angle < 0 then
            angle = angle + M_PI * 2
        end

        while angle >= M_PI * 2 do 
            angle = angle - (M_PI * 2)
        end
        return angle
    end
    local function getTargetPoint( screen_width, screen_height, src_x_pos, src_y_pos, angle )
        angle = angle_range(angle)
        local target_x_pos = nil
        local target_y_pos = nil
        if angle > 0 and angle < M_PI_2 then
            target_x_pos = screen_width + 300
            target_y_pos = src_y_pos + (screen_width - src_x_pos + 300) * math.tan(angle)
        elseif angle >= M_PI_2 and angle < M_PI then
            target_x_pos = -300
            target_y_pos = src_y_pos - (src_x_pos + 300) * math.tan(angle)
        elseif angle >= M_PI and angle < 3*M_PI/2 then
            target_x_pos = -300
            target_y_pos = src_y_pos - (src_x_pos + 300) * math.tan(angle)
        else
            target_x_pos = screen_width + 300
            target_y_pos = src_y_pos + (screen_width - src_x_pos + 300) * math.tan(angle)
        end
        return target_x_pos, target_y_pos
    end
    local function buildLinear( init_x, init_y, init_count, distance )
        if init_count < 2 then return end
        if distance <= 0 then return end
        local distance_total = cc.pGetDistance( cc.p( init_x[init_count], init_y[init_count] ) , cc.p( init_x[1], init_y[1] ) )
        if distance_total <= 0 then return end
        local fpt = {}
        local cos_value  = math.abs( init_y[init_count] - init_y[1] ) / distance_total
        local temp_angle = math.acos(cos_value)
        local point = {x = init_x[1], y = init_y[1], angle = 1}
        fpt[1] = point
        local temp_distance = 0
        local temp_pos      = {x=0, y=0, angle=0}
        local size = 0
        while temp_distance < distance_total do 
            size = #fpt
            point = {x = 0, y = 0, angle = 1}

            if init_x[init_count] < init_x[1] then
                point.x = init_x[1] - math.sin(temp_angle) * (distance * size)
            else
                point.x = init_x[1] + math.sin(temp_angle) * (distance * size)
            end

            if init_y[init_count] < init_y[1] then
                point.y = init_y[1] - math.cos(temp_angle) * (distance * size)
            else
                point.y = init_y[1] + math.cos(temp_angle) * (distance * size)
            end

            local temp_dis = cc.pGetDistance( cc.p(point.x, point.y), cc.p(temp_pos.x, temp_pos.y) )
            if temp_dis ~= 0 then
                local temp_value = (point.x - temp_pos.x) / temp_dis
                if ((point.y - temp_pos.y) >= 0 ) then
                    point.angle = math.acos(temp_value)
                else
                    point.angle = -math.acos(temp_value)
                end
            else
                point.angle = 1
            end

            temp_pos.x = point.x
            temp_pos.y = point.y
            fpt[#fpt+1] = point
            temp_distance = cc.pGetDistance( cc.p(point.x, point.y), cc.p(init_x[1], init_y[1])  )
        end
        fpt[#fpt].x = init_x[init_count]
        fpt[#fpt].y = init_y[init_count]

        return fpt
    end

    local function scene1()
        self.sceneFishPos[1] = {}
        local fish_count = 0
        local kVScale = screen_height / yl.HEIGHT
        local kRadius = ( screen_height - (240 * kVScale) ) / 2
        local kSpeed  = 1.5 * screen_width / yl.WIDTH
        local center = cc.p(0,0)
        center.x = screen_width + kRadius
        center.y = kRadius + 120 * kVScale
        local fish_pos = nil
        fish_pos = buildCircle(center.x, center.y, kRadius, 100)
        local savePos  = {}
        for i=1, 100 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = -2 * kRadius
            local initY2 = initY1
            savePos[i] = {initX1, initY1, initX2, initY2}
            -- local posT = buildLinear( {initX1, initX2}, {initY1, initY2}, 2, kSpeed )
        end

        local kRotateRadian1 = 45 * M_PI / 180
        local kRotateRadian2 = 135 * M_PI / 180
        local kRadiusSmall = kRadius / 2
        local kRadiusSmall1 = kRadius / 3
        local center_small = {}
        center_small[1] = {}
        center_small[1].x = center.x + kRadiusSmall * math.cos(-kRotateRadian2)
        center_small[1].y = center.y + kRadiusSmall * math.sin(-kRotateRadian2)

        center_small[2] = {}
        center_small[2].x = center.x + kRadiusSmall * math.cos(-kRotateRadian1)
        center_small[2].y = center.y + kRadiusSmall * math.sin(-kRotateRadian1)

        center_small[3] = {}
        center_small[3].x = center.x + kRadiusSmall * math.cos(kRotateRadian2)
        center_small[3].y = center.y + kRadiusSmall * math.sin(kRotateRadian2)

        center_small[4] = {}
        center_small[4].x = center.x + kRadiusSmall * math.cos(kRotateRadian1)
        center_small[4].y = center.y + kRadiusSmall * math.sin(kRotateRadian1)

        fish_pos = buildCircle(center_small[1].x, center_small[1].y, kRadiusSmall1, 17)
        for i=1, 17 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = -2 * kRadius
            local initY2 = initY1
            savePos[100+i] = {initX1, initY1, initX2, initY2}
        end

        fish_pos = buildCircle(center_small[2].x, center_small[2].y, kRadiusSmall1, 17)
        for i=1, 17 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = -2 * kRadius
            local initY2 = initY1
            savePos[100+17+i] = {initX1, initY1, initX2, initY2}
        end

        fish_pos = buildCircle(center_small[3].x, center_small[3].y, kRadiusSmall1, 30)
        for i=1, 30 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = -2 * kRadius
            local initY2 = initY1
            savePos[100+17+17+i] = {initX1, initY1, initX2, initY2}
        end

        fish_pos = buildCircle(center_small[4].x, center_small[4].y, kRadiusSmall1, 30)
        for i=1, 30 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = -2 * kRadius
            local initY2 = initY1
            savePos[100+17+17+30+i] = {initX1, initY1, initX2, initY2}
        end

        fish_pos = buildCircle(center.x, center.y, kRadiusSmall / 2, 15)
        for i=1, 15 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = -2 * kRadius
            local initY2 = initY1
            savePos[100+17+17+30+30+i] = {initX1, initY1, initX2, initY2}
        end
        savePos[#savePos+1] = { center.x, center.y, -2*kRadius, center.y } --第210个

        self.sceneFishPos[1] = savePos

    end

    local function scene2() --142 - 1618
        self.sceneFishPos[2] = {}
        -- screen_width  = 1799
        -- screen_height = 1366
        --  yl.WIDTH = 1804
        --  yl.HEIGHT = 1040
        local kHScale = screen_width / yl.WIDTH
        local kVScale = screen_height/ yl.HEIGHT
        local kStopExcursion = 180 * kVScale
        local kHExcursion = 27 * kHScale / 2
        local kSmallFishInterval = (screen_width - kHExcursion * 2) / 100
        local kSmallFishHeight = 65 * kVScale
        local kSpeed = 3 * kHScale

        local fish_count = 0
        local small_height = kSmallFishHeight * 3
        local init_x = {}
        local init_y = {}
        local savePos = {}
        for i=1, 200 do 
            init_x[1] = kHExcursion + (i % 100) * kSmallFishInterval
            init_x[2] = init_x[1]
            local excursion = math.random(1, small_height+1)-1
            if i <= 100 then
                init_y[1] = -65 - excursion
                init_y[2] = screen_height + 65
            else
                init_y[1] = screen_height + 65 + excursion
                init_y[2] = - 65
            end
            savePos[i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end
        local big_fish_width = {
            270 * kHScale, 226 * kHScale, 375 * kHScale, 420 * kHScale, 540 * kHScale, 454 * kHScale, 600 * kHScale
        }
        local big_fish_excursion = {}
        for i=1, 7 do 
            big_fish_excursion[i] = big_fish_width[i]
            for j=1, i do 
                big_fish_excursion[i] = big_fish_excursion[i] + big_fish_width[j]
            end
        end

        local y_excursoin = 250 * kVScale / 2
        for i=1, 14 do 
            if i <= 7 then
                init_y[1] = screen_height / 2 - y_excursoin
                init_y[2] = init_y[1]
                init_x[1] = -big_fish_excursion[((i-1)%7)+1]
                init_x[2] = screen_width + big_fish_width[((i-1)%7)+1]
            else
                init_y[1] = screen_height / 2 + y_excursoin
                init_y[2] = init_y[1]
                init_x[1] = screen_width + big_fish_excursion[((i-1)%7)+1]
                init_x[2] = -big_fish_width[((i-1)%7)+1]
            end
            savePos[200+i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end
        self.sceneFishPos[2] = savePos
        ------------------------------等待-------------
        local function wait()
            -- local waitSmallPos = {}
            -- init_x[1] = 0
            -- init_x[2] = 0
            -- init_y[1] = -2 * kSmallFishHeight
            -- init_y[2] = kStopExcursion

            -- waitSmallPos[1] = {init_x[1], init_y[1], init_x[2], init_y[2]}

            -- local waitBigPos = {}
            -- init_y[1] = 0
            -- init_y[2] = 0
            -- init_x[1] = -big_fish_excursion[7]
            -- init_x[2] = screen_width + big_fish_width[7]

            -- waitBigPos[1] = {init_x[1], init_y[1], init_x[2], init_y[2]}
            -- local scene_kind_2_small_fish_stop_index_ = {}

            -- local big_stop_count = 0
            -- for i=1, 200 do 
            --     for j=1, #savePos do 
            --         local pos = savePos[i][j]
            --         if i < 100 then
            --             if pos.y >= kStopExcursion then
            --                 scene_kind_2_small_fish_stop_index_[i] = j
            --                 if big_stop_count == 0 then
            --                     big_stop_count = j
            --                 elseif big_stop_count < j then
            --                     big_stop_count = j
            --                 end
            --                 break
            --             end
            --         else
            --             if pos.y < screen_height - kStopExcursion then
            --                 scene_kind_2_small_fish_stop_index_[i] = j
            --                 if big_stop_count == 0 then 
            --                     big_stop_count = j
            --                 elseif big_stop_count < j then
            --                     big_stop_count = j
            --                 end
            --                 break
            --             end
            --         end
            --     end
            -- end

            -- scene_kind_2_small_fish_stop_index_ = #waitBigPos
        end
    end

    local function scene3()
        self.sceneFishPos[3] = {}
        local savePos = {}
        local kVScale = screen_height / yl.HEIGHT
        local kRadius = (screen_height - (240 * kVScale)) / 2
        local kSpeed  = 1.5 * screen_width / yl.WIDTH
        local center  = cc.p(0,0)
        center.x      = screen_width + kRadius
        center.y      = kRadius + 120 * kVScale
        local fish_pos = nil
        fish_pos = buildCircle(center.x, center.y, kRadius, 50)
        for i=1, 50 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = -2 * kRadius
            local initY2 = initY1
            savePos[i] = {initX1, initY1, initX2, initY2}
        end

        fish_pos = buildCircle(center.x, center.y, kRadius * 40 / 50, 40)
        for i=1, 40 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = -2 * kRadius
            local initY2 = initY1
            savePos[50+i] = {initX1, initY1, initX2, initY2}
        end

        fish_pos = buildCircle(center.x, center.y, kRadius * 30 / 50, 30)
        for i=1, 30 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = -2 * kRadius
            local initY2 = initY1
            savePos[50+40+i] = {initX1, initY1, initX2, initY2}
        end

        savePos[50+40+30+1] = {center.x, center.y, -2*kRadius, center.y}

        center.x = -kRadius

        fish_pos = buildCircle(center.x, center.y, kRadius , 50)
        for i=1, 50 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = screen_width + 2 * kRadius
            local initY2 = initY1
            savePos[50+40+30+1+i] = {initX1, initY1, initX2, initY2}
        end

        fish_pos = buildCircle(center.x, center.y, kRadius * 40 / 50 , 40)
        for i=1, 40 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = screen_width + 2 * kRadius
            local initY2 = initY1
            savePos[50+40+30+1+50+i] = {initX1, initY1, initX2, initY2}
        end

        fish_pos = buildCircle(center.x, center.y, kRadius * 30 / 50 , 30)
        for i=1, 30 do 
            local initX1 = fish_pos[i].x
            local initY1 = fish_pos[i].y
            local initX2 = screen_width + 2 * kRadius
            local initY2 = initY1
            savePos[50+40+30+1+50+40+i] = {initX1, initY1, initX2, initY2}
        end

        savePos[50+40+30+1+50+40+30+1] = {center.x, center.y, screen_width+2*kRadius, center.y}
        self.sceneFishPos[3] = savePos
    end

    local function scene4()
        self.sceneFishPos[4] = {}
        local kHScale = screen_width / yl.WIDTH
        local kVScale = screen_height / yl.HEIGHT
        local kSpeed  = 3 * kHScale
        local kFishWidth = 512 * kHScale
        local kFishHeight= 304 * kVScale
        local savePos = {}
        local init_x = {}
        local init_y = {}
        local start_pos = cc.p(0, screen_height - kFishHeight / 2)
        local target_pos= cc.p(screen_width - kFishHeight/2, 0)

        local dis = cc.pGetDistance( cc.p( target_pos.x, target_pos.y ) , cc.p( start_pos.x, start_pos.y ) )
        local angle = math.acos( (target_pos.x - start_pos.x) / dis)
        local radius = kFishWidth * 4
        local length = radius + kFishWidth / 2
        local center_pos = cc.p(0,0)
        center_pos.x = -length * math.cos(angle)
        center_pos.y = start_pos.y + length * math.sin(angle)
        init_x[2] = target_pos.x + kFishWidth
        init_y[2] = target_pos.y - kFishHeight
        for i=1, 8 do
            if radius < 0 then
                init_x[1] = center_pos.x + radius * math.cos(angle)
                init_y[1] = center_pos.y - radius * math.sin(angle)
            else
                init_x[1] = center_pos.x - radius * math.cos(angle + M_PI)
                init_y[1] = center_pos.y + radius * math.sin(angle + M_PI)
            end
            radius = radius - kFishWidth

            savePos[i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end

        start_pos.x = kFishHeight / 2
        start_pos.y = screen_height
        target_pos.x = screen_width
        target_pos.y = kFishHeight / 2

        dis = cc.pGetDistance( cc.p( target_pos.x, target_pos.y ) , cc.p( start_pos.x, start_pos.y ) )
        angle = math.acos( (target_pos.x - start_pos.x) / dis)
        radius = kFishWidth * 4
        length = radius + kFishWidth / 2
        center_pos.x = start_pos.x - length * math.cos(angle)
        center_pos.y = start_pos.y + length * math.sin(angle)
        init_x[2] = target_pos.x + kFishWidth
        init_y[2] = target_pos.y - kFishHeight
        for i=1, 8 do 
            if radius < 0 then
                init_x[1] = center_pos.x + radius * math.cos(angle)
                init_y[1] = center_pos.y - radius * math.sin(angle)
            else
                init_x[1] = center_pos.x - radius * math.cos(angle + M_PI)
                init_y[1] = center_pos.y + radius * math.sin(angle + M_PI)
            end
            radius = radius - kFishWidth

            savePos[8+i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end

        start_pos.x = screen_width - kFishHeight / 2
        start_pos.y = screen_height
        target_pos.x = 0
        target_pos.y = kFishHeight / 2
        dis = cc.pGetDistance( cc.p( target_pos.x, target_pos.y ) , cc.p( start_pos.x, start_pos.y ) )
        angle = math.acos( (start_pos.x - target_pos.x) / dis)
        radius = kFishWidth * 4
        length = radius + kFishWidth / 2
        center_pos.x = start_pos.x + length * math.cos(angle)
        center_pos.y = start_pos.y + length * math.sin(angle)
        init_x[2] = target_pos.x - kFishWidth
        init_y[2] = target_pos.y - kFishHeight
        for i=1, 8 do 
            if radius < 0 then
                init_x[1] = center_pos.x - radius * math.cos(angle + M_PI)
                init_y[1] = center_pos.y - radius * math.sin(angle + M_PI)
            else
                init_x[1] = center_pos.x - radius * math.cos(angle)
                init_y[1] = center_pos.y - radius * math.sin(angle)
            end
            radius = radius - kFishWidth

            savePos[8+8+i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end

        start_pos.x = screen_width
        start_pos.y = screen_height - kFishHeight / 2
        target_pos.x = kFishHeight / 2
        target_pos.y = 0
        dis = cc.pGetDistance( cc.p( target_pos.x, target_pos.y ) , cc.p( start_pos.x, start_pos.y ) )
        angle = math.acos( (start_pos.x - target_pos.x) / dis)
        radius = kFishWidth * 4
        length = radius + kFishWidth / 2
        center_pos.x = start_pos.x + length * math.cos(angle)
        center_pos.y = start_pos.y + length * math.sin(angle)
        init_x[2] = target_pos.x - kFishWidth
        init_y[2] = target_pos.y - kFishHeight

        for i=1, 8 do 
            if radius < 0 then
                init_x[1] = center_pos.x - radius * math.cos(angle + M_PI)
                init_y[1] = center_pos.y - radius * math.sin(angle + M_PI)
            else
                init_x[1] = center_pos.x - radius * math.cos(angle)
                init_y[1] = center_pos.y - radius * math.sin(angle)
            end
            radius = radius - kFishWidth

            savePos[8+8+8+i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end

        --右上
        start_pos.x = screen_width
        start_pos.y = kFishHeight / 2
        target_pos.x = kFishHeight / 2
        target_pos.y = screen_height
        dis = cc.pGetDistance( cc.p( target_pos.x, target_pos.y ) , cc.p( start_pos.x, start_pos.y ) )
        angle = math.acos( (start_pos.x - target_pos.x) / dis)
        radius = kFishWidth * 4
        length = radius + kFishWidth / 2
        center_pos.x = start_pos.x + length * math.cos(angle)
        center_pos.y = start_pos.y - length * math.sin(angle)
        init_x[2] = target_pos.x - kFishWidth
        init_y[2] = target_pos.y + kFishHeight
        for i=1, 8 do 
            if radius < 0 then
                init_x[1] = center_pos.x - radius * math.cos(-angle + M_PI)
                init_y[1] = center_pos.y - radius * math.sin(-angle + M_PI)
            else
                init_x[1] = center_pos.x - radius * math.cos(-angle)
                init_y[1] = center_pos.y - radius * math.sin(-angle)
            end
            radius = radius - kFishWidth

            savePos[8+8+8+8+i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end

        start_pos.x = screen_width - kFishHeight / 2
        start_pos.y = 0
        target_pos.x = 0
        target_pos.y = screen_height - kFishHeight / 2
        dis = cc.pGetDistance( cc.p( target_pos.x, target_pos.y ) , cc.p( start_pos.x, start_pos.y ) )
        angle = math.acos( (start_pos.x - target_pos.x) / dis)
        radius = kFishWidth * 4
        length = radius + kFishWidth / 2
        center_pos.x = start_pos.x + length * math.cos(angle)
        center_pos.y = start_pos.y - length * math.sin(angle)
        init_x[2] = target_pos.x - kFishWidth
        init_y[2] = target_pos.y + kFishHeight
        for i=1, 8 do 
            if radius < 0 then
                init_x[1] = center_pos.x - radius * math.cos(-angle - M_PI)
                init_y[1] = center_pos.y - radius * math.sin(-angle - M_PI)
            else
                init_x[1] = center_pos.x - radius * math.cos(-angle)
                init_y[1] = center_pos.y - radius * math.sin(-angle)
            end
            radius = radius - kFishWidth

            savePos[8+8+8+8+8+i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end

        --左上
        start_pos.x = kFishHeight / 2
        start_pos.y = 0
        target_pos.x = screen_width
        target_pos.y = screen_height - kFishHeight / 2
        dis = cc.pGetDistance( cc.p( target_pos.x, target_pos.y ) , cc.p( start_pos.x, start_pos.y ) )
        angle = math.acos( (target_pos.x - start_pos.x) / dis)
        radius = kFishWidth * 4
        length = radius + kFishWidth / 2
        center_pos.x = start_pos.x - length * math.cos(angle)
        center_pos.y = start_pos.y - length * math.sin(angle)
        init_x[2] = target_pos.x + kFishWidth
        init_y[2] = target_pos.y + kFishHeight
        for i=1, 8 do 
            if radius < 0 then
                init_x[1] = center_pos.x + radius * math.cos(angle + M_PI)
                init_y[1] = center_pos.y + radius * math.sin(angle + M_PI)
            else
                init_x[1] = center_pos.x + radius * math.cos(angle)
                init_y[1] = center_pos.y + radius * math.sin(angle)
            end
            radius = radius - kFishWidth

            savePos[8+8+8+8+8+8+i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end

        start_pos.x = 0
        start_pos.y = kFishHeight / 2
        target_pos.x = screen_width - kFishHeight / 2
        target_pos.y = screen_height
        dis = cc.pGetDistance( cc.p( target_pos.x, target_pos.y ) , cc.p( start_pos.x, start_pos.y ) )
        angle = math.acos( (target_pos.x - start_pos.x) / dis)
        radius = kFishWidth * 4
        length = radius + kFishWidth / 2
        center_pos.x = start_pos.x - length * math.cos(angle)
        center_pos.y = start_pos.y - length * math.sin(angle)
        init_x[2] = target_pos.x + kFishWidth
        init_y[2] = target_pos.y + kFishHeight
        for i=1, 8 do 
            if radius < 0 then
                init_x[1] = center_pos.x + radius * math.cos(angle + M_PI)
                init_y[1] = center_pos.y + radius * math.sin(angle + M_PI)
            else
                init_x[1] = center_pos.x + radius * math.cos(angle)
                init_y[1] = center_pos.y + radius * math.sin(angle)
            end
            radius = radius - kFishWidth

            savePos[8+8+8+8+8+8+8+i] = {init_x[1], init_y[1], init_x[2], init_y[2]}
        end

        self.sceneFishPos[4] = savePos
    end
   
    local function scene5()
        self.sceneFishPos[5] = {}
        local savePos= {}
        for i=1, 236 do 
            savePos[i] = {}
        end
        local kVScale = screen_height / yl.HEIGHT
        local kRadius = (screen_height - (200 * kVScale)) / 2
        local kRotateSpeed = 1.5 * M_PI / 180
        local kSpeed = 5 * screen_width / yl.WIDTH
        local center = {cc.p(0,0), cc.p(0,0)}
        center[1].x = screen_width / 4
        center[1].y = kRadius + 100 * kVScale
        center[2].x = screen_width - screen_width / 4
        center[2].y = kRadius + 100 * kVScale

        local kLFish1Rotate = 720 * M_PI / 180
        local kRFish2Rotate = (720 + 90) * M_PI / 180
        local kRFish5Rotate = (720 + 180) * M_PI / 180
        local kLFish3Rotate = (720 + 180 + 45) * M_PI / 180
        local kLFish4Rotate = (720 + 180 + 90) * M_PI / 180
        local kRFish6Rotate = (720 + 180 + 90 + 30) * M_PI / 180
        local kRFish7Rotate = (720 + 180 + 90 + 60) * M_PI / 180
        local kLFish6Rotate = (720 + 180 + 90 + 60 + 30) * M_PI / 180
        local kLFish18Rotate = (720 + 180 + 90 + 60 + 60) * M_PI / 180
        local kRFish17Rotate = (720 + 180 + 90 + 60 + 60 + 30) * M_PI / 180
        local fish_pos = nil

        local rotate = 0
        while true do 
            if rotate > kLFish1Rotate then break end
            rotate = rotate + kRotateSpeed
            fish_pos = buildCircle1(center[1].x, center[1].y, kRadius, 40, rotate, kRotateSpeed)
            for i=1, 40 do 
                table.insert(savePos[i], fish_pos[i])
            end
        end
        
        rotate = 0
        while true do 
            if rotate > kRFish2Rotate then break end
            rotate = rotate + kRotateSpeed
            fish_pos = buildCircle1(center[2].x, center[2].y, kRadius, 40, rotate, kRotateSpeed)
            for i=1, 40 do 
                table.insert(savePos[40+i], fish_pos[i])
            end
        end

        rotate = 0
        while true do 
            if rotate > kRFish5Rotate then break end
            rotate = rotate + kRotateSpeed
            fish_pos = buildCircle1(center[2].x, center[2].y, kRadius - 34.5 * kVScale, 40, rotate, kRotateSpeed)
            for i=1, 40 do
                 table.insert(savePos[40+40+i], fish_pos[i])
            end
        end

        rotate = 0
        while true do 
            if rotate > kLFish3Rotate then break end
            rotate = rotate + kRotateSpeed
            fish_pos = buildCircle1(center[1].x, center[1].y, kRadius - 36 * kVScale, 40, rotate, kRotateSpeed)
            for i=1, 40 do
                table.insert(savePos[40+40+40+i], fish_pos[i])
            end
        end

        rotate = 0
        while true do 
            if rotate > kLFish4Rotate then break end
            rotate = rotate + kRotateSpeed
            fish_pos = buildCircle1(center[1].x, center[1].y, kRadius - 36 * kVScale - 56 * kVScale, 24, rotate, kRotateSpeed)
            for i=1, 24 do
                 table.insert(savePos[40+40+40+40+i], fish_pos[i])
            end
        end

        rotate = 0
        while true do 
            if rotate > kRFish6Rotate then break end
            rotate = rotate + kRotateSpeed
            fish_pos = buildCircle1(center[2].x, center[2].y, kRadius - 34.5 * kVScale - 58.5 * kVScale, 24, rotate, kRotateSpeed)
            for i=1, 24 do
                table.insert(savePos[40+40+40+40+24+i], fish_pos[i])
            end
        end

        rotate = 0
        while true do 
            if rotate > kRFish7Rotate then break end --翻肚子的鱼
            rotate = rotate + kRotateSpeed
            fish_pos = buildCircle1(center[2].x, center[2].y, kRadius - 34.5 * kVScale - 58.5 * kVScale - 65 * kVScale, 13, rotate, kRotateSpeed)
            for i=1, 13 do
                table.insert(savePos[40+40+40+40+24+24+i], fish_pos[i])
            end
        end

        rotate = 0
        while true do 
            if rotate > kLFish6Rotate then break end
            rotate = rotate + kRotateSpeed
            fish_pos = buildCircle1(center[1].x, center[1].y, kRadius - 36 * kVScale - 56 * kVScale - 68 * kVScale, 13, rotate, kRotateSpeed)
            for i=1, 13 do
                table.insert(savePos[40+40+40+40+24+24+13+i], fish_pos[i])
            end
        end

        rotate = 0
        while true do
            if rotate > kLFish18Rotate then break end --鲸鱼
            rotate = rotate + kRotateSpeed
            local p = {x = center[1].x, y = center[1].y, angle = -M_PI_2 + rotate}
            table.insert(savePos[40+40+40+40+24+24+13+13+1], p)
        end

        rotate = 0
        while true do
            if rotate > kRFish17Rotate then break end --小金沙
            rotate = rotate + kRotateSpeed
            local p = {x = center[2].x, y = center[2].y, angle = -M_PI_2 + rotate}
            table.insert(savePos[40+40+40+40+24+24+13+13+1+1], p)
        end
        local init_x = {}
        local init_y = {}
        
        for i=1, #savePos do
            local pos = savePos[i][#savePos[i]]
            init_x[1] = pos.x
            init_y[1] = pos.y
            init_x[2], init_y[2] = getTargetPoint(screen_width, screen_height, pos.x, pos.y, pos.angle)

            local goPos = buildLinear(init_x, init_y, 2, kSpeed)
            goPos[1].angle = pos.angle
            goPos[2].angle = pos.angle

            for k,v in ipairs(goPos) do
                table.insert(savePos[i], v)
            end
        end

        self.sceneFishPos[5] = savePos
        -- error("zz")
    end
    scene1()--210
    scene2()--214
    scene3()--242
    scene4()--64
    scene5()--236 
    --scene5:kind =  1-40 = 0, 41-80 = 1, 81-120 = 4, 121-160 = 2, 161-184 = 3, 
    --185-208 = 5, 209-221 = 6, 222-234=5, 235 = 17, 236 = 16,
end
--切换场景
function GameLayer:onSubExchangeScene( dataBuffer )

    self._dataModel:playEffect(g_var(cmd).Change_Scene)
    local systime = currentTime()
    self._dataModel.m_enterTime = systime

    self._dataModel._exchangeSceneing = true
    self._dataModel.m_bulletCount    = 0
    self:playBackGround()
    local cmddata = ExternalFun.create_netdata(g_var(cmd).SwitchScene)
    local exchangeScene = ExternalFun.read_netdata(g_var(cmd).SwitchScene, dataBuffer)
    -- --dump( exchangeScene, "场景切换--->>>>>" )
    local speed = nil
    local _type = 0
    local traceType = 0
    if exchangeScene.scene_ == 0 then
        speed = 1.5 * cc.Director:getInstance():getVisibleSize().width / yl.WIDTH
        _type = 1
    elseif exchangeScene.scene_ == 1 then
        speed = 3 * cc.Director:getInstance():getVisibleSize().width / yl.WIDTH
        _type = 2
        traceType = 3
    elseif exchangeScene.scene_ == 2 then
        speed = 1.5 * cc.Director:getInstance():getVisibleSize().width / yl.WIDTH
        _type = 3
    elseif exchangeScene.scene_ == 3 then
        speed = 3 * cc.Director:getInstance():getVisibleSize().width / yl.WIDTH
        _type = 4
    elseif exchangeScene.scene_ == 4 then
        speed = 5 * cc.Director:getInstance():getVisibleSize().width / yl.WIDTH
        _type = 5
        traceType = 2
    end

    local aniName = "waveAnim"
    local ani = cc.AnimationCache:getInstance():getAnimation(aniName)
    if ani == nil then
        print("空  导致不能开炮")
    end
    if ani ~= nil then
        local action = cc.RepeatForever:create(cc.Animate:create(ani))
        local move   = cc.MoveTo:create(4, cc.p(-100, 0))

        local wave = cc.Sprite:create()
        self:addChild(wave)
        wave:setAnchorPoint(cc.p(0 , 0))
        wave:setPosition(yl.WIDTH, 0)
        self.changeSceneTimes = exchangeScene.scene_ % 3 + 1
        --print("exchangeScene.scene_kind------------------",exchangeScene.scene_kind,self.changeSceneTimes)
        
        local oldZorder = 1
        local call = cc.CallFunc:create(function(  )
            self._dataModel._exchangeSceneing = false
            self:playBackGround(1)
            local fishdata = nil
            for k,v in pairs(self._dataModel.m_fishList) do 
                self._dataModel.m_fishList[k] = nil
            end
            self.m_fishLayer:removeFromParent()
            self.m_fishLayer = cc.Layer:create()
            self._gameView:addChild(self.m_fishLayer, 5)

            -- by zzy 
            --鱼潮不用这个 换换
            if 1 then 
                return
            end

            local yy = 180 * cc.Director:getInstance():getVisibleSize().height / yl.HEIGHT
            for i=1, exchangeScene.fish_count do
                if traceType == 2 then --最后一个转圈鱼潮特殊处理
                    fishdata =
                    {
                        init_count = 2,
                        fish_kind = exchangeScene.fish_kind[1][i],
                        fish_id   = exchangeScene.fish_id[1][i],
                        trace_type = traceType,
                        sceneSpeed = speed,
                        init_pos = self.sceneFishPos[_type][i]
                    }
                elseif traceType == 3 then --第二个上下的鱼潮 142 - 1618
                    local _waitY = 0
                    local _waitTime = math.floor(1618/33)
                    if i <= 100 then
                        _waitY = cc.Director:getInstance():getVisibleSize().height - yy
                    elseif i <= 200 then
                        _waitY = yy
                    else
                        _waitTime = 0
                        -- _waitTime = math.floor(142/33)--142
                    end

                    fishdata =
                    {
                        init_count = 2,
                        fish_kind = exchangeScene.fish_kind[1][i],
                        fish_id   = exchangeScene.fish_id[1][i],
                        trace_type = traceType,
                        sceneSpeed = speed,
                        waitY = _waitY,
                        waitTime = _waitTime,
                        init_pos = 
                        {
                            {
                                {x = self.sceneFishPos[_type][i][1], y = self.sceneFishPos[_type][i][2]},
                                {x = self.sceneFishPos[_type][i][3], y = self.sceneFishPos[_type][i][4]},
                            }
                            
                        }
                    }
                else --普通鱼潮
                    fishdata =
                    {
                        init_count = 2,
                        fish_kind = exchangeScene.fish_kind[1][i],
                        fish_id   = exchangeScene.fish_id[1][i],
                        trace_type = traceType,
                        sceneSpeed = speed,
                        init_pos = 
                        {
                            {
                                {x = self.sceneFishPos[_type][i][1], y = self.sceneFishPos[_type][i][2]},
                                {x = self.sceneFishPos[_type][i][3], y = self.sceneFishPos[_type][i][4]},
                            }
                            
                        }
                    }
                end
                local fish = g_var(Fish):create(fishdata,self)
                fish:initAnim()
                fish:setTag(g_var(cmd).Tag_Fish)
                fish:initPhysicsBody()
                self.m_fishLayer:addChild(fish, fish.m_data.fish_kind + 1) --鱼种类越高 层级越高
                self._dataModel.m_fishList[fish.m_data.fish_id] = fish
            end
        end)
        
     
        local bgfile = string.format("Scene/bg%d.jpg", self.changeSceneTimes)
        local _bg = cc.Sprite:create(bgfile)
        _bg:setAnchorPoint(cc.p(0, 0))
        _bg:setPosition(yl.WIDTH+100, 0)
        _bg:setTag(200)
        self._gameView:addChild(_bg, 5)
        local water = self._gameView:createWater()
        _bg:addChild(water)
        _bg:runAction(cc.Sequence:create(cc.MoveTo:create(4, cc.p(0, 0)), call) )



        wave:runAction(action)
        local _call = cc.CallFunc:create(function()
            self._dataModel._exchangeSceneing = false
            wave:removeFromParent()
        end)
        wave:runAction( cc.Sequence:create(move, _call))
    end
end
--获取玩家列表
function GameLayer:getUserList()
    return self._gameFrame._UserList
end

function GameLayer:addEvent()

   --通知监听
    local function eventListener(event)
        --print("收到加载完成通知 播放音乐")
        --初始化界面
        self._gameView:initView(self.changeSceneTimes)

        --添加炮台层
        -- self.m_cannonLayer = g_var(CannonLayer):create(self)
        -- self._gameView:addChild(self.m_cannonLayer, 6)
        self.m_cannonLayer:init()

        --全都初始化完了 上分 总可以了吧
        self:upupupScore()

        --查询本桌其他用户
        self._gameFrame:QueryUserInfo( self.m_nTableID,yl.INVALID_CHAIR)
         --self:checkOtherPlayer()
        --播放背景音乐
        if  GlobalUserItem.bSoundAble then
            AudioEngine.playMusic(cc.FileUtils:getInstance():fullPathForFilename(g_var(cmd).bgm1),true)
        end
        
        if not GlobalUserItem.bVoiceAble then
            AudioEngine.setMusicVolume(0)
            AudioEngine.pauseMusic() -- 暂停音乐
        end

    end
    --print("添加监听-------------")
    local listener = cc.EventListenerCustom:create(g_var(cmd).Event_LoadingFinish, eventListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function GameLayer:upupupScore()
    --是否是游戏中进来的 发送上分失败 再场景消息接受值

    self.m_cannonLayer:addBulletCount(self.m_nChairID, self.GameingScore)
    self.m_cannonLayer:setFishGold(self.m_nChairID+1, self.GameingScore)
    self._gameView:setCurGold(self.GameingScore)
    self.GameingScore =0
    
    --print("发送上分喽")
    local cmddata = ExternalFun.create_netdata(g_var(cmd).C_ExchangeFishScore)
    cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_BUY_BULLET)
    if self.cash_ratio == nil then
        self.cash_ratio = 1
    end
    cmddata:pushscore(GlobalUserItem.lUserScore * self.cash_ratio)
    self:sendNetData(cmddata)
end

--判断自己位置 是否需翻转
function GameLayer:setReversal( )
   
  if self.m_pUserItem then
    if self.m_pUserItem.wChairID < 3 then
        self._dataModel.m_reversal = true
    end
  end

  return self._dataModel.m_reversal
end

--添加碰撞
function GameLayer:addContact()

    local function onContactBegin(contact)
    
        local a = contact:getShapeA():getBody():getNode()
        local b = contact:getShapeB():getBody():getNode()
       
        local bullet = nil
        local fish = nil
        if a and b then
            if a:getTag() == g_var(cmd).Tag_Bullet then
                bullet = a
                fish = b
            end

            if b:getTag() == g_var(cmd).Tag_Bullet then
                bullet = b
                fish = a
            end

        end
        if nil ~= bullet then
            bullet:fallingNet(fish)
            bullet:removeFromParent()
        end

        return true
    end

    local dispatcher = self:getEventDispatcher()
    self.contactListener = cc.EventListenerPhysicsContact:create()
    self.contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    dispatcher:addEventListenerWithSceneGraphPriority(self.contactListener, self)

end

--60开炮倒计时
function GameLayer:setSecondCount(dt)
     self.m_nSecondCount = dt

     if dt == 120 then
       local tipBG = self._gameView:getChildByTag(10000)
       if nil ~= tipBG then
          tipBG:removeFromParent()
       end
     end
end

function GameLayer:createSecoundSchedule() 

    local function setSecondTips() --提示
        if nil == self._gameView:getChildByTag(10000) then 
            local tipBG = cc.Sprite:create("maintain/time_out.png")
            tipBG:setAnchorPoint(cc.p(0, 0))
            tipBG:setPosition(100, 375)
            tipBG:setTag(10000)
            self._gameView:addChild(tipBG,100)


            -- local watch = cc.Sprite:createWithSpriteFrameName("watch_0.png")
            -- watch:setPosition(60, 45)
            -- tipBG:addChild(watch)

            -- local animation = cc.AnimationCache:getInstance():getAnimation("watchAnim")
            -- if nil ~= animation then
            --     watch:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
            -- end

            local buttomTip = cc.Label:createWithTTF("60", "fonts/round_body.ttf", 28)
            buttomTip:setAnchorPoint(0.5, 0.5)
            buttomTip:setTextColor(cc.RED)
            buttomTip:setPosition(730, 22)
            buttomTip:setTag(22)
            tipBG:addChild(buttomTip)
        else
            local tipBG = self._gameView:getChildByTag(10000)
            local time = tipBG:getChildByTag(22)
            time:setString(string.format("%d",self.m_nSecondCount))      
        end
    end

    local function removeTip()
        local tipBG = self._gameView:getChildByTag(10000)
        if nil ~= tipBG then
            tipBG:removeFromParent()
        end
    end


    local function update(dt)
        -- --print("self.m_nSecondCount ",self.m_nSecondCount)
        if self.m_nSecondCount == 0 then --发送起立
            removeTip()
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(delayLeaveTime),
                cc.CallFunc:create(
                    function () 
                        self._gameView:StopLoading(false)
                        self._gameFrame:StandUp(1)
                    end
                ),
            cc.DelayTime:create(exit_timeOut),
            cc.CallFunc:create(
                function ()
                    --强制离开游戏(针对长时间收不到服务器消息的情况)
                    -- --print("delay leave")
                    self:onExitRoom()
                end
                ))
            )
            return
        end

        if self.m_nSecondCount - 1 >= 0 then 
            self.m_nSecondCount = self.m_nSecondCount - 1
        end

        if self.m_nSecondCount <= 60 then
            setSecondTips()
        end
    end

    if nil == self.m_secondCountSchedule then
        self.m_secondCountSchedule = scheduler:scheduleScriptFunc(update, 1.0, false)
    end
end

function GameLayer:unSchedule( )

    --游戏定时器
	if nil ~= self.m_scheduleUpdate then
		scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
		self.m_scheduleUpdate = nil
	end

    --60秒倒计时定时器
    if nil ~= self.m_secondCountSchedule then 
        scheduler:unscheduleScriptEntry(self.m_secondCountSchedule)
        self.m_secondCountSchedule = nil
    end
    if self.m_cannonLayer ~= nil then
        for i=1, 8 do
            if self.m_cannonLayer:getCannon(i) ~= nil then
                self.m_cannonLayer:getCannon(i):unDelLockEntry()
            end
        end
    end
    if nil~=self.timeTimer then
        scheduler:unscheduleScriptEntry(self.timeTimer)
		self.timeTimer = nil
    end
    
end

function GameLayer:onEnter( )
	--print("onEnter of gameLayer")
end

function GameLayer:onEnterTransitionFinish(  )
 
    --print("onEnterTransitionFinish of gameLayer")
    if  GlobalUserItem.bSoundAble then
        AudioEngine.playMusic(g_var(cmd).bgm1,true)
    end

    --碰撞监听
    self:addContact()

end

function GameLayer:onExit()

    --print("gameLayer onExit()....")

    --移除碰撞监听
    cc.Director:getInstance():getEventDispatcher():removeEventListener(self.contactListener)

    cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(g_var(cmd).Event_LoadingFinish)
 
    --释放游戏所有定时器
    self:unSchedule()
    --cc.Director:getInstance():getRunningScene():destryPhysicWorld()
end


--触摸事件
function GameLayer:onTouchBegan(touch, event)
	return true
end

function GameLayer:onTouchMoved(touch, event)

end

function GameLayer:onTouchEnded(touch, event )

end
--检测进来的时候有没有其他玩家
function GameLayer:checkOtherPlayer()
    local players = self:getUserList()
    for k, v in pairs(players) do
        if v.wTableID == self.m_nTableID then--同一桌的
            if v.wChairID ~= self.m_nChairID then--其他玩家
                self:onEventUserEnter(v.wTableID, v.wChairID, v)
            end
        end
    end
end
--用户进入
function GameLayer:onEventUserEnter( wTableID,wChairID,useritem )
    print("用户进入数据 " ,wTableID,wChairID,useritem)
     
    print("GameLayer onevnetuser Enter1 ")
    -- error("sss")
    if wTableID ~= self.m_nTableID or  useritem.cbUserStatus == yl.US_LOOKON or not self.m_cannonLayer then
        --print("return ===== onEventUserEnter")
        return
    end
    print("GameLayer onevnetuser Enter2 ")
    self.m_cannonLayer:onEventUserEnter( wTableID,wChairID,useritem )

    self:setUserMultiple()
end

--用户状态
function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
    --print("用户状态数据 ",useritem,newstatus,oldstatus)
    if  useritem.cbUserStatus == yl.US_LOOKON or not self.m_cannonLayer then
        return
    end
    --查询本桌其他用户
    -- self._gameFrame:QueryUserInfo( self.m_nTableID,yl.INVALID_CHAIR)
    self.m_cannonLayer:onEventUserStatus(useritem,newstatus,oldstatus)

    -- self:setUserMultiple()

end

--用户分数
function GameLayer:onEventUserScore( item )
    --print("lkpy onEventUserScore...")
end

--显示等待
function GameLayer:showPopWait()
    if self._scene and self._scene.showPopWait then
        self._scene:showPopWait()
    end
end

--关闭等待
function GameLayer:dismissPopWait()
  --print("关闭等待")
    if self._scene and self._scene.dismissPopWait then
      --print("呵呵")
        self._scene:dismissPopWait()
    end
end

-- 初始化游戏数据
function GameLayer:onInitData()

end


-- 重置游戏数据
function GameLayer:onResetData()
    -- body
end

function GameLayer:setUserMultiple()
    --print("设置user复杂数据",self.m_cannonLayer)
    -- error("dd")
    if not self.m_cannonLayer then
        return
    end

  --设置炮台倍数
    for i=1,6 do
        local cannon = self.m_cannonLayer:getCannoByPos(i)
        local pos = i
        if nil ~= cannon then
            local fishGold = self.m_cannonLayer:getBulletsCount(i-1)
            self.m_cannonLayer:setFishGold(i, fishGold)
        end
    end
end

-- 场景信息数据处理
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)

   
    local rel_scene  = ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusFree, dataBuffer)
    local rolobj    = rel_scene.role_objects_
    --dump(rel_scene)
    --dump(rel_scene.role_objects_)
 
    self:send_time_check(true)

    --print("场景数据 lkpy",self.m_bScene)

    --new gameScene
    if self.m_bScene then
        self:dismissPopWait()
        return
    end
    self.m_bScene = true
  	local systime = currentTime()
    self._dataModel.m_enterTime = systime

    self._dataModel.m_secene = rel_scene--ExternalFun.read_netdata(g_var(cmd).GameStatus, dataBuffer)

    --游戏配置 转移到场景


    local wscale = g_var(cmd).WSCALE
    for i=1,6 do
        self.bullet_speed_[i] =18
        self.net_radius_[i] = rel_scene.bullet_config_[1][i].bounding_radius
    end
    self._dataModel.m_gameConfig.bullet_speed = self.bullet_speed_

    self:checkOtherPlayer()

    for i=1, 6 do
        self.m_cannonLayer:initFishScoreAndBulletCount( i-1,  (rolobj[1][i].cannon_mulriple_),   (rolobj[1][i].catch_gold_)   )
        self.m_cannonLayer:setFishGold(i , rolobj[1][i].catch_gold_)
        if i-1 == self.m_nChairID then
            self.GameingScore = rolobj[1][i].catch_gold_
        end
    end

    self.changeSceneTimes = 7 % 3 + 1
    self.exchange_fish_score_ = {}
    for i=1, 6 do
        -- --print("self._dataModel.m_secene.fish_score[i+1]  ",self._dataModel.m_secene.fish_score[1][1])
        self.m_cannonLayer:setFishScore(i, rolobj[1][i].catch_gold_)
        self.exchange_fish_score_[i] = rolobj[1][i].catch_gold_
    end
    self.allow_fire = true --是否可以开火


    self.timeTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
						
        self:send_time_check(false)
    end, 3, false)

    self.cash_ratio = rel_scene.ex_ratio_birdscore_ / rel_scene.ex_ratio_userscore_
    --添加用户
    -- for i=1,6 do
    --     if rolobj[1][i].chair_id_ ~= 65535 then
    --         self.m_cannonLayer:initUserInfo(rolobj[1][i].chair_id_+1,nil)
    --      end
    -- end
    --self.m_cannonLayer:onEventUserEnter(self.m_nTableID,)


--     if self.m_bScene then
--         self:dismissPopWait()
--         return
--     end
--     self.m_bScene = true
--   	local systime = currentTime()
--     self._dataModel.m_enterTime = systime

--     self._dataModel.m_secene = ExternalFun.read_netdata(g_var(cmd).GameStatus, dataBuffer)

--    --local cmddata = ExternalFun.create_netdata(g_var(cmd).GameStatus)
--      ----print("场景包长度  ",dataBuffer:getlen())
--    -- --dump(cmddata)
--     -- --dump(self._dataModel.m_secene, "场景数据咯 ================ > ")
--     -- error("ssssss")
--     self.changeSceneTimes = self._dataModel.m_secene.sceneID % 3 + 1
--     self.exchange_fish_score_ = {}
--     for i=1, g_var(cmd).GAME_PLAYER do
--         -- --print("self._dataModel.m_secene.fish_score[i+1]  ",self._dataModel.m_secene.fish_score[1][1])
--         self.m_cannonLayer:setFishScore(i, self._dataModel.m_secene.fish_score[1][i])
--         self.exchange_fish_score_[i] = self._dataModel.m_secene.exchange_fish_score[1][i]
--     end
--     self.allow_fire = true --是否可以开火

        self:onSubGameConfig(nil)
end

function GameLayer:send_time_check(is_game_status)
    
    local cmddata = ExternalFun.create_netdata(g_var(cmd).CMD_C_TimeCheck)
    cmddata:setcmdinfo(yl.MDM_GF_GAME, 204)
    cmddata:pushword(self.m_nChairID)
    cmddata:pushint(TimestampManager:getTimeCheck())
    cmddata:pushbool(is_game_status)
    print("发送校验")
    print(TimestampManager:getTimeCheck())
    self:sendNetData(cmddata)

end

function GameLayer:getKindNum(beishu)
    local kind = 2 --默认两个炮管
    if beishu >= 1000 and beishu < 5000 then 
        kind = 3 --三个炮管
    elseif beishu >= 5000 then
        kind = 4 --四个炮管
    end
    kind = kind - 1

    return kind
end
--游戏设置消息处理
function GameLayer:onSubGameConfig(data)
    dump(data,"游戏设置消息处理------------------------>>")
    -- error("ff")

    --炮弹的一些设置 好笑也没用
    -- new gameconfig by zzy
    local current_bullet_mulriple_ = 1000
    self.min_bullet_multiple_      = 1000--current_bullet_mulriple_
    self.max_bullet_multiple_      = 9900--data.max_bullet_multiple
    self.bomb_range_width          = 50--data.bomb_range_width
    self.bomb_range_height         = 50--data.bomb_range_height
    
  
    local current_bullet_kind_ = self:getKindNum(current_bullet_mulriple_)
    self._dataModel.m_secene.nBulletCoolingTime = 240
    --1677 hang
    -- self.m_cannonLayer:setMyStation(self.byMyStation)
   
    local wscale = g_var(cmd).WSCALE

    for i=0, g_var(cmd).GAME_PLAYER-1 do
        self.m_cannonLayer:switch(i, current_bullet_kind_)
        self.m_cannonLayer:setCannonMulriple(i, current_bullet_mulriple_)
    end

    self.fish_multiple_ = {2,2,3,4,5,6,7,  8,9,10,12,15,18,20,  25,30,35,40,120,320,40 ,1,1,1,1,1,1}

    self.fish_bounding_box_width_={ 15,18,36,42,33, 54,37,52,56,52,   71,48,112,45,69,     187,112,112,131,157, 225,97,266,202,146,  86,180,180,180,97,             150,150,150,150,150, 150,150,150,150,150};		--鱼边界框的宽度
	self.fish_bounding_box_height_={48,40,58,72,93, 78,86,97,112,120, 101,112,105,157,209, 165,270,270,367,315, 217,322,352,345,247, 97,195,195,195,135,     150,150,150,150,150, 150,150,150,150,150};

    -- self.fish_bounding_box_width_={55,60,80,70,80, 90,90,120,150,110, 145,120,180,230,180, 260,280,290,340,340, 200,180,140,130,340, 340,340,460,460,460, 150,150,150,150,150, 150,150,150,150,150};		--鱼边界框的宽度
	-- self.fish_bounding_box_height_={15,25,32,43,54, 70,40,55,47,112,    80,150,70,88,160,   80, 90,140,100,70,  240,100,140,130,130,130,130,130,130,130,150,150,150,150,150,150,150,150,150,150};
    for i=1, g_var(cmd).FishKind.FISH_KIND_COUNT do
        --self.fish_multiple_[i] = 1--data.fish_multiple[1][i]
        self.fish_speed_[i] = 2--data.fish_speed[1][i]
       
        self.fish_hit_radius_[i] = 10--data.fish_hit_radius[1][i] * wscale
    end
    -- --dump(data.gamestatus, "data.gamestatus->>>")
   
    self.allow_fire = true

    self.isSuper = true
    self.user_config_info_ = {}
    self.user_config_info_["show_help_tip"] = true--data.show_help_tip
    self.user_config_info_["show_task_tip"] = true--data.show_task_tip


       
    self._dataModel.m_gameConfig.max_bullet_multiple = self.max_bullet_multiple_ 
    self._dataModel.m_gameConfig.min_bullet_multiple_ = self.min_bullet_multiple_ 
    self._dataModel.m_gameConfig.bomb_range_width = self.bomb_range_width 
    self._dataModel.m_gameConfig.bomb_range_height = self.bomb_range_height
    self._dataModel.m_gameConfig.FireInterval = self._dataModel.m_secene.nBulletCoolingTime 
   

    --鱼的设置 没什么用 
    local temp1 = {}
    local temp2 = {}
    local temp3 = {}
    local temp4 = {}
    local temp5 = {}

    for i=1,g_var(cmd).FishKind.FISH_KIND_COUNT do
        temp1[i] = 1
        temp2[i] = 2
        temp3[i] = 20
        temp4[i] = 20
        temp5[i] = 10
    end

        self._dataModel.m_gameConfig.fish_multiple = temp1
        self._dataModel.m_gameConfig.fish_speed_= temp2
        self._dataModel.m_gameConfig.fish_bounding_box_width = temp3
        self._dataModel.m_gameConfig.fish_bounding_box_height = temp4
        self._dataModel.m_gameConfig.fish_hit_radius = temp5

    self._dataModel.m_gameConfig.show_help_tip = self.user_config_info_["show_help_tip"]
    self._dataModel.m_gameConfig.show_task_tip = self.user_config_info_["show_task_tip"]

    -- local wscale = g_var(cmd).WSCALE
    -- local temp6 = {}
    -- for i=1, g_var(cmd).BulletKind.BULLET_KIND_COUNT do
    --     temp6[i] = 10* wscale
    --     self.bullet_speed_[i] = 2  * wscale
    -- end
    -- self._dataModel.m_gameConfig.bullet_speed = temp6

    --dump(self._dataModel.m_gameConfig)

    -- local current_bullet_mulriple_ = data.min_bullet_multiple
    -- self.min_bullet_multiple_      = current_bullet_mulriple_
    -- self.max_bullet_multiple_      = data.max_bullet_multiple
    -- self.bomb_range_width          = data.bomb_range_width
    -- self.bomb_range_height         = data.bomb_range_height
    -- self.exchange_ratio_userscore_ = data.exchange_ratio_userscore
    -- self.exchange_ratio_fishscore_ = data.exchange_ratio_fishscore
    -- -- --print("bomb = ",self.bomb_range_width, self.bomb_range_height)
    -- --设置默认子弹类型
    -- -- if current_bullet_mulriple_ < 100 then
    -- --     self.current_bullet_kind_ = (self.current_bullet_kind_ / 4) * 4 --默认是2
    -- -- elseif current_bullet_mulriple_ >= 100 and current_bullet_mulriple_ < 1000 then
    -- --     self.current_bullet_kind_ = (self.current_bullet_kind_ / 4) * 4 + 1
    -- -- elseif current_bullet_mulriple_ >= 1000 and current_bullet_mulriple_ < 5000 then
    -- --     self.current_bullet_kind_ = (self.current_bullet_kind_ / 4) * 4 + 2
    -- -- else
    -- --     self.current_bullet_kind_ = (self.current_bullet_kind_ / 4) * 4 + 3
    -- -- end
    -- local current_bullet_kind_ = self:getKindNum(current_bullet_mulriple_)
    -- self._dataModel.m_secene.nBulletCoolingTime = data.FireInterval
    -- --1677 hang
    -- -- self.m_cannonLayer:setMyStation(self.byMyStation)
    -- local screen_width = cc.Director:getInstance():getVisibleSize().width
    -- -- --print("screen_width ",screen_width)
     --local wscale = g_var(cmd).WSCALE

    -- for i=0, g_var(cmd).GAME_PLAYER-1 do
    --     self.m_cannonLayer:switch(i, current_bullet_kind_)
    --     self.m_cannonLayer:setCannonMulriple(i, current_bullet_mulriple_)
    -- end

    -- for i=1, g_var(cmd).FishKind.FISH_KIND_COUNT do
    --     self.fish_multiple_[i] = data.fish_multiple[1][i]
    --     self.fish_speed_[i] = data.fish_speed[1][i]
    --     self.fish_bounding_box_width_[i] = data.fish_bounding_box_width[1][i] * wscale
    --     self.fish_bounding_box_height_[i] = data.fish_bounding_box_height[1][i] * wscale
    --     self.fish_hit_radius_[i] = data.fish_hit_radius[1][i] * wscale
    -- end

    self.fish18_max_multiple_ = 120
    self.fish19_max_multiple_ = 500
    self.fishLK_max_multiple_ = 300

    -- self.fish18_max_multiple_ = data.fish18_max_multiple
    -- self.fish19_max_multiple_ = data.fish19_max_multiple
    -- self.fishLK_max_multiple_ = data.fishLK_max_multiple

    --for i=1, g_var(cmd).BulletKind.BULLET_KIND_COUNT do
     --   self.bullet_speed_[i] = data.bullet_speed[1][i]  * wscale
        --self.net_radius_[i] = data.net_radius[1][i] * wscale
    --end
    -- -- --dump(data.gamestatus, "data.gamestatus->>>")
    -- for i=1, g_var(cmd).GAME_PLAYER do
    --     -- --print("initFishScoreAndBulletCount ",(data.gamestatus.bullet_count[1][1]), (data.gamestatus.fish_score[1][1]))
    --     self.m_cannonLayer:initFishScoreAndBulletCount( i-1,  (data.gamestatus.bullet_count[1][i]),   (data.gamestatus.fish_score[1][i])   )
    --     -- self.m_cannonLayer:setFishGold(data.gamestatus.bullet_count[1][i])
    -- end

    -- self.allow_fire = true
    -- --fish_manager:set_MyStation(self.byMyStation)

    -- self.bullet_price = data.gamestatus.bullet_price
    -- -- --dump(bullet_price,"  测试---------------->>>>>")

    -- self.isSuper = data.bIsSuper
    -- self.user_config_info_ = {}
    -- self.user_config_info_["show_help_tip"] = data.show_help_tip
    -- self.user_config_info_["show_task_tip"] = data.show_task_tip


    -- 
end

--用户上分消息
function GameLayer:onSubExchangeFishScore(data)
    -- local cmddata = ExternalFun.create_netdata(g_var(cmd).ExchangeFishScore)
    -- --print("-------------",data:getlen())
    self._dataModel.userScore = ExternalFun.read_netdata(g_var(cmd).ExchangeFishScore, data)
    print("用户上分数据---------------->>>>>>>")
    dump(self._dataModel.userScore)

    self.m_cannonLayer:addBulletCount(self._dataModel.userScore.chair_id_, self._dataModel.userScore.count_)
    self.m_cannonLayer:setFishGold(self._dataModel.userScore.chair_id_+1, self._dataModel.userScore.count_)
    -- self.exchange_fish_score_[self._dataModel.userScore.chair_id+1] = self._dataModel.userScore.exchange_fish_score
    --self.m_cannonLayer:setFishGold(self._dataModel.userScore.chair_id+1, self._dataModel.userScore.bullet_count[1][self._dataModel.userScore.chair_id+1])
    if self._dataModel.userScore.chair_id_ == self.m_nChairID then
        self._gameView:setCurGold(self._dataModel.userScore.count_)
    end
end

--用户下分消息
function GameLayer:onSubFishScoreTobullets(data)
    -- local cmddata = ExternalFun.create_netdata(g_var(cmd).FishScoreToBullet)
    local scoreData = ExternalFun.read_netdata(g_var(cmd).FishScoreToBullet, data)
    -- --print("接收包长度 ",data:getlen())
    -- --dump(scoreData, "用户下分数据---------------->>>>>>>")

    -- self.exchange_fish_score_[scoreData.chair_id+1] = self.exchange_fish_score_[scoreData.chair_id+1] - self.m_cannonLayer:getBulletsCount(scoreData.chair_id)
    
    self.m_cannonLayer:changeFishScoreToBullets(scoreData.chair_id, scoreData.bullet_count[1][scoreData.chair_id+1], scoreData.fish_score)

    -- for i=1, 8 do
        self.m_cannonLayer:setFishGold(scoreData.chair_id+1, scoreData.bullet_count[1][scoreData.chair_id+1])
    -- end
    if scoreData.chair_id == self.m_nChairID then
        self._gameView:setCurGold( scoreData.UserScore )
    end
end

--开火
function GameLayer:onSubUserFire(databuffer)
    table.insert(self._dataModel.m_fireData, databuffer:retain())
end
--播放背景音乐
function GameLayer:playBackGround(_type)
    if  GlobalUserItem.bSoundAble then
        if _type == nil then
            self._dataModel:playEffect(g_var(cmd).wave)
        else
            self.musicCount = self.musicCount + 1
            if self.musicCount > 4 then self.musicCount = 1 end
            
            if self.musicCount == 1 then
                AudioEngine.playMusic(g_var(cmd).bgm2,true)
            elseif self.musicCount == 2 then
                AudioEngine.playMusic(g_var(cmd).bgm3,true)
            elseif self.musicCount == 3 then
                AudioEngine.playMusic(g_var(cmd).bgm4,true)
            else
                AudioEngine.playMusic(g_var(cmd).bgm1,true)
            end
        end
    end
end

--李逵分数变更
function GameLayer:onSubLkMultiple(dataBuffer)
    local cmddata = ExternalFun.create_netdata(g_var(cmd).HitFishLK)
    local data = ExternalFun.read_netdata(g_var(cmd).HitFishLK, dataBuffer)
    -- --dump(data,"李逵分数-->>>")
    local lkfish = self._dataModel.m_fishList[data.fish_id]
    -- --print("lkfish ",lkfish)
    if lkfish ~= nil then
        lkfish:setMultiple(data.fish_mulriple)
    end
end
--定屏结束
function GameLayer:onSubDingPingOver( dataBuffer )
    --print("定屏结束了----------")
    self._dataModel.dingping = false
end
--离子子弹结束
function GameLayer:onSubBulletIonTimeout(dataBuffer)
    local data = ExternalFun.read_netdata(g_var(cmd).BulletIonTimeout, dataBuffer)
    -- --dump(data,"离子子弹结束 ",data)

    local bulletMulriple = self.m_cannonLayer:getCannonMulriple(data.chair_id) --当前子弹倍数
    local can = self.m_cannonLayer:getCannoByPos(data.chair_id+1)
    if can ~= nil then
        can:setSuperBullet(false)
    end
    if data.chair_id == self.m_nChairID then
        -- local bkind = nil
        -- if bulletMulriple < 100 then
        --     bkind = 0
        -- elseif bulletMulriple >= 100 and bulletMulriple < 1000 then
        --     bkind = 1
        -- elseif bulletMulriple >= 1000 and bulletMulriple < 5000 then
        --     bkind = 2
        -- else
        --     bkind = 3
        -- end
        local bkind = self:getKindNum(bulletMulriple)

        self.m_cannonLayer:switch(data.chair_id, bkind)
    else
        local bkind = self.m_cannonLayer:getCurrentBulletKind(data.chair_id)
        self.m_cannonLayer:switch(data.chair_id, bkind % 4)
    end
end
-- 游戏消息
local testCreateFishTimes = 0
function GameLayer:onEventGameMessage(sub,dataBuffer)
    print("接收游戏内消息 : ",sub, dataBuffer, self.m_bLeaveGame, self._gameView)
    -- 游戏内消息 :        122     userdata        nil     userdata
    if self.m_bLeaveGame or nil == self._gameView  then
        --print("return-------------onEventGameMessage")
	    return
    end 

    if sub == g_var(cmd).SUB_S_SEND_BIRD then --创建鱼
       
  		-- --鱼创建
          self:onSubFishTrace(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_BUY_BULLET_FAILED then --上分失败
         print("上分失败")
               
    elseif sub == g_var(cmd).SUB_S_HIT_FISH_LK then --李逵分
        -- --print("李逵分数变更 ",dataBuffer:getlen())
        self:onSubLkMultiple(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_BUY_BULLET_SUCCESS then --用户上分
        -- --print("用户上分---------------------------")
        self:onSubExchangeFishScore(dataBuffer)
    elseif sub ==  134 then -- 抓住闪电鱼   --g_var(cmd).SUB_S_FISHSCORETOBULLET then --用户下分
        --闪电鱼 待定
        --这就是命啊
        self:on_sub_catch_bird_chain(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_SEND_BULLET  then --用户开火
        print("开火包长度----------------------------",dataBuffer:getlen())
        -- --dump(dataBuffer,"fire---->>")
        self:onSubUserFire(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_BULLET_ION_TIMEOUT then --离子子弹结束
        self:onSubBulletIonTimeout(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_FISH_CATCH then --捕鱼
        print("捕鱼包长度 ",dataBuffer:getlen())
        self:onSubFishCatchT(dataBuffer)
    -- elseif sub == g_var(cmd).SUB_S_CATCH_SWEEP_FISH_RESULT then --捕鱼（扫描的）
    --     print("捕鱼(扫描)包长度 ",dataBuffer:getlen())
        --129 消息对应大闹天宫 SUB_S_PLAY_BIRD
        --self:onSubFishCatchT(dataBuffer,1)
    elseif sub == 129 then --场景鱼
        --self:on_sub_play_bird(dataBuffer)
    elseif sub == 130 then --场景子弹
        --self:on_sub_play_bullet(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_LOCK_TIMEOUT then --定屏结束
        self:onSubDingPingOver(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_CHANGE_SCENE then--sub == g_var(cmd).SUB_S_EXCHANGE_SCENE then --切换场景
        --dntg 切换场景sub SUB_S_CHANGE_SCENE == 100

       print("切换场景包长度 ",dataBuffer:getlen() )
        -- if testCreateFishTimes == 0 then
            self:onSubExchangeScene(dataBuffer)
        -- end
        -- testCreateFishTimes = testCreateFishTimes +
    elseif sub == 114 then  --鱼特效 定屏
        
        self:on_sub_bird_effect(dataBuffer)
    elseif sub == 111 then  --时间校准
        --没懂什么意思 生成鱼有用到
        self:on_sub_time_check(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_SEND_BIRD_LINEAR then  --特殊鱼镇
        
        self:on_sub_bird_linear(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_SEND_BIRD_ROUND then
        self:on_sub_bird_round(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_SEND_BIRD_PAUSE_LINEAR then
        self:on_sub_bird_pause_linear(dataBuffer)
    end
end

function GameLayer:on_sub_bird_effect( dataBuffer )
    --定屏
    -- if 1 then
    --     return
    -- end
    local bird_effect  = ExternalFun.read_netdata(g_var(cmd).CMD_S_Bird_Effect,dataBuffer)
    if bird_effect.effect_ == 3 then
        --定屏
        if bird_effect.bird_id_>0 then
            self._dataModel.dingping = true
        else
            self._dataModel.dingping = false
        end
        
    end
   
end

function GameLayer:on_sub_time_check( dataBuffer )
    local timeCheck_  = ExternalFun.read_netdata(g_var(cmd).CMD_S_TimeCheck,dataBuffer)
    TimestampManager:timeCheck(math.abs(timeCheck_.client_time_),math.abs(timeCheck_.server_time_))
end

--创建鱼
function GameLayer:onSubFishTrace( dataBuffer )
    table.insert(self._dataModel.m_fishData,dataBuffer:retain())
    -- --print("收到创建鱼数据: ",#self._dataModel.m_fishData)
end
--创建鱼震1
function GameLayer:on_sub_bird_linear( dataBuffer )
    table.insert(self._dataModel.m_LinearfishData,dataBuffer:retain())
end
--创建鱼震2
function GameLayer:on_sub_bird_round( dataBuffer )
    table.insert(self._dataModel.m_RoundfishData,dataBuffer:retain())
end
--创建鱼震3
function GameLayer:on_sub_bird_pause_linear( dataBuffer )
    table.insert(self._dataModel.m_PausefishData,dataBuffer:retain())
end

--[[
* @brief  两点距离
* @param [in] x1       位置1x坐标
* @param [in] y1       位置1y坐标
* @param [in] x2       位置2x坐标
* @param [in] y2       位置2y坐标
* @return  返回结果
--]]
function GameLayer:calcDistance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end
--[[
* @brief  组合
* @param [in] count    多少个元素
* @param [in] r        取出多少个
* @return  返回结果
--]]
function GameLayer:combination(count, r)
    return self:factorial(count) / (self:factorial(r) * self:factorial(count - r))
end
--[[
* @brief  阶乘
* @param [in] chair_id     多少阶乘
* @return  返回结果
--]]
function GameLayer:factorial(number)
    local factorial = 1
    local temp = number
    for i=0, number do
        factorial = factorial * temp
        temp = temp - 1
    end
    return factorial
end

--创建定时器
local testtt = 0
function GameLayer:onCreateSchedule()
    local isBreak0 = false
    local isBreak1 = true

    --鱼队列
    local function dealCanAddFish()
        if 0 ~= #self._dataModel.m_fishCreateList  then
            --每一帧最多刷鱼鱼数目
            local  fishcount = #self._dataModel.m_fishCreateList
            for i=1,fishcount do --wyf 刷鱼
                local fishdata = self._dataModel.m_fishCreateList[1]

                table.remove(self._dataModel.m_fishCreateList,1)
                print("鱼进来了")
                local fish = g_var(Fish):create(fishdata,self)
                
                fish:initAnim()
                fish:setTag(g_var(cmd).Tag_Fish)
                fish:initPhysicsBody()
                self.m_fishLayer:addChild(fish, fish.m_data.fish_kind + 1) --鱼种类越高 层级越高
                self._dataModel.m_fishList[fish.m_data.fish_id] = fish
            end
        end 
    end

    --等待队列
    local function dealWaitList( )

        if isBreak1 then
            isBreak0 = false
            return
        end

        if  #self._dataModel.m_waitList == 0 then
            isBreak0 = false
            isBreak1 = true
            return
        end

        if  #self._dataModel.m_waitList ~= 0 then
           
            for i=1, #self._dataModel.m_waitList do
                local fishdata = self._dataModel.m_waitList[i]
                table.insert(self._dataModel.m_fishCreateList,1,fishdata)
            end
            self._dataModel.m_waitList = {}
        end
    end

    --定位大鱼
    local function selectMaxFish()
        --自动锁定
        if self._dataModel.m_autolock  then
            local fish = self._dataModel.m_fishList[self._dataModel.m_fishIndex]
            -- --print("ffff ",fish, self._dataModel.m_fishIndex)
            if nil == fish then
                self._dataModel.m_fishIndex = self._dataModel:selectMaxFish()
                self.selectFishAngle = true
                -- --print("fffffffffffffffffffffffffffffffffffffffff",self.selectFishAngle)
            else
                local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
                local pos = cc.p(fish:getPositionX(),fish:getPositionY()) 
                  
                if not cc.rectContainsPoint(rect,pos) then
                    self.selectFishAngle = true
                    self._dataModel.m_fishIndex = self._dataModel:selectMaxFish()
                end
            end
            
            if self._dataModel.m_fishList[self._dataModel.m_fishIndex] == nil then
                --没有大鱼的情况下 锁鱼无效
                self._gameView:setLockByFish(false)
            end
            
            if self.selectFishAngle == true then
                self.selectFishAngle = false
                local cannon = self.m_cannonLayer:getCannoByPos(self.m_nChairID + 1)
                if cannon ~= nil then
                    -- --print("iiiiiiiiiiiiiiiiiiiIIIIIIIIIIIIIIIII")
                    cannon:setLockAngle(self._dataModel.m_fishIndex)
                end
            end
        end
    end

    local function dealFishData()
        -- --print("dealFishData-------------------------",#self._dataModel.m_fishData) wyf
        -- --print("解析鱼数据-------------------",#self._dataModel.m_fishData)
        if 0 == #self._dataModel.m_fishData then
            return
        end

        local dataBuffer = self._dataModel.m_fishData[1] --当前鱼数据
        table.remove(self._dataModel.m_fishData,1)

        --local fishNum = math.floor(dataBuffer:getlen()/56)
        local fishNum = math.floor(dataBuffer:getlen()/37)
        
       --print("当前鱼数量，",fishNum, dataBuffer:getlen())
        -- fishNum = 1 --test
        -- fishNum = 2
        if fishNum >= 1 then
            for i=1, fishNum do
                local fishCreate = ExternalFun.read_netdata(g_var(cmd).FishTrace,dataBuffer)
               
                local trad = TimestampManager:get_time_difference(fishCreate.time_)
                fishCreate.fish_kind = fishCreate.type_
                
                fishCreate.fish_TTType = FISH_TTYPE.fish_normal

                -- fishCreate.init_count = 2
                fishCreate.fish_id = fishCreate.id_
                fishCreate.elapsed_ = fishCreate.elapsed_+ (trad/1000)
                -- fishCreate.trace_type = 0
                 fishCreate.init_pos ={  {  {x = fishCreate.path_offset_.x ,y = fishCreate.path_offset_.y},{x = 1007.7, y= 50.0} } } 
                --dump(fishCreate)
                table.insert(self._dataModel.m_fishCreateList, fishCreate)

                if fishCreate.fish_kind >= g_var(cmd).FishKind.FISH_KIND_18 and fishCreate.fish_kind <= g_var(cmd).FishKind.FISH_KIND_21 then
                    local tips = 0
                    --del by zzy
                    if fishCreate.fish_kind == g_var(cmd).FishKind.FISH_KIND_18 then
                        tips = 1
                    elseif fishCreate.fish_kind == g_var(cmd).FishKind.FISH_KIND_19 then
                        tips = 2
                    elseif fishCreate.fish_kind == g_var(cmd).FishKind.FISH_KIND_20 then
                        tips = 3
                    elseif fishCreate.fish_kind == g_var(cmd).FishKind.FISH_KIND_21 then
                        tips = 4
                    else
                        tips = 5
                    end
                    self._gameView:Showtips(tips, fishCreate.fish_kind) --test 正常之后恢复
                end
            end
        end

        dataBuffer:release() 
    end  

    --鱼群1
    local function dealLinearFishData()
      
        if 0 == #self._dataModel.m_LinearfishData then
            return
        end
        --print("解析鱼群数据1-------------------",#self._dataModel.m_LinearfishData)
        local dataBuffer = self._dataModel.m_LinearfishData[1] --当前鱼数据
        table.remove(self._dataModel.m_LinearfishData,1)
        
        local fishNum = math.floor(dataBuffer:getlen()/42)
        
       print("当前鱼数量Linear，",fishNum, dataBuffer:getlen())
     
        if fishNum >= 1 then
            for i=1, fishNum do
                local fishCreate = ExternalFun.read_netdata(g_var(cmd).CMD_S_Send_Bird_Linear,dataBuffer)
                local trad = TimestampManager:get_time_difference(math.abs(fishCreate.time_))
                fishCreate.fish_kind = fishCreate.type_
                -- fishCreate.init_count = 2
                fishCreate.fish_TTType = FISH_TTYPE.fish_linear
                fishCreate.fish_id = fishCreate.id_
                fishCreate.elapsed_ = fishCreate.elapsed_+ (trad/1000.0)
                -- mei什么用nit pos
                 fishCreate.init_pos ={  {  {x = 0 ,y = 0},{x = 0, y= 0} } } 
                 --dump(fishCreate)
                table.insert(self._dataModel.m_fishCreateList, fishCreate)

            end
        end

        dataBuffer:release() 
    end  
    
    local function dealRoundFishData()
      
        if 0 == #self._dataModel.m_RoundfishData then
            return
        end
        print("解析鱼群数据2-------------------",#self._dataModel.m_RoundfishData)

        local dataBuffer = self._dataModel.m_RoundfishData[1] --当前鱼数据
        table.remove(self._dataModel.m_RoundfishData,1)

        local fishNum = math.floor(dataBuffer:getlen()/54)
        
       print("当前鱼数量RoundF，",fishNum, dataBuffer:getlen())
     
        if fishNum >= 1 then
            for i=1, fishNum do
                local fishCreate = ExternalFun.read_netdata(g_var(cmd).CMD_S_Send_Bird_Round,dataBuffer)
  
                local trad = TimestampManager:get_time_difference(fishCreate.time_)
                fishCreate.fish_kind = fishCreate.type_
                -- fishCreate.init_count = 2
                fishCreate.fish_TTType = FISH_TTYPE.fish_round
                fishCreate.fish_id = fishCreate.id_
                fishCreate.elapsed_ = fishCreate.elapsed_+ (trad/1000.0)
                -- mei什么用nit pos
                 fishCreate.init_pos ={  {  {x = 0 ,y = 0},{x = 0, y= 0} } } 
                 dump(fishCreate)
                table.insert(self._dataModel.m_fishCreateList, fishCreate)

            end
        end

        dataBuffer:release() 
    end  

    local function dealPauseFishData()
      
        if 0 == #self._dataModel.m_PausefishData then
            return
        end
        print("解析鱼群数据3-------------------",#self._dataModel.m_PausefishData)

        local dataBuffer = self._dataModel.m_PausefishData[1] --当前鱼数据
        table.remove(self._dataModel.m_PausefishData,1)

        local fishNum = math.floor(dataBuffer:getlen()/58)
        
       print("当前鱼数量Pause，",fishNum, dataBuffer:getlen())
     
        if fishNum >= 1 then
            for i=1, fishNum do
                local fishCreate = ExternalFun.read_netdata(g_var(cmd).CMD_S_Send_Bird_Pause_Linear,dataBuffer)
                dump(fishCreate)
                if tonumber(fishCreate.type_)>39  then
                    return
                end
                local trad = TimestampManager:get_time_difference(fishCreate.time_)
                fishCreate.fish_kind = fishCreate.type_
                -- fishCreate.init_count = 2
                fishCreate.fish_TTType = FISH_TTYPE.fish_pause
                fishCreate.fish_id = fishCreate.id_
                fishCreate.elapsed_ = fishCreate.elapsed_+ (trad/1000)
                -- mei什么用nit pos
                 fishCreate.init_pos ={  {  {x = 0 ,y = 0},{x = 0, y= 0} } } 
                
                table.insert(self._dataModel.m_fishCreateList, fishCreate)

            end
        end

        dataBuffer:release() 
    end  

    local  function dealFireData()
        if 0 == #self._dataModel.m_fireData then
            return
        end
        
        local dataBuffer = self._dataModel.m_fireData[1]
        table.remove(self._dataModel.m_fireData,1)
        -- --print("解析开火包长度 --->>")
        -- local cmddata = ExternalFun.create_netdata(g_var(cmd).UserFire)
        local fire = ExternalFun.read_netdata(g_var(cmd).UserFire, dataBuffer)
        dump(fire,"开火数据--->>>")
        -- --print("fire bullet id ",fire.bullet_id)
        local chair_id = fire.chair_id_
        -- --print("chair data = ",chair_id, self.m_nChairID)

        local bullet_mulriple = fire.bullet_mulriple --子弹倍数
        --local fish_score = fire.fish_score --扣的鱼分
        local curGold = self.m_cannonLayer:getFishGold(chair_id+1)
        if curGold == nil then return end
        -- --print("sss ",bullet_mulriple, curGold)
        -- --print("开火设置鱼分数",chair_id, curGold-bullet_mulriple, curGold, bullet_mulriple)
        self.m_cannonLayer:setFishGold(chair_id+1, curGold-bullet_mulriple)

        if chair_id == self.m_nChairID then
            return
        end

        if not self.m_cannonLayer then
            -- --print("dataBuffer ",dataBuffer)
            -- error("不能这里就完事了吧 ")
            dataBuffer:release()
            return
        end

        local lock_fish_id = fire.lock_bird_id_
        local angle = fire.rotation_


        self:setLockFishID(chair_id, lock_fish_id)


        local cannonPos = chair_id
        local cannon = self.m_cannonLayer:getCannoByPos(cannonPos + 1)
        if nil ~= cannon then
            cannon:setMultiple(bullet_mulriple)
            cannon:othershoot(fire)
            self._dataModel:playEffect(g_var(cmd).fire)
        else
            -- --print("cannon = nil ",cannonPos)
        -- self._dataModel.m_secene.lPalyCurScore[1][fire.wChairID+1] = self._dataModel.m_secene.lPalyCurScore[1][fire.wChairID+1] - fire.nBulletScore
        end
        dataBuffer:release()
        -- local lock_fish_id = fireData.lock_fishid
        -- local angle = fireData.angle

        -- if lock_fish_id == -1 then
        --     lock_fish_id = self:getLockFishID(chair_id)
        --     if lock_fish_id == 0 then
        --         --锁鱼。。
        --         -- lock_fish_id =
        --     end
        -- end
        -- self:setLockFishID(chair_id, lock_fish_id)

        -- if lock_fish_id > 0 then
        --     --todo local fish = 
        -- end

        -- --先发子弹后扣钱
        -- if chair_id ~= self.m_nChairID then --别人发的子弹哦
        --     self.m_cannonLayer:setCannonMulriple(chair_id, fireData.bullet_mulriple)
        --     self.m_cannonLayer:setFishScore(chair_id, fireData.fish_score)
        --     self.m_cannonLayer:fire(chair_id, fireData.bullet_kind)
        --     --todo play sound music
        -- else
        --     --自己发的子弹，不再画子弹了，只扣钱
        --     self.m_cannonLayer:fire(chair_id, self.current_bullet_kind_)
        --     self.m_cannonLayer:setFishScore(chair_id, fireData.fish_score)
        -- end
        -- --自己的炮管不重画了，不然网络不好会一跳一跳的
        -- if chair_id ~= self.m_nChairID then
        --     self.m_cannonLayer:setCurrentAngle(chair_id, angle)
        -- end
    end

    local function dealBullet()
        if 0 == table.nums(self._dataModel.m_InViewTag) then 
            if self._gameView:getChildByTag(g_var(cmd).Tag_Bullet) then
                --print("del this ????????????? test")
                self._gameView:removeChildByTag(g_var(cmd).Tag_Bullet)
            end
        end
    end 

    local function update(dt)
      -- --print("dt is  ================== >",dt,self._dataModel:checkRes())

        if not self._dataModel:checkRes() then  --检测资源是否加载完了
            ----print("没加载完资源返回")
            return
        end

        --筛选大鱼
        selectMaxFish()

        --鱼数据解析
        dealFishData()

        --特殊鱼阵列？
        dealLinearFishData()
        dealRoundFishData()
        dealPauseFishData()

        --能加入显示的鱼群
        dealCanAddFish()

        --开炮
        dealFireData()

        --需等待的鱼群
        -- dealWaitList()


        --处理子弹过多
        -- dealBullet()

        --处理jetton test
        -- self:jettonMore()
    end

    --游戏定时器
    if nil == self.m_scheduleUpdate then
        self.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0, false)
    end
end
-- function GameLayer:onSubAwardTip( databuffer )
--     local award = ExternalFun.read_netdata(g_var(cmd).CMD_S_AwardTip,databuffer)
--     local mutiple = award.nFishMultiple

--     if mutiple>=50 or (award.nFishType==19 and award.nScoreType==g_var(cmd).SupplyType.EST_Cold and award.wChairID==self.m_nChairID) then
--         self._gameView:ShowAwardTip(award)
--     end
-- end

-- function GameLayer:onSubBankTake(databuffer)
--   local take = ExternalFun.read_netdata(g_var(cmd).CMD_S_BankTake,databuffer)
--   -- self._dataModel.m_secene.lPalyCurScore[1][take.wChairID + 1] = self._dataModel.m_secene.lPalyCurScore[1][take.wChairID + 1] + take.lPlayScore
--   if take.wChairID == self.m_nChairID then
-- 	 self._dataModel.m_lScoreCopy = self._dataModel.m_lScoreCopy + take.lPlayScore
--   end
--   if not self.m_cannonLayer then
-- 	return
--   end
--   local cannonPos = take.wChairID
--   if  not self.m_cannonLayer then
--     return
--   end
--   if self._dataModel.m_reversal then 
--        cannonPos = 5 - cannonPos
--   end
--   local cannon = self.m_cannonLayer:getCannoByPos(cannonPos + 1)
--   if not cannon then
--      return
--   end
--   -- self.m_cannonLayer:updateUserScore( self._dataModel.m_secene.lPalyCurScore[1][take.wChairID + 1],cannonPos+1 )
--   if take.wChairID == self.m_nChairID then
--     -- GlobalUserItem.lUserScore = self._dataModel.m_secene.lPalyCurScore[1][take.wChairID + 1]
--     if nil ~= self._gameView and false == self.m_bLeaveGame then
--       self._gameView:refreshScore()
--     end
    
--   end
-- end

-- function GameLayer:onSubShootLaser( databuffer )
--   local laser = ExternalFun.read_netdata(g_var(cmd).CMD_S_Laser,databuffer)
--   --print("--- onSubShootLaser databuffer:getlen() ---",databuffer:getlen())
--   --dump(laser, "---- onSubShootLaser ----", 6)
--   local cannonPos = laser.wChairID
--   if laser.wChairID == self.m_nChairID then
--     --print("onSubShootLaser myself return")
--     return
--   end
--   if self._dataModel.m_reversal then 
--        cannonPos = 5 - cannonPos
--   end
--   local cannon = self.m_cannonLayer:getCannoByPos(cannonPos + 1)
--   if not  cannon then
--      return
--   end
  
--   if nil ~= cannon then
--     cannon.m_laserBeginConvertPos.x = laser.ptBeginPos.x
--     cannon.m_laserBeginConvertPos.y = laser.ptBeginPos.y
--     cannon.m_laserBeginConvertPos = self._dataModel:convertCoordinateSystem(cc.p( cannon.m_laserBeginConvertPos.x, cannon.m_laserBeginConvertPos.y), 0, self._dataModel.m_reversal)
--     cannon.m_laserConvertPos.x = laser.ptEndPos.x
--     cannon.m_laserConvertPos.y = laser.ptEndPos.y
--     cannon.m_laserConvertPos = self._dataModel:convertCoordinateSystem(cc.p( cannon.m_laserConvertPos.x, cannon.m_laserConvertPos.y), 0, self._dataModel.m_reversal)
--     cannon:shootLaser()
--   end
-- end

-- function GameLayer:onSubSupplyTip(databuffer)

--     if not self.m_cannonLayer then
--       return
--     end
   
--      local tip = ExternalFun.read_netdata(g_var(cmd).CMD_S_SupplyTip,databuffer)

--      local tipStr = ""
--      if tip.wChairID == self.m_nChairID then
--        tipStr = "获得一个补给箱！击中可能获得大量奖励哟！赶快击杀！"
--       else
--          local cannonPos = tip.wChairID
--          if self._dataModel.m_reversal then 
--            cannonPos = 5 - cannonPos
--          end

--          local cannon = self.m_cannonLayer:getCannoByPos(cannonPos + 1)
--          local userid = self.m_cannonLayer:getUserIDByCannon(cannonPos+1)
--          local userItem = self._gameFrame._UserList[userid]

--          if not userItem then
--             return
--          end
--          tipStr = userItem.szNickName .." 获得了一个补给箱！羡慕吧，继续努力，你也可能得到！"
--      end

--      self._gameView:Showtips(tipStr)
-- end

-- function GameLayer:onSubMultiple( databuffer )

--     --print("切换炮台倍数.......")
--     local mutiple = ExternalFun.read_netdata(g_var(cmd).CMD_S_Multiple,databuffer)
--     local cannonPos = mutiple.wChairID
--     if self._dataModel.m_reversal then 
--          cannonPos = 5 - cannonPos
--     end
 
--    if nil ~= self.m_cannonLayer then
--       local cannon = self.m_cannonLayer:getCannoByPos(cannonPos + 1)

--       if nil == cannon then
--         return
--       end

--       if mutiple.wChairID ~= self.m_nChairID then 
--         self._dataModel.m_secene.nMultipleIndex[1][mutiple.wChairID + 1] = mutiple.nMultipleIndex
--         cannon:setMultiple(mutiple.nMultipleIndex)    
--       end
--    end
-- end

-- function GameLayer:onSubUpdateGame( databuffer )
--   --print("接收的这是啥？onSubUpdateGame")
--   local update = ExternalFun.read_netdata(g_var(cmd).CMD_S_UpdateGame,databuffer)
--   self._dataModel.m_secene.nBulletVelocity = update.nBulletVelocity
--   self._dataModel.m_secene.nBulletCoolingTime = update.nBulletCoolingTime
--   self._dataModel.m_secene.nFishMultiple = update.nFishMultiple
--   self._dataModel.m_secene.nMultipleValue = update.nMultipleValue
-- end

-- function GameLayer:onSubStayFish( databuffer )
--   local stay = ExternalFun.read_netdata(g_var(cmd).CMD_S_StayFish,databuffer)

--   local fish = self._dataModel.m_fishList[stay.nFishKey]
--   if nil ~= fish then
--       fish:Stay(stay.nStayTime)
--   end
-- end
-- function GameLayer:onSubSupply(databuffer )
--   local supply =  ExternalFun.read_netdata(g_var(cmd).CMD_S_Supply,databuffer)

--   local cannonPos = supply.wChairID
--   if self._dataModel.m_reversal then 
--        cannonPos = 5 - cannonPos
--   end


--   if supply.nSupplyType == g_var(cmd).SupplyType.EST_Gift then
--     --dump(supply, "========== onSubSupply ==========", 6)
--     -- self._dataModel.m_secene.lPalyCurScore[1][supply.wChairID+1] = self._dataModel.m_secene.lPalyCurScore[1][supply.wChairID+1] + supply.lSupplyCount
--     if supply.wChairID == self.m_nChairID then
--       self._dataModel.m_lScoreCopy = self._dataModel.m_lScoreCopy + supply.lSupplyCount
--     end
--   end

--   if not self.m_cannonLayer then
--     return
--   end

  

--   local cannon = self.m_cannonLayer:getCannoByPos(cannonPos + 1)
--   if not  cannon then
--      return
--   else
--     if supply.nSupplyType == g_var(cmd).SupplyType.EST_Gift then
--         -- cannon:updateScore(self._dataModel.m_secene.lPalyCurScore[1][supply.wChairID+1]) 
--     end 
--   end
--   cannon:ShowSupply(supply)

--   local tipStr = ""

--    local cannonPos = supply.wChairID
--    if self._dataModel.m_reversal then 
--      cannonPos = 5 - cannonPos
--    end

--    local cannon = self.m_cannonLayer:getCannoByPos(cannonPos + 1)
--    local userid = self.m_cannonLayer:getUserIDByCannon(cannonPos+1)
--    local userItem = self._gameFrame._UserList[userid]


--   if supply.nSupplyType == g_var(cmd).SupplyType.EST_Laser then
--      if supply.wChairID == self.m_nChairID then
--        tipStr = self.m_pUserItem.szNickName.."击中补给箱打出了激光！秒杀利器！赶快使用！"
--     else
--        tipStr = userItem.szNickName .." 击中补给箱打出了激光！秒杀利器!"
--     end

--   elseif supply.nSupplyType == g_var(cmd).SupplyType.EST_Speed then
    
--       tipStr = userItem.szNickName.." 击中补给箱打出了加速！所有子弹速度翻倍！"
--   elseif supply.nSupplyType == g_var(cmd).SupplyType.EST_Null then
   
--       tipStr = "很遗憾！补给箱里面什么都没有！"

--       self._dataModel:playEffect(g_var(cmd).SmashFail)

--   end

--   if nil ~= tipStr then 
--     self._gameView:Showtips(tipStr)
--   end
-- end

--同步时间
-- function GameLayer:onSubSynchronous( databuffer )
-- 	--print("同步时间")
--     self.m_bSynchronous = true
-- 	local synchronous = ExternalFun.read_netdata(g_var(cmd).CMD_S_FishFinish,databuffer)
-- 	if 0 ~= synchronous.nOffSetTime then
--         --print("同步时间1")
-- 	  	local offtime = synchronous.nOffSetTime
-- 	  	self._dataModel.m_enterTime = self._dataModel.m_enterTime - offtime
-- 	end
-- end

--切换场景
-- function GameLayer:onSubExchangeScene( dataBuffer )

--     --print("场景切换")

--     self._dataModel:playEffect(g_var(cmd).Change_Scene)
--     local systime = currentTime()
--     self._dataModel.m_enterTime = systime

--     self._dataModel._exchangeSceneing = true

--     local exchangeScene = ExternalFun.read_netdata(g_var(cmd).CMD_S_ChangeSecene,dataBuffer)
--     self._gameView:updteBackGround(exchangeScene.cbBackIndex)

--     local callfunc = cc.CallFunc:create(function()
--         self._dataModel._exchangeSceneing = false
--     end)

--     self:runAction(cc.Sequence:create(cc.DelayTime:create(8.0),callfunc))

-- end

-- function GameLayer:onSubFire(databuffer)
  
--   table.insert(self._dataModel.m_fireData,databuffer:retain())

-- end

--捕获鱼消息
local ttt = 0
function GameLayer:playFishEffect( fish_kind )
    -- fish_kind = 11 --test 测试音效
    if fish_kind >= g_var(cmd).FishKind.FISH_KIND_10 and fish_kind <= g_var(cmd).FishKind.FISH_KIND_17 then
        -- local mathNum = 1
        -- if fish_kind == g_var(cmd).FishKind.FISH_KIND_17 then
        --     mathNum = math.random(1, 3)
        -- end
        -- --print("播放鱼的音效----------- ",fish_kind)
        local key = g_var(cmd).fishEffect[fish_kind+1]
        local file = key[math.random(1, #key)]
        self._dataModel:playEffect(file)
    end
end
function GameLayer:onSubFishCatchT(dataBuffer, _type)
   
    self._dataModel:playEffect(g_var(cmd).catch)

    local fishNum = math.floor(dataBuffer:getlen()/48)
    local catchData = nil
    catchData = ExternalFun.read_netdata(g_var(cmd).CatchFish, dataBuffer)
    
    -- dump(catchData,"捕获普通鱼数据-------------->>>")
    -- print("fishnum" .. fishNum)
    for i=1,fishNum do
        local catch_bird = ExternalFun.create_netdata(g_var(cmd).CMD_S_Special_Catch_Bird)
        catch_bird.chair_id_ = catchData.chair_id;
        catch_bird.cannon_type_ = catchData.cannon_type_;
        local count = catchData.count_;
        --print(count)
        for j=1,count do
            catch_bird.bird_id_ = catchData.catch_bird_[1][j].bird_id_;
            catch_bird.catch_gold_ = catchData.catch_bird_[1][j].catch_gold_;
            catch_bird.award_type_ = catchData.catch_bird_[1][j].award_type_;
            catch_bird.award_count_ = catchData.catch_bird_[1][j].award_count_;
            catch_bird.medal_ = catchData.catch_bird_[1][j].medal_;
            catch_bird.link_bird_id_ = catchData.catch_bird_[1][j].link_bird_id_;
            catch_bird.thread_id = 1;
           
            local emitter = nil
            
            if self._dataModel.m_fishList[catch_bird.bird_id_] == nil then
                --print("空fishID : " ..catch_bird.bird_id_)
                local curgold1 = self.m_cannonLayer:getFishGold(catch_bird.chair_id_+1)
                if catch_bird.chair_id_ == self.m_nChairID then
                    --设置分数
                    
                    self.m_cannonLayer:setFishGold(self.m_nChairID+1, curgold1 + catch_bird.catch_gold_)
                    self._gameView:setCurGold( curgold1 + catch_bird.catch_gold_)
                 
                else 
                    --先这样
                    if curgold1 == nil then
                        return
                    end
                    self.m_cannonLayer:setFishGold(catch_bird.chair_id_+1,  curgold1 + catch_bird.catch_gold_)
                end

                return
            end
            
            local catchKindID = self._dataModel.m_fishList[catch_bird.bird_id_].m_data.fish_kind

            local curgold1 = self.m_cannonLayer:getFishGold(catch_bird.chair_id_+1)
            if catchKindID >= 50 then
                print("老的一箭多雕 无视")
                return
            end
       
            --catchData.fish_score = catch_bird.catch_gold_

            if  tonumber(catchKindID) >= g_var(cmd).FishKind.FISH_KIND_18 and tonumber(catchKindID )<= g_var(cmd).FishKind.FISH_KIND_21 then
                emitter = "一网打尽爆炸"
            elseif catchKindID >= g_var(cmd).FishKind.FISH_KIND_25 then
                emitter = "海啸来袭爆炸"
            elseif catchKindID == g_var(cmd).FishKind.FISH_KIND_23 or catchKindID == g_var(cmd).FishKind.FISH_KIND_24 then
                emitter = "鱼雷爆炸"
            elseif catchKindID == g_var(cmd).FishKind.FISH_KIND_22 then
                emitter = "定海"
            end
            if emitter ~= nil then
                self._dataModel:playEffect(g_var(cmd).superarm)
            end
            self:playFishEffect(catchKindID)

            
        if not self.m_cannonLayer then
                local fish = self._dataModel.m_fishList[catch_bird.bird_id_]
                if catch_bird.chair_id_ == self.m_nChairID then
                else
                    if fish ~= nil and fish.m_data ~= nil then
                        fish:removeFromParent()
                        self._dataModel.m_fishList[catch_bird.bird_id_] = nil
                        -- error("sssffsszz")
                    end
                end
        else
        
            local fish = self._dataModel.m_fishList[catch_bird.bird_id_]
            local saomiaoFish = {}
            local curgold = self.m_cannonLayer:getFishGold(catch_bird.chair_id_+1)

            if catch_bird.chair_id_ == self.m_nChairID then
                --设置分数
                print("FishScore : " .. catch_bird.catch_gold_ .. "  kindID "  .. catchKindID 
                .. "   Score:" .. curgold + catch_bird.catch_gold_ )
                -- self.m_cannonLayer:setFishGold(self.m_nChairID+1, catchData.bullet_count[1][self.m_nChairID+1])
                self.m_cannonLayer:setFishGold(self.m_nChairID+1, curgold + catch_bird.catch_gold_)
                self._gameView:setCurGold( curgold + catch_bird.catch_gold_)
                --统计打死的鱼
                if _type == nil then
                    if self.fishkindNum[catchKindID] == nil then self.fishkindNum[catchKindID] = 0 end
                    self.fishkindNum[catchKindID] = self.fishkindNum[catchKindID] + 1
                else
                
                end
            else 
           
                --先这样
                if curgold == nil then
                    return
                end
                self.m_cannonLayer:setFishGold(catch_bird.chair_id_+1,  curgold + catch_bird.catch_gold_)
            end

            if  fish ~= nil then
            --金币动画 
                local fishPos = cc.p(fish:getPositionX(), fish:getPositionY())

                if fish.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_16 then
                    local praticle = cc.ParticleSystemQuad:create("game_res/particles_test2.plist")
                    praticle:setPosition(fishPos)
                    praticle:setPositionType(cc.POSITION_TYPE_GROUPED)
                    self:addChild(praticle,3)
                end
            
                -- if fish.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_22 then --定屏炸弹
                --     self._dataModel.dingping = true
                -- end

                if (fish.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_18 and fish.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_21) or
                    (fish.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and fish.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_30) then
                    self._dataModel:playEffect(g_var(cmd).bingo)
                    local aniName = "bingoAnim" --大鱼bingo动画
                    local ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                    if ani ~= nil then
                        local times = 1
                        local con = self.m_cannonLayer:getCannoByPos(catch_bird.chair_id_ + 1)
                        local action = cc.Repeat:create(cc.Animate:create(ani),4)
                        local coin = cc.Sprite:create() --256*256
                        local call = cc.CallFunc:create(function(  )
                            coin:removeFromParent()
                        end)
                   
                        coin:setScale(0.5)
                        coin:runAction( cc.Sequence:create( action, call ) )
                        if catch_bird.chair_id_ < 3 then
                            coin:setPosition(cc.p(con:getPositionX(),con:getPositionY()-con:getContentSize().height-20))
                    
                        else
                            coin:setPosition(cc.p(con:getPositionX(),con:getPositionY()+con:getContentSize().height+20))
                        end
                        self:addChild(coin)

                        local bingoNum = cc.LabelAtlas:create(string.format("%d", catch_bird.catch_gold_),"prize/bingo_num.png",50,60,string.byte("0"))
                        bingoNum:setAnchorPoint(0.5, 0.5)
                        bingoNum:setScale(0.8)
                        bingoNum:setPositionY(256*coin:getScaleY())
                        bingoNum:setPositionX(256*coin:getScaleX())
                        coin:addChild(bingoNum)
                        local skew1 = cc.SkewTo:create(0.3, 37.5, -37.5)
                        local skew2 = cc.SkewTo:create(0.3, 0, 0)
                        local skew3 = cc.SkewTo:create(0.3, -37.5, 37.5)

                        bingoNum:runAction(cc.Sequence:create(skew1, skew2, skew3, skew2, skew1, skew2, skew3, skew2))
                    end
                end

                --游戏币动画
                local aniName = "goldAnim"
                local ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                if ani ~= nil then
                    local times = 1
                    local con = self.m_cannonLayer:getCannoByPos(catch_bird.chair_id_ + 1)
                    if con == nil then return end
                    if con:isVisible() == false then return end
                    local kCoinCountEnum = { 0, 100, 1000, 10000, 100000 }
                    local kCointCount = { 2, 3, 4, 5, 6 }
                    local coin_count = 0

                    local len  = 5
                    for i = len,1,-1 do
                        if catch_bird.catch_gold_ >= kCoinCountEnum[i] then 
                            if i == len then 
                                coin_count = kCointCount[i] + math.floor((catch_bird.catch_gold_ - kCoinCountEnum[i]) / 10000)
                                coin_count = math.min(20,coin_count)
                                break
                            else
                                coin_count = kCointCount[i]
                                break
                            end

                        end
                    end

                    for i=1, coin_count do --金币
                        local action = cc.Repeat:create(cc.Animate:create(ani),5)
                        local move = cc.MoveTo:create(2, cc.p(con:getPositionX(), con:getPositionY()))

                        local gold = cc.Sprite:create()
                        local call = cc.CallFunc:create(function(  )
                            gold:removeFromParent()
                        end)
                        gold:runAction(action)
                        gold:runAction( cc.Sequence:create( move, call ) )

                        local mathX, mathY = nil, nil
                        if i == 1 then
                            mathX, mathY = fishPos.x, fishPos.y
                        else
                            --math.randomseed(tostring(os.time()):reverse():sub(1, 7))
                            mathX, mathY = fishPos.x + math.random(1,200), fishPos.y + math.random(1,200)
                        end
                        ----print("mathX----------------------------------",mathX,mathY)
                        gold:setPosition( cc.p( mathX, mathY ))
                        self:addChild(gold)
                    end

                    self._gameView:showJetton(catch_bird)
                end

                --获得鱼分数数字
                local num = cc.LabelAtlas:create(string.format("%d", catch_bird.catch_gold_),"score_num.png",33,38,string.byte("0"))
                num:setAnchorPoint(0.5, 0.5)
                num:setPosition(fishPos.x, fishPos.y)
                self:addChild(num)
                local call = cc.CallFunc:create(function()
                    num:removeFromParent()
                end)

                num:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), call))

                --鱼死亡处理
                fish:deadDeal()
            end
            for k,v in pairs(saomiaoFish) do 
                --鱼死亡处理
                -- --print("跟着一起死的 ", v.m_data.fish_kind )
                v:deadDeal()
            end
            end

 
            if catch_bird.chair_id_ == self.m_nChairID then
                if catchKindID == g_var(cmd).FishKind.FISH_KIND_19 or catchKindID == g_var(cmd).FishKind.FISH_KIND_20 then
                    local name = self.m_pUserItem.szNickName
                    local fishName = "金龙"
                    if catchKindID == g_var(cmd).FishKind.FISH_KIND_20 then fishName = "企鹅" end
                    --del by zzy
                    --self._gameView:Showtips(string.format("恭喜【%s】捕获【%s】,获得【%d】金币",name, fishName, catchData.fish_score*self.exchange_ratio_userscore_/self.exchange_ratio_fishscore_))
                    -- self._gameView:ShowAwardTip(string.format("恭喜【%s】捕获【%s】,获得【%d】金币",name, fishName, catchData.fish_score*self.exchange_ratio_userscore_/self.exchange_ratio_fishscore_))
                end
            end
        end
    end

  
end

function GameLayer:on_sub_catch_bird_chain(dataBuffer )
    self._dataModel:playEffect(g_var(cmd).catch)

    local fishNum = math.floor(dataBuffer:getlen()/49)
    local catchData = nil
    catchData = ExternalFun.read_netdata(g_var(cmd).CMD_S_Catch_Bird_Chain, dataBuffer)

    for i=1,fishNum do

        local catch_bird = ExternalFun.create_netdata(g_var(cmd).CMD_S_Special_Catch_Bird)
        catch_bird.chair_id_ = catchData.chair_id_;
        catch_bird.cannon_type_ = catchData.cannon_type_;
        local count = catchData.count_;

        for j=1,count do
            catch_bird.bird_id_ = catchData.catch_bird_[1][j].bird_id_;
            catch_bird.catch_gold_ = catchData.catch_bird_[1][j].catch_gold_;
            catch_bird.award_type_ = catchData.catch_bird_[1][j].award_type_;
            catch_bird.award_count_ = catchData.catch_bird_[1][j].award_count_;
            catch_bird.medal_ = catchData.catch_bird_[1][j].medal_;
            catch_bird.link_bird_id_ = catchData.catch_bird_[1][j].link_bird_id_;
            catch_bird.thread_id = 1;
            local catchKindID = self._dataModel.m_fishList[catch_bird.bird_id_].m_data.fish_kind

            local curgold1 = self.m_cannonLayer:getFishGold(catch_bird.chair_id_+1)

            local emitter = nil
            
            if self._dataModel.m_fishList[catch_bird.bird_id_] == nil then
                if catch_bird.chair_id_ == self.m_nChairID then
                    --设置分数
                    print("134 msg FishScore : " .. catch_bird.catch_gold_ .. "  kindID "  .. catchKindID 
                    .. "   Score:" .. curgold1 + catch_bird.catch_gold_ )
                    
                    self.m_cannonLayer:setFishGold(self.m_nChairID+1, curgold1 + catch_bird.catch_gold_)
                    self._gameView:setCurGold( curgold1 + catch_bird.catch_gold_)
                 
                else 
                    --先这样
                    if curgold1 == nil then
                        return
                    end
                    self.m_cannonLayer:setFishGold(catch_bird.chair_id_+1,  curgold1 + catch_bird.catch_gold_)
                end

                return           
            end
            
           
            if catchKindID >= 50 then
                print("老的一箭多雕 无视")
                return
            end
       
            --catchData.fish_score = catch_bird.catch_gold_

            if  tonumber(catchKindID) >= g_var(cmd).FishKind.FISH_KIND_18 and tonumber(catchKindID )<= g_var(cmd).FishKind.FISH_KIND_21 then
                emitter = "一网打尽爆炸"
            elseif catchKindID >= g_var(cmd).FishKind.FISH_KIND_25 then
                emitter = "海啸来袭爆炸"
            elseif catchKindID == g_var(cmd).FishKind.FISH_KIND_23 or catchKindID == g_var(cmd).FishKind.FISH_KIND_24 then
                emitter = "鱼雷爆炸"
            elseif catchKindID == g_var(cmd).FishKind.FISH_KIND_22 then
                emitter = "定海"
            end
            if emitter ~= nil then
                self._dataModel:playEffect(g_var(cmd).superarm)
            end
            self:playFishEffect(catchKindID)

            
        if not self.m_cannonLayer then
                local fish = self._dataModel.m_fishList[catch_bird.bird_id_]
                if catch_bird.chair_id_ == self.m_nChairID then
                else
                    if fish ~= nil and fish.m_data ~= nil then
                        fish:removeFromParent()
                        self._dataModel.m_fishList[catch_bird.bird_id_] = nil
                        -- error("sssffsszz")
                    end
                end
        else
        
            local fish = self._dataModel.m_fishList[catch_bird.bird_id_]
            local saomiaoFish = {}
            local curgold = self.m_cannonLayer:getFishGold(catch_bird.chair_id_+1)

            if catch_bird.chair_id_ == self.m_nChairID then
                --设置分数
                print("134 msg FishScore: " .. catch_bird.catch_gold_ .. " kindID "  .. catchKindID 
                .. " Score: " .. curgold + catch_bird.catch_gold_ )
                -- self.m_cannonLayer:setFishGold(self.m_nChairID+1, catchData.bullet_count[1][self.m_nChairID+1])
                self.m_cannonLayer:setFishGold(self.m_nChairID+1, curgold + catch_bird.catch_gold_)
                self._gameView:setCurGold( curgold + catch_bird.catch_gold_)
                
            else 
           
                --先这样
                if curgold == nil then
                    return
                end
                self.m_cannonLayer:setFishGold(catch_bird.chair_id_+1,  curgold + catch_bird.catch_gold_)
            end

            if  fish ~= nil then
            --金币动画 
                local fishPos = cc.p(fish:getPositionX(), fish:getPositionY())

                if fish.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_16 then
                    local praticle = cc.ParticleSystemQuad:create("game_res/particles_test2.plist")
                    praticle:setPosition(fishPos)
                    praticle:setPositionType(cc.POSITION_TYPE_GROUPED)
                    self:addChild(praticle,3)
                end
            
                -- if fish.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_22 then --定屏炸弹
                --     self._dataModel.dingping = true
                -- end

                if (fish.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_18 and fish.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_21) or
                    (fish.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and fish.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_30) then
                    self._dataModel:playEffect(g_var(cmd).bingo)
                    local aniName = "bingoAnim" --大鱼bingo动画
                    local ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                    if ani ~= nil then
                        local times = 1
                        local con = self.m_cannonLayer:getCannoByPos(catch_bird.chair_id_ + 1)
                        local action = cc.Repeat:create(cc.Animate:create(ani),4)
                        local coin = cc.Sprite:create() --256*256
                        local call = cc.CallFunc:create(function(  )
                            coin:removeFromParent()
                        end)
                   
                        coin:setScale(0.5)
                        coin:runAction( cc.Sequence:create( action, call ) )
                        if catch_bird.chair_id_ < 3 then
                            coin:setPosition(cc.p(con:getPositionX(),con:getPositionY()-con:getContentSize().height-20))
                    
                        else
                            coin:setPosition(cc.p(con:getPositionX(),con:getPositionY()+con:getContentSize().height+20))
                        end
                        self:addChild(coin)

                        local bingoNum = cc.LabelAtlas:create(string.format("%d", catch_bird.catch_gold_),"prize/bingo_num.png",50,60,string.byte("0"))
                        bingoNum:setAnchorPoint(0.5, 0.5)
                        bingoNum:setScale(0.8)
                        bingoNum:setPositionY(256*coin:getScaleY())
                        bingoNum:setPositionX(256*coin:getScaleX())
                        coin:addChild(bingoNum)
                        local skew1 = cc.SkewTo:create(0.3, 37.5, -37.5)
                        local skew2 = cc.SkewTo:create(0.3, 0, 0)
                        local skew3 = cc.SkewTo:create(0.3, -37.5, 37.5)

                        bingoNum:runAction(cc.Sequence:create(skew1, skew2, skew3, skew2, skew1, skew2, skew3, skew2))
                    end
                end

                --游戏币动画
                local aniName = "goldAnim"
                local ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                if ani ~= nil then
                    local times = 1
                    local con = self.m_cannonLayer:getCannoByPos(catch_bird.chair_id_ + 1)
                    if con == nil then return end
                    if con:isVisible() == false then return end
                    local kCoinCountEnum = { 0, 100, 1000, 10000, 100000 }
                    local kCointCount = { 2, 3, 4, 5, 6 }
                    local coin_count = 0

                    local len  = 5
                    for i = len,1,-1 do
                        if catch_bird.catch_gold_ >= kCoinCountEnum[i] then 
                            if i == len then 
                                coin_count = kCointCount[i] + math.floor((catch_bird.catch_gold_ - kCoinCountEnum[i]) / 10000)
                                coin_count = math.min(20,coin_count)
                                break
                            else
                                coin_count = kCointCount[i]
                                break
                            end

                        end
                    end

                    for i=1, coin_count do --金币
                        local action = cc.Repeat:create(cc.Animate:create(ani),5)
                        local move = cc.MoveTo:create(2, cc.p(con:getPositionX(), con:getPositionY()))

                        local gold = cc.Sprite:create()
                        local call = cc.CallFunc:create(function(  )
                            gold:removeFromParent()
                        end)
                        gold:runAction(action)
                        gold:runAction( cc.Sequence:create( move, call ) )

                        local mathX, mathY = nil, nil
                        if i == 1 then
                            mathX, mathY = fishPos.x, fishPos.y
                        else
                            --math.randomseed(tostring(os.time()):reverse():sub(1, 7))
                            mathX, mathY = fishPos.x + math.random(1,200), fishPos.y + math.random(1,200)
                        end
                        ----print("mathX----------------------------------",mathX,mathY)
                        gold:setPosition( cc.p( mathX, mathY ))
                        self:addChild(gold)
                    end

                    self._gameView:showJetton(catch_bird)
                end

                --获得鱼分数数字
                local num = cc.LabelAtlas:create(string.format("%d", catch_bird.catch_gold_),"score_num.png",33,38,string.byte("0"))
                num:setAnchorPoint(0.5, 0.5)
                num:setPosition(fishPos.x, fishPos.y)
                self:addChild(num)
                local call = cc.CallFunc:create(function()
                    num:removeFromParent()
                end)

                num:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), call))

                --鱼死亡处理
                fish:deadDeal()
            end
            for k,v in pairs(saomiaoFish) do 
                --鱼死亡处理
                -- --print("跟着一起死的 ", v.m_data.fish_kind )
                v:deadDeal()
            end
            end

 
            if catch_bird.chair_id_ == self.m_nChairID then
                if catchKindID == g_var(cmd).FishKind.FISH_KIND_19 or catchKindID == g_var(cmd).FishKind.FISH_KIND_20 then
                    local name = self.m_pUserItem.szNickName
                    local fishName = "金龙"
                    if catchKindID == g_var(cmd).FishKind.FISH_KIND_20 then fishName = "企鹅" end
                    --del by zzy
                    --self._gameView:Showtips(string.format("恭喜【%s】捕获【%s】,获得【%d】金币",name, fishName, catchData.fish_score*self.exchange_ratio_userscore_/self.exchange_ratio_fishscore_))
                    -- self._gameView:ShowAwardTip(string.format("恭喜【%s】捕获【%s】,获得【%d】金币",name, fishName, catchData.fish_score*self.exchange_ratio_userscore_/self.exchange_ratio_fishscore_))
                end
            end
        end
    end
end

--断线重连
function GameLayer:OnResetGameEngine()
    --print("@@@@@@@@@@断线重连@@@@@@@@@@@")
    -- self._dataModle:removeAllUser()
    -- self._dataModle:initUserList(self:getUserList())
    -- error("f")
end

--银行 
-- function GameLayer:onSocketInsureEvent( sub,dataBuffer )
--   --print(sub)

--     self:dismissPopWait()

--     if sub == g_var(game_cmd).SUB_GR_USER_INSURE_SUCCESS then
--         local cmd_table = ExternalFun.read_netdata(g_var(game_cmd).CMD_GR_S_UserInsureSuccess, dataBuffer)
--         self.bank_success = cmd_table

--         self._gameView:onBankSuccess()

--     elseif sub == g_var(game_cmd).SUB_GR_USER_INSURE_FAILURE then

--         local cmd_table = ExternalFun.read_netdata(g_var(game_cmd).CMD_GR_S_UserInsureFailure, dataBuffer)
--         self.bank_fail = cmd_table

--         self._gameView:onBankFailure()
--     else
--         --print("unknow gamemessage sub is ==>"..sub)
--     end
-- end

function GameLayer:onExitTable()
    --print("退出了鸟。。。。。。。")
    self._scene:onKeyBack()
end

function GameLayer:onKeyBack()
    --print("点击返回????????????????")
    if nil == PRELOAD.loadingBar then
        self:onQueryExitGame()
    else
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(delayLeaveTime),
            cc.CallFunc:create(
                function () 
                    self._gameView:StopLoading(false)
                    self._gameFrame:StandUp(1)
                end
                ),
            cc.DelayTime:create(exit_timeOut),
            cc.CallFunc:create(
                function ()
                    --强制离开游戏(针对长时间收不到服务器消息的情况)
                    --print("delay leave")
                    self:onExitRoom()
                end
                )
            )
        )
    end

    return true
end
--设置锁鱼ID
function GameLayer:setLockFishID(chair_id, fish_id)
    self.lock_fish_id_[chair_id+1] = fish_id
end
function GameLayer:getLockFishID(chair_id)
    return self.lock_fish_id_[chair_id+1]
end

function GameLayer:getDataMgr( )
    return self._dataModel
end

function GameLayer:sendNetData( cmddata )
    return self._gameFrame:sendSocketData(cmddata)
end

--离开房间
function GameLayer:onExitRoom()
    --print("离开房间？ gamelayer")
    self._gameFrame:onCloseSocket()

    self._scene:onKeyBack()
end

function GameLayer:showSystemTip( tip )
    if self.firstInTime == 0 then
        self.firstInTime = self.firstInTime + 1
        self._gameView:Showtips(tip,nil, cc.RED, 10)
    else
        self._gameView:Showtips(tip,nil, cc.RED)
    end
end
--退出询问
function GameLayer:onQueryExitGame()

    if self._queryDialog then
      return
    end

    self._queryDialog = QueryDialog:create("您要退出游戏么？", function(ok)
        if ok == true then
            self:runAction(cc.Sequence:create(
            cc.DelayTime:create(delayLeaveTime),
            cc.CallFunc:create(
                function () 
                    self._gameFrame:setEnterAntiCheatRoom(false)
                    self._gameFrame:StandUp(1)
                end
                ),
            cc.DelayTime:create(exit_timeOut),
            cc.CallFunc:create(
                function ()
                    --强制离开游戏(针对长时间收不到服务器消息的情况)
                    --print("delay leave")
                    self:onExitRoom()
                end
                )
            )
        )

        end
            self._queryDialog = nil
      end):setCanTouchOutside(false)
            :addTo(self)
end

return GameLayer