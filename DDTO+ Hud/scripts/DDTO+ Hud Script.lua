--[[

CREDITS:
Script Created By MinecraftBoy2038
Graident Lua Timebar by Betopia#5677
NPS logic made by beihu(北狐丶逐梦) https://b23.tv/gxqO0GH
Lane Overlay by Nox#5005
HUD Originated By DDTO+
Please credit me if you are using this hud

]]

-- SETTINGS --
local judgementCounter = false -- Do you want to enable the judgement counter? [true/false]
local npsEnabled = false -- Do you want to enable NPS? [true/false]
local noteUnderlayValue = 0 -- Set the overlay on how transparent it is. Max 1 (Example: 0.5)

-- END OF SETTINGS --

-- Mess around with the code if you know what you're doing

-- NPS SHIT -- 
local nps = 0
local reduce = true
local npsmax = 0


function onCreatePost()
    -- Pixel thing
    isPixel = getPropertyFromClass('PlayState', 'isPixelStage')

    -- Score Text
    makeLuaText('ddtoScore', 'Score: 0 | Breaks: 0 | Rating: ?' ,0, 0, 0)
    
    setProperty('scoreTxt.visible', false)
    setTextFont('ddtoScore','Aller_rg.ttf')

    if isPixel == true then
        setTextFont('ddtoScore','vcr.ttf')
    end

    setTextBorder('ddtoScore', 2, '000000')
    setProperty('ddtoScore.y', getProperty('scoreTxt.y') + 12)
	setProperty('ddtoScore.x', getProperty('scoreTxt.x'))
	setTextAlignment('ddtoScore','CENTER')
    setTextWidth('ddtoScore', getTextWidth('scoreTxt'))
	setTextSize('ddtoScore', 20)
	addLuaText('ddtoScore')

    -- Judgement Counter
    if judgementCounter then
        makeLuaText('judgementCounterTxt', '', screenWidth, 20, 0)
        setTextSize('judgementCounterTxt', 20)
        setTextBorder('judgementCounterTxt', 2, '000000')
        screenCenter('judgementCounterTxt', 'Y')
        setTextAlignment('judgementCounterTxt', 'left')
        addLuaText('judgementCounterTxt')
        setObjectCamera('judgementCounterTxt', 'hud')
        setTextFont('judgementCounterTxt', 'Aller_rg.ttf')
        
        if isPixel == true then
            setTextFont('judgementCounterTxt','vcr.ttf')
        end
    end

    -- Graident Timebar by Betopia#5677
    addHaxeLibrary('Std')
    runHaxeCode([[
        var wawa = [];
        for (i in game.dad.healthColorArray) wawa.push(StringTools.hex(i, 2));
        var wawa2 = [];
        for (i in game.boyfriend.healthColorArray) wawa2.push(StringTools.hex(i, 2));
        game.timeBar.createGradientBar([0x0], [Std.parseInt('0xFF' + wawa2.join('')), Std.parseInt('0xFF' + wawa.join(''))]);
    ]])

    -- Time Text
    setProperty('timeTxt.visible', false)
    makeLuaText('ddtoTimeText', 'rip', 0, 0)
    setObjectCamera('ddtoTimeText', 'hud', true)
    setProperty('ddtoTimeText.alpha', 0)
    setTextSize('ddtoTimeText', 18)
    setTextFont('ddtoTimeText','Aller_rg.ttf')

    if isPixel == true then
        setTextFont('ddtoTimeText','vcr.ttf')
    end

    addLuaText('ddtoTimeText', true)
    setProperty('ddtoTimeText.y', getProperty('timeBar.y')-4)

end

function onCreate()
    -- Lane Overlay by Nox#5005 (edited by MinecraftBoy2038)
    if middlescroll then
        makeLuaSprite('laneOverlayMS', '...', 405, 0)
        setProperty('laneOverlay.alpha', 0)
        setProperty('laneOverlay2.alpha', 0)
        makeGraphic('laneOverlayMS', 460, 800, '000000')
        addLuaSprite('laneOverlayMS')
        setProperty('laneOverlayMS.alpha', noteUnderlayValue)
        setObjectCamera('laneOverlayMS', 'hud')
    else
        makeLuaSprite('laneOverlay', '...', 725, 0)
        makeGraphic('laneOverlay', 460, 800, '000000')
        addLuaSprite('laneOverlay')
        setProperty('laneOverlay.alpha', noteUnderlayValue)
        setObjectCamera('laneOverlay', 'hud')
        makeLuaSprite('laneOverlay2', '...', 83, 0)
        makeGraphic('laneOverlay2', 460, 800, '000000')
        addLuaSprite('laneOverlay2')
        setProperty('laneOverlay2.alpha', noteUnderlayValue)
        setObjectCamera('laneOverlay2', 'hud')
        setProperty('laneOverlayMS.alpha', 0)
    end
end

function onUpdatePost()
    -- Judgement Counter
    if judgementCounter then
        setTextString('judgementCounterTxt', 'Doki: '..getProperty('sicks')..'\nGood: '..getProperty('goods')..'\nOk: '..getProperty('bads')..'\nNo: '..getProperty('shits')..'\nMiss: '..getProperty('songMisses'));
    end
    -- Time Text
    setTextString('ddtoTimeText', songName..' ('..getProperty('timeTxt.text')..')')
    screenCenter('ddtoTimeText', 'x')
end

function onUpdate()

    local BeforeScoreNPS = 'NPS: '..nps..' (Max '.. npsmax ..') | Score: '..score..' | Breaks: '..misses..' | Rating: '..ratingName
    local FinalScoreNPS = 'NPS: '..nps..' (Max '.. npsmax ..') | Score: '..score..' | Breaks: '..misses..' | Rating: '..ratingName..' ('..round(getProperty('ratingPercent') * 100 , 2)..'%) - '..ratingFC..''

    local BeforeScore = 'Score: '..score..' | Breaks: '..misses..' | Rating: '..ratingName
    local AfterScore = 'Score: '..score..' | Breaks: '..misses..' | Rating: '..ratingName..' ('..round(getProperty('ratingPercent') * 100 , 2)..'%) - '..ratingFC..''

    if ratingName == '?' and npsEnabled == true then
        setTextString('ddtoScore', BeforeScoreNPS)
    elseif npsEnabled == true then
        setTextString('ddtoScore', FinalScoreNPS)  
    end

    if ratingName == '?' and npsEnabled == false then
        setTextString('ddtoScore', BeforeScore)
    elseif npsEnabled == false then
        setTextString('ddtoScore', AfterScore)  
    end

    --NPS logic made by beihu(北狐丶逐梦) https://b23.tv/gxqO0GH
    if nps >0 and reduce == true then
        reduce = false
        runTimer('reduce nps', 1/nps , 1)	
    end
        if nps ==0 then
        reduce = true
    end
    if nps > npsmax then
        npsmax = nps
    end

    if rating >= 0.999935 then
        ratingName = 'AAAAA'
    elseif rating >= 0.99980 then
        ratingName = 'AAAA:'
    elseif rating >= 0.99970 then
        ratingName = 'AAAA.'
    elseif rating >= 0.99955 then
        ratingName = 'AAAA'
    elseif rating >= 0.9990 then
        ratingName = 'AAA:'
    elseif rating >= 0.9980 then
        ratingName = 'AAA.'
    elseif rating >= 0.9970 then
        ratingName = 'AAA'
    elseif rating >= 0.99 then
        ratingName = 'AA:'
    elseif rating >= 0.9650 then
        ratingName = 'AA.'
    elseif rating >= 0.93 then
        ratingName = 'AA'
    elseif rating >= 0.90 then
        ratingName = 'A:'
    elseif rating >= 0.85 then
        ratingName = 'A.'
    elseif rating >= 0.80 then
        ratingName = 'A'
    elseif rating >= 0.70 then
        ratingName = 'B'
    elseif rating >= 0.60 then
        ratingName = 'C'
    elseif rating == 0.00 then
        ratingName = '?' 
    else
        ratingName = 'D'
    end

    -- Psych Engine wants me to do this 
    setProperty('timeBarBG.color', getColorFromHex('853b52'))
end
    
function goodNoteHit(id, noteData, noteType, isSustainNote)
    if  not isSustainNote then
        nps = nps + 1
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    --NPS logic made by beihu(北狐丶逐梦) https://b23.tv/gxqO0GH
    if tag == 'reduce nps'  and nps > 0 then
        runTimer('reduce nps', 1/nps, 1)
        nps = nps - 1
    end
end

function onSongStart()
    -- Time Text
    doTweenAlpha('ddtoTimeTextTween', 'ddtoTimeText', 1, 0.25, circIn)
end

function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end