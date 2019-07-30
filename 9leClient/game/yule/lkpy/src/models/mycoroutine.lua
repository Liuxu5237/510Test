
local mycoroutine  = {}
local module_pre = "game.yule.lkpy.src"  
local cmd = module_pre .. ".models.CMD_LKGame"
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var = ExternalFun.req_var
local newPlist = 
{
    "gunbullet.plist",
    "fish_dead.plist",
    "fish_dead1.plist",
    "fish_dead2.plist",
    "fish_dead3.plist",
    "fish_dead4.plist",
    "fish_move.plist",
    "fish_move1.plist",
    "fish_move2.plist",
    "fish_move3.plist",
    "fish_move4.plist",
    "fish_move5.plist",
    "fish_move6.plist",
    "fish_move7.plist",
    "fish_move8.plist",
    "fish_move9.plist",
    "fish_move10.plist",
    "lock_fish.plist",
    "fish_gold.plist",
    "wave.plist",
    "boom_darts.plist",
    "bomb.plist",
    "blue.plist",
    "watch.plist",
}
local newPng = 
{
    "gunbullet.png",
    "fish_dead.png",
    "fish_dead1.png",
    "fish_dead2.png",
    "fish_dead3.png",
    "fish_dead4.png",
    "fish_move.png",
    "fish_move1.png",
    "fish_move2.png",
    "fish_move3.png",
    "fish_move4.png",
    "fish_move5.png",
    "fish_move6.png",
    "fish_move7.png",
    "fish_move8.png",
    "fish_move9.png",
    "fish_move10.png",
    "lock_fish.png",
    "fish_gold.png",
    "wave.png",
    "boom_darts.png",
    "bomb.png",
    "blue.png",
    "watch.png",
}

function mycoroutine.create()
    local m_nImageOffset = 1
    local function load(  )
        local function readAnimation(file, key, num, time,formatBit)
            local frames = {}
            local actionTime = time
            for i=1,num do

                local frameName
                if formatBit == 1 then
                    frameName = string.format(file.."%d.png", i-1)
                elseif formatBit == 2 then
                    frameName = string.format(file.."%2d.png", i-1)
                end
                local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
                
                table.insert(frames, frame)
            end

            local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
            cc.AnimationCache:getInstance():addAnimation(animation, key)
        end

        local  function readAniams()
            local fishFrameMoveNum =
            {
                16,12,24,
                24,24,25,
                12,10,12,
                60,20,24,
                16,24,12,
                24,20,24,
                24,24,9,
                9,20,15,
                15,8,1
            }

            local fishFrameDeadNum =
            {
                5,3,3,
                10,3,6,
                3,6,4,
                7,4,4,
                4,3,6,
                6,4,3,
                4,20,9,
                15,8,2
            }

            local frames = {}
            --鱼游动动画
            for i=1, g_var(cmd).Fish_MOVE_TYPE_NUM do
                local actionTime = 0.09
                frames = {}
                local num = fishFrameMoveNum[i]
                for j=1,num do
                    local frameName = string.format("fish%d_%02d.png",i,j) --fish2_01  fish14_16
                  --  ----print("frameName is =========================================================="..frameName)
                    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
                    table.insert(frames, frame)
                end

                local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                local key = string.format("animation_fish_move%d", i)
                cc.AnimationCache:getInstance():addAnimation(animation, key)

                --最后一个加载特殊的
                if i == g_var(cmd).Fish_MOVE_TYPE_NUM then
                    frames = {}
                    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("fish24.png") 
                    table.insert(frames, frame)

                    local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                    local key = string.format("animation_fish_move%d", i+1)
                    cc.AnimationCache:getInstance():addAnimation(animation, key)
                end
            end

            --鱼死亡动画
            for i=1,g_var(cmd).Fish_DEAD_TYPE_NUM do
                frames = {}
                local actionTime = 0.1
                local num = fishFrameDeadNum[i]

                for j=1,num do
                    local frameName = string.format("fish%d_d_%02d.png",i,j)  --    fish2_d_01  fish23_d_01
                    -- ----print("load dead frameName : ",frameName)
                    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
                    table.insert(frames, frame)
                end

                local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                local key = string.format("animation_fish_dead%d", i)

                cc.AnimationCache:getInstance():addAnimation(animation, key)
                -- if i == 3 then error("stiop") end
            end

            ----加载子弹动画
            for i=1,10 do
                frames = {}
                local actionTime = 0.5
                for j=1,2 do
                    local frameName = string.format("bullet1_norm%d_%02d.png",i,j)
                    ----print("load bullet frameName : ",frameName)
                    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
                    table.insert(frames, frame)
                end

                local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                local key = string.format("animation_bullet1_norm%d",i)

                cc.AnimationCache:getInstance():addAnimation(animation, key)
         
            end

            for i=1,10 do
                frames = {}
                local actionTime = 0.5
                for j=1,2 do
                    local frameName = string.format("bullet2_norm%d_%02d.png",i,j)
                    ----print("load bullet frameName : ",frameName)
                    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
                    table.insert(frames, frame)
                end

                local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                local key = string.format("animation_bullet2_norm%d",i)

                cc.AnimationCache:getInstance():addAnimation(animation, key)
         
            end

            for i=1,10 do
                frames = {}
                local actionTime = 0.5
                for j=1,2 do
                    local frameName = string.format("bullet3_norm%d_%20d.png",i,j)
                    ----print("load bullet frameName : ",frameName)
                    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
                    table.insert(frames, frame)
                end

                local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                local key = string.format("animation_bullet3_norm%d",i)

                cc.AnimationCache:getInstance():addAnimation(animation, key)
         
            end

            for i=1,10 do
                frames = {}
                local actionTime = 0.5
                for j=1,2 do
                    local frameName = string.format("bullet4_norm%d_%02d.png",i,j)
                    ----print("load bullet frameName : ",frameName)
                    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
                    table.insert(frames, frame)
                end

                local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                local key = string.format("animation_bullet4_norm%d",i)

                cc.AnimationCache:getInstance():addAnimation(animation, key)
         
            end

            --加载特殊子弹
            for i=1, 4 do
                frames = {}
                local actionTime = 0.5
                for j=1, 2 do
                    local frameName = string.format("bullet%d_ion_%02d.png",i,j) -- bullet2_ion_01.png
                    ----print("load bullet sp frameName : ",frameName)
                    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
                    table.insert(frames, frame)
                end

                local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                local key = string.format("animation_spbullet_norm%d",i)

                cc.AnimationCache:getInstance():addAnimation(animation, key)
            end

            --金币图
            frames = {}
            for i=1, 12 do 
                local actionTime = 0.08
                local frameName = string.format("coin2_%02d.png",i) -- coin2_01.png
                local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
                frames[i] = frame

                if i == 12 then
                    local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                    local key = "goldAnim"

                    cc.AnimationCache:getInstance():addAnimation(animation, key)
                end
            end

            frames = {}
            for i=1, 10 do 
                local actionTime = 0.08
                local frameName = string.format("bingo_%02d.png",i) -- bingo__01.png
                local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
                frames[i] = frame

                if i == 10 then
                    local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                    local key = "bingoAnim"

                    cc.AnimationCache:getInstance():addAnimation(animation, key)
                end
            end

            frames = {}
            for i=1, 2 do 
                local actionTime = 0.1
                local frameName = string.format("wave_%d.png",i)
                local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
                frames[i] = frame

                if i == 2 then
                    local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
                    local key = "waveAnim"

                    cc.AnimationCache:getInstance():addAnimation(animation, key)
                end
            end
            readAnimation("boom", "BombAnim", 32,0.1,2);
            readAnimation("boom_darts", "BombDartsAnim", 33,0.03,1);
            readAnimation("blue", "BlueIceAnim", 22,0.03,2);
            readAnimation("watch_", "watchAnim", 24, 0.08,1);
        end

        local function imageLoaded( )
            m_nImageOffset = m_nImageOffset + 1
            ----print("m_nImageOffset---------------,",m_nImageOffset)
            if m_nImageOffset<=#newPng then 
                cc.SpriteFrameCache:getInstance():addSpriteFrames("fish/"..newPlist[m_nImageOffset])
                cc.Director:getInstance():getTextureCache():addImageAsync("fish/"..newPng[m_nImageOffset], imageLoaded)
            else
                readAniams()
            end
           
        end

        cc.SpriteFrameCache:getInstance():addSpriteFrames("game_res/gunbullet.plist")
        cc.Director:getInstance():getTextureCache():addImageAsync("game_res/gunbullet.png", imageLoaded)

    end
    local co = coroutine.create(load)
    local state,var = coroutine.resume(co)
    ----print("var----------------",state,var)
    ----print("coroutine.status()---",coroutine.status(co))
end



return mycoroutine