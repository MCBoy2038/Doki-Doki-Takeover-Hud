--[[

CREDITS:
Script Created By MinecraftBoy2038
Modified By Zaxh#9092 (Made the script more accurate from the original ddto+ source code) 
Graident Lua Timebar by Betopia#5677 (Fixed Character Change by Aaron ♡#0001, luv u)
PlayAsDad by Kevin Kuntz
NPS logic made by beihu(北狐丶逐梦) https://b23.tv/gxqO0GH
Lane overlay/underlay by Nox#5005
HUD Originated By DDTO+
Please credit me if you are using this hud

]]

-- SETTINGS --
local judgementCounter = false -- Do you want to enable the judgement counter? [true/false]
local npsEnabled = false -- Do you want to enable NPS? (Notes per second) [true/false]
local laneUnderlay = false -- Do you want to enable the lane underlay? [true/false]
local laneTransparency = 0.3 -- Set the underlay on how transparent it is. Max 1
local mirrorMode = false -- Do you want to play as the opponent? [true/false]
local coolGameplay = false -- Do you want to enable coolGameplay?? lol [true/false]
local gfCountdown = false -- Do you want to enable gfCountdown?? [true/false] (IMPORTANT: THIS ONLY WORKS IF YOU HAVE THE GF FROM DDTO+)

local onlyBFSongs = {'songName1', 'songName2'}

-- CODE N SUCH --
local nps = 0
local early = 0
local late = 0
local reduce = true
local npsMax = 0
local maxCombo = 0
local botplaySine = 0
local pixelShitPart1 = ''
local pixelShitPart2 = ''
local altSuffix = ''
local glitchSuffix = '-glitch'

function onCreate()
  if judgementCounter then
      makeLuaText('judgementCounter', '', screenWidth, 20, 0)
      setTextSize('judgementCounter', 20)
      setTextBorder('judgementCounter', 2, '000000')
      setProperty('judgementCounter.borderQuality', 2)
      setTextFont('judgementCounter', 'Aller_Rg.ttf')
      screenCenter('judgementCounter', 'Y')
      setProperty('judgementCounter.y', getProperty('judgementCounter.y') - 50)
      setTextAlignment('judgementCounter', 'left')
      addLuaText('judgementCounter')
  end

  if coolGameplay then
      makeAnimatedLuaSprite('hueh231', 'coolgameplay')
      addAnimationByPrefix('hueh231', 'idle', 'Symbol', 24, true)
      playAnim('hueh231', 'idle')
      setObjectCamera('hueh231', 'hud')
      addLuaSprite('hueh231', true)
  end

  if laneUnderlay then
      makeLuaSprite('laneunderlayOpponent', '', 70, 0)
      makeGraphic('laneunderlayOpponent', 500, screenHeight * 2, '000000')
      setProperty('laneunderlayOpponent.alpha', laneTransparency)
      setObjectCamera('laneunderlayOpponent', 'hud')
      screenCenter('laneunderlayOpponent', 'Y')
      addLuaSprite('laneunderlayOpponent')

      makeLuaSprite('laneunderlay', '', 70 + (screenWidth / 2), 0)
      makeGraphic('laneunderlay', 500, screenHeight * 2, '000000')
      setProperty('laneunderlay.alpha', laneTransparency)
      setObjectCamera('laneunderlay', 'hud')
      screenCenter('laneunderlay', 'Y')
      addLuaSprite('laneunderlay')
  end

   makeLuaText('practiceTxt', 'PRACTICE MODE', 0, 0)
   setTextSize('practiceTxt', 32)
   setTextFont('practiceTxt', 'riffic.ttf')
   screenCenter('practiceTxt', 'X')
   setTextAlignment('practiceTxt', 'center')
   setProperty('practiceTxt.visible', false)
   setTextBorder('practiceTxt', 1.25, '000000')
   addLuaText('practiceTxt')

  -- NEED HELP FOR THIS ONE LOL

   if earlyLate then
      makeLuaText('currentTimingShown', '', 0, 0, 0)
      setTextSize('currentTimingShown', 28)
      setObjectCamera('currentTimingShown', '')
      setTextBorder('currentTimingShown', 1.25, '000000')
      setTextFont('currentTimingShown', 'riffic.ttf')
      addLuaText('currentTimingShown')
  end

   makeLuaSprite('timeBarBack', 'timeBar')
   setObjectCamera('timeBarBack', 'hud')
   addLuaSprite('timeBarBack')

   makeLuaSprite('ready', pixelShitPart1..'ready'..pixelShitPart2)
   setObjectCamera('ready', 'hud')
   if not isPixel then
     setGraphicSize('ready', getProperty('ready.width') * 0.6)
    else
     setGraphicSize('ready', getProperty('ready.width') * 6)
   end
   screenCenter('ready')
   setProperty('ready.alpha', 0)
   addLuaSprite('ready')

   makeLuaSprite('set', pixelShitPart1..'set'..pixelShitPart2)
   setObjectCamera('set', 'hud')
   if not isPixel then
     setGraphicSize('set', getProperty('set.width') * 0.6)
    else
     setGraphicSize('set', getProperty('set.width') * 6)
   end
   screenCenter('set')
   setProperty('set.alpha', 0)
   addLuaSprite('set')

   makeLuaSprite('go', pixelShitPart1..'go'..pixelShitPart2)
   setObjectCamera('go', 'hud')
   if not isPixel then
     setGraphicSize('go', getProperty('go.width') * 0.6)
    else
     setGraphicSize('go', getProperty('go.width') * 6)
   end
   screenCenter('go')
   setProperty('go.alpha', 0)
   addLuaSprite('go')
end

function onCreatePost()
   if mirrorMode then
     if not middlescroll then
	for i = 0, getProperty('strumLineNotes.members.length') do
	   local name = i >= 4 and 'Opponent' or 'Player'
	     setProperty('strumLineNotes.members['..i..'].x', _G['default'..name..'StrumX'..i % 4])
	     setProperty('strumLineNotes.members['..i..'].y', _G['default'..name..'StrumY'..i % 4])
	 end
     end

     for i = 0, getProperty('unspawnNotes.length')-1 do
        setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)
        setPropertyFromGroup('unspawnNotes', i, 'noMissAnimation', true)
        setPropertyFromGroup('unspawnNotes', i, 'mustPress', not getPropertyFromGroup('unspawnNotes', i, 'mustPress'))
       end
   end
  isPixel = getPropertyFromClass('PlayState', 'isPixelStage')
   changeGradientBar()

   setProperty('scoreTxt.visible', false)

   makeLuaText('ddtoScoreTxt', '')
   setTextFont('ddtoScoreTxt', 'Aller_Rg.ttf')
   setTextBorder('ddtoScoreTxt', 1.25, '000000')
   setTextSize('ddtoScoreTxt', 20)
   setProperty('ddtoScoreTxt.x', getProperty('scoreTxt.x'))
   setProperty('ddtoScoreTxt.y', getProperty('healthBarBG.y') + 48)
   setTextWidth('ddtoScoreTxt', getTextWidth('scoreTxt'))
   setTextAlignment('ddtoScoreTxt', 'CENTER')
   addLuaText('ddtoScoreTxt', true)

   setTextSize('timeTxt', 18)
   setProperty('timeTxt.y', getProperty('timeBarBG.y'))
   setProperty('timeBarBack.x', getProperty('timeBarBG.x'))
   setProperty('timeBarBack.y', getProperty('timeBarBG.y'))
   setProperty('practiceTxt.y', defaultPlayerStrumY0 + 30)
   setTextFont('botplayTxt', 'riffic.ttf')
 
   -- why psych's timeBarBG a mess :(
   setObjectOrder('timeBarBack', getObjectOrder('timeBarBG') + 1)
   setObjectOrder('practiceTxt', getObjectOrder('botplayTxt'))
   setObjectOrder('timeBar', getObjectOrder('timeBarBack') + 1)
   setObjectOrder('timeTxt', getObjectOrder('timeBar') + 1)
   setProperty('timeBarBack.alpha', 0)

   if rating == 0 then
       if npsEnabled then
         setProperty('scoreTxt.text', 'NPS: 0 (Max: 0) | Score: 0 | Breaks: 0 | Rating: ?')
         setTextString('ddtoScoreTxt', 'NPS: 0 (Max: 0) | Score: 0 | Breaks: 0 | Rating: ?')
        else
         setProperty('scoreTxt.text', 'Score: 0 | Breaks: 0 | Rating: ?')
         setTextString('ddtoScoreTxt', 'Score: 0 | Breaks: 0 | Rating: ?')
       end
   end

 
   for i = 1, #onlyBFSongs do
      if songName == onlyBFSongs[i] and mirrorMode then
        mirrorMode = false
      end
   end
end

function onCountdownTick(swagCounter)
     if swagCounter == 0 then
       if isPixel and curStage:lower():find('evil') then
          setCountdown(0, 'evil')
       elseif isPixel then
          setCountdown(0, 'pixel')
       else
          setCountdown(0)
       end

     elseif swagCounter == 1 then
       if isPixel and curStage:lower():lower():find('evil') then
          setCountdown(1, 'evil')
       elseif isPixel then
          setCountdown(1, 'pixel')
       else
          setCountdown(1)
       end

     elseif swagCounter == 2 then 
       if isPixel and curStage:lower():lower():find('evil') then
          setCountdown(2, 'evil')
       elseif isPixel then
          setCountdown(2, 'pixel')
       else
          setCountdown(2)
       end

     elseif swagCounter == 3 then
       if isPixel and curStage:lower():find('evil') then
          setCountdown(3, 'evil')
       elseif isPixel then
          setCountdown(3, 'pixel')
       else
          setCountdown(3)
       end
    end
end

function setCountdown(swagCounter, countdownStyle)
  if swagCounter == 0 then
     if gfCountdown and checkAnimationExists('gf', 'countdownThree') then
         playAnim('gf', 'countdownThree')
     end

  elseif swagCounter == 1 then
        setProperty('ready.alpha', 1)
        doTweenAlpha('ready', 'ready', 0, crochet / 1000, 'cubeInOut')
     if gfCountdown and checkAnimationExists('gf', 'countdownTwo') then
         playAnim('gf', 'countdownTwo')
     end

  elseif swagCounter == 2 then
        setProperty('set.alpha', 1)
        doTweenAlpha('set', 'set', 0, crochet / 1000, 'cubeInOut')
     if gfCountdown and checkAnimationExists('gf', 'countdownOne') then
         playAnim('gf', 'countdownOne')
     end

  elseif swagCounter == 3 then
        setProperty('go.alpha', 1)
        doTweenAlpha('go', 'go', 0, crochet / 1000, 'cubeInOut')
     if gfCountdown and checkAnimationExists('gf', 'countdownGo') then
         playAnim('gf', 'countdownGo')
     end
  end

    if countdownStyle == 'pixel' then
      if swagCounter == 1 then
        loadGraphic('ready', 'pixelUI/ready-pixel')
        setGraphicSize('ready', getProperty('ready.width') * 6)
        setProperty('ready.antialiasing', false)
        screenCenter('ready')

      elseif swagCounter == 2 then
        loadGraphic('set', 'pixelUI/set-pixel')
        setGraphicSize('set', getProperty('set.width') * 6)
        setProperty('set.antialiasing', false)
        screenCenter('set')

      elseif swagCounter == 3 then
        loadGraphic('go', 'pixelUI/date-pixel')
        setGraphicSize('go', getProperty('go.width') * 6)
        setProperty('go.antialiasing', false)
        screenCenter('go')
      end

    elseif countdownStyle == 'evil' then
       setProperty('introSoundsSuffix', '-glitch')
      if swagCounter == 1 then
        loadGraphic('ready', 'pixelUI/ready-pixel')
        setGraphicSize('ready', getProperty('ready.width') * 6)
        setProperty('ready.antialiasing', false)
        screenCenter('ready')

      elseif swagCounter == 2 then
        loadGraphic('set', 'pixelUI/set-pixel')
        setGraphicSize('set', getProperty('set.width') * 6)
        setProperty('set.antialiasing', false)
        screenCenter('set')

      elseif swagCounter == 3 then
        loadGraphic('go', 'pixelUI/demise-date')
        setGraphicSize('go', getProperty('go.width') * 6)
        setProperty('go.antialiasing', false)
        screenCenter('go')
        end
    end
end

function onTweenCompleted(tag)
   if tag == 'ready' then
     removeLuaSprite('ready')
   elseif tag == 'set' then
     removeLuaSprite('set')
   elseif tag == 'go' then
     removeLuaSprite('go')
    end
end

function GetDataNote(id, var)
    return getPropertyFromGroup('notes', id, var)
end

function onUpdate()
  if middlescroll then
      screenCenter('laneunderlay', 'X')
      setProperty('laneunderlayOpponent.alpha', 0)
  end

  isPixel = getPropertyFromClass('PlayState', 'isPixelStage')

   setProperty('countdownReady.visible', false)
   setProperty('countdownSet.visible', false)
   setProperty('countdownGo.visible', false)

    if judgementCounter then
         setProperty('judgementCounter.text', 'Doki: '..getProperty('sicks')..'\nGood: '..getProperty('goods')..'\nOk: '..getProperty('bads')..'\nNo: '..getProperty('shits')..'\nMiss: '..getProperty('songMisses'));

    end

    beforeScore = 'Score: 0 | Breaks: 0 | Rating: ?'
    finalScore = 'Score: '..score..' | Breaks: '..misses..' | Rating: '..ratingName..' ('..round(rating * 100,2)..'%) - '..ratingFC
    beforeScoreNps = 'NPS: 0 (Max: 0) | Score: 0 | Breaks: 0 | Rating: ?'
    finalScoreNps = 'NPS: '..nps..' (Max: '..npsMax..') | Score: '..score..' | Breaks: '..misses..' | Rating: '..ratingName..' ('..round(getProperty('ratingPercent') * 100 , 2)..'%) - '..ratingFC

    if rating == 0 then
      if npsEnabled then
        setProperty('scoreTxt.text', 'NPS: 0 (Max: 0) | Score: 0 | Breaks: 0 | Rating: ?')
        setProperty('ddtoScoreTxt.text', 'NPS: 0 (Max: 0) | Score: 0 | Breaks: 0 | Rating: ?')
       else
        setProperty('scoreTxt.text', 'Score: 0 | Breaks: 0 | Rating: ?')
        setProperty('ddtoScoreTxt.text', 'Score: 0 | Breaks: 0 | Rating: ?')
      end
    else
      if npsEnabled then
        setProperty('scoreTxt.text', finalScoreNps)
        setProperty('ddtoScoreTxt.text', finalScoreNps)
       else
        setProperty('scoreTxt.text', finalScore)
        setProperty('ddtoScoreTxt.text', finalScore)
        end
    end

    if nps > 0 and reduce == true then
        reduce = false
        runTimer('reduce nps', 1 / nps , 1)	
    end
        if nps == 0 then
        reduce = true
    end

    if nps > npsMax then
        npsMax = nps
    end

    combo = getProperty('combo')

    if combo > maxCombo then
        maxCombo = combo
    end

    if isPixel then
      pixelShitPart1 = 'pixelUI/'
      pixelShitPart2 = '-pixel'
      setTextFont('scoreTxt', getFont('vcr'))
      setTextFont('ddtoScoreTxt', getFont('vcr'))
      setTextFont('timeTxt', getFont('vcr'))
      setTextFont('judgementCounter', getFont('vcr'))
      setTextFont('botplayTxt', getFont('vcr'))
      setTextFont('practiceTxt', getFont('vcr'))
    else
      pixelShitPart1 = ''
      pixelShitPart2 = ''
      setTextFont('scoreTxt', getFont()) 
      setTextFont('ddtoScoreTxt', getFont())
      setTextFont('timeTxt', getFont()) 
      setTextFont('judgementCounter', getFont())
      setTextFont('botplayTxt', getFont('riffic'))
      setTextFont('practiceTxt', getFont('riffic'))
    end

    if getProperty('cpuControlled') and getProperty('practiceMode') then
      setProperty('practiceTxt.visible', false)
      setProperty('botplayTxt.visible', true)
    elseif not getProperty('cpuControlled') and getProperty('practiceMode') then
      setProperty('practiceTxt.visible', true)
      setProperty('botplayTxt.visible', false)
    end

    if rating >= 0.9935 then
        ratingName = 'AAAAA'
    elseif rating >= 0.980 then
        ratingName = 'AAAA:'
    elseif rating >= 0.970 then
        ratingName = 'AAAA.'
    elseif rating >= 0.955 then
        ratingName = 'AAAA'
    elseif rating >= 0.90 then
        ratingName = 'AAA:'
    elseif rating >= 0.80 then
        ratingName = 'AAA.'
    elseif rating >= 0.70 then
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
    elseif rating < 60 then
        ratingName = 'D'
    else
        ratingName = 'D'
    end

    if getProperty('songMisses') == 0 and getProperty('bads') == 0 and getProperty('shits') == 0 and getProperty('goods') == 0 then
      ratingFC = 'SFC' -- Sick Full Combo
    elseif getProperty('songMisses') == 0 and getProperty('bads') == 0 and getProperty('shits') == 0 and getProperty('goods') >= 1 then
      ratingFC = 'GFC' -- Good Full Combo
    elseif getProperty('songMisses') == 0 then
      ratingFC = 'FC' -- Full Combo
    elseif getProperty('songMisses') < 10 then
      ratingFC = 'SDCB' -- Single Digit Combo Break
    else
      ratingFC = 'Clear'
    end
end

function onUpdatePost(elapsed)
  botplaySine = botplaySine + 180 * elapsed

    setProperty('practiceTxt.alpha', 1 - math.sin(math.pi * botplaySine / 180))

    if playbackRate == 1 then
       setTextString('timeTxt', songName..' ('..formatTime(remainingTime())..')')
     else
       setTextString('timeTxt', songName..' ('..playbackRate..'x) ('..formatTime(remainingTime())..')')
    end

   if mirrorMode then
	setProperty('healthBar.value', 2 - getHealth())
	addHaxeLibrary('FlxMath', 'flixel.math')
	runHaxeCode([[
	var iconOffset = 26;
	game.iconP1.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * game.iconP1.scale.x - 150) / 2 - iconOffset;
	game.iconP2.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * game.iconP2.scale.x) / 2 - iconOffset * 2;
	var iconArray = [game.iconP1, game.iconP2];
	    for (icon in iconArray) {
		var i = iconArray.indexOf(icon);
		icon.animation.curAnim.curFrame = (i < 1 ? game.healthBar.percent < 20 : game.healthBar.percent > 80) ? 1 : 0;
	    }
	]])
    end
end

function onEvent(name, value1, value2)
  if name == 'Change Character' then
   changeGradientBar()
    end
end
    
function onSongStart()
   -- 99.9% accurate lmao
   doTweenAlpha('timeTween', 'timeBarBack', 1, 0.5, 'circOut')
end

function noteMiss(id, noteData, noteType, isSustainNote)
   if mirrorMode == true then
    animToPlay = getProperty('singAnimations')[noteData + 1]
     char = 'dad'
     if not (getPropertyFromGroup('notes', id, 'noMissAnimation')) then
        if checkAnimationExists(char, animToPlay, 'miss') then
             playAnim(char, animToPlay..'miss', true)
          else
	     playAnim(char, animToPlay, true)
            end
        end
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
   if mirrorMode then
     animToPlay = getProperty('singAnimations')[noteData + 1]
     char = 'boyfriend'
          if noteType == 'GF Sing' then
             playAnim('gf', animToPlay, true)
             char = 'gf'
          end

          if noteType == 'Hey!' then
             playAnim(char, 'hey', true)
             setProperty(char..'.specialAnim', true)
             setProperty(char..'.heyTimer', 0.6)
          end

          if noteType == 'Alt Animation' then
             if checkAnimationExists(char, animToPlay, '-alt') then
                 playAnim(char, animToPlay..'-alt', true)
             else
                 playAnim(char, animToPlay, true)
              end
          end

          if noteType == 'No Animation' then
              playAnim(char, 'idle')
          end

          if noteType == '' then
             playAnim(char, animToPlay, true)
          end

         if gfSection then
            playAnim('gf', animToPlay, true)
            char = 'gf'
         elseif altAnim then
            if checkAnimationExists(char, animToPlay, '-alt') then
               playAnim(char, animToPlay..'-alt', true)
             else
               playAnim(char, animToPlay, true)
             end
         end
       setProperty(char..'.holdTimer', 0)
    end
end

function goodNoteHit(noteID, noteData, noteType, isSustainNote)
    local ratingOffset = getPropertyFromClass('ClientPrefs', 'ratingOffset')
    local Rating = (getPropertyFromGroup('notes', noteID, 'strumTime') - getSongPosition() + ratingOffset)
    if not isSustainNote then
      if not botPlay or not getProperty('cpuControlled') then
        setProperty('ddtoScoreTxt.scale.x', 1.075)
        setProperty('ddtoScoreTxt.scale.y', 1.075)
        cancelTween('ddtoScoreTxtTweenX')
        cancelTween('ddtoScoreTxtTweenY')
        doTweenX('ddtoScoreTxtTweenX', 'ddtoScoreTxt.scale', 1, 0.2)
        doTweenY('ddtoScoreTxtTweenY', 'ddtoScoreTxt.scale', 1, 0.2)
      end
        nps = nps + 1
    end

    if mirrorMode then
     animToPlay = getProperty('singAnimations')[noteData + 1]
       char = 'dad'
         if noteType == 'GF Sing' then
            playAnim('gf', animToPlay, true)
            char = 'gf'
         end

         if noteType == 'Hey!' then
              playAnim(char, 'hey', true)
              setProperty(char..'.specialAnim', true)
              setProperty(char..'.heyTimer', 0.6)
         end

         if noteType == 'Alt Animation' then
            if checkAnimationExists(char, animToPlay, '-alt') then
               playAnim(char, animToPlay..'-alt', true)
             else
               playAnim(char, animToPlay, true)
             end
         end

         if noteType == 'No Animation' then
             playAnim(char, 'idle')
         end

         if noteType == '' then
              playAnim(char, animToPlay, true)
         end

         if gfSection then
            playAnim('gf', animToPlay, true)
            char = 'gf'
         elseif altAnim then
            if checkAnimationExists(char, animToPlay, '-alt') then
               playAnim(char, animToPlay..'-alt', true)
             else
               playAnim(char, animToPlay, true)
             end
         end
      setProperty(char..'.holdTimer', 0)
    end
end

function changeGradientBar(colorShitDad, colorShitBF)
    addHaxeLibrary('Std')
  if colorShitBF == nil then
    runHaxeCode([[
        var wawa = [];
        for (i in game.dad.healthColorArray) wawa.push(StringTools.hex(i, 2));
        var wawa2 = [];
        for (i in game.boyfriend.healthColorArray) wawa2.push(StringTools.hex(i, 2));
        game.timeBar.createGradientBar([0x0], [Std.parseInt('0xFF' + wawa2.join('')), Std.parseInt('0xFF' + wawa.join(''))]);
    ]])
  else
    runHaxeCode([[
        var wawa = [];
        for (i in game.dad.healthColorArray) wawa.push(StringTools.hex(i, 2));
        var wawa2 = [];
        for (i in game.boyfriend.healthColorArray) wawa2.push(StringTools.hex(i, 2));
        game.timeBar.createGradientBar([0x0], [Std.parseInt('0xFF' + ']]..colorShitBF..[['), Std.parseInt('0xFF' + wawa.join(''))]);
    ]])
  end
  if colorShitDad == nil then
    runHaxeCode([[
        var wawa = [];
        for (i in game.dad.healthColorArray) wawa.push(StringTools.hex(i, 2));
        var wawa2 = [];
        for (i in game.boyfriend.healthColorArray) wawa2.push(StringTools.hex(i, 2));
        game.timeBar.createGradientBar([0x0], [Std.parseInt('0xFF' + wawa2.join('')), Std.parseInt('0xFF' + wawa.join(''))]);
    ]])
  else
    runHaxeCode([[
        var wawa = [];
        for (i in game.dad.healthColorArray) wawa.push(StringTools.hex(i, 2));
        var wawa2 = [];
        for (i in game.boyfriend.healthColorArray) wawa2.push(StringTools.hex(i, 2));
        game.timeBar.createGradientBar([0x0], [Std.parseInt('0xFF' + wawa2.join('')), Std.parseInt('0xFF' + ']]..colorShitDad..[[')]);
    ]])
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'reduce nps'  and nps > 0 then
        runTimer('reduce nps', 1/nps, 1)
        nps = nps - 1
    end
end

function getHealthColor(chr)
	return getColorFromHex(rgbToHex(getProperty(chr .. ".healthColorArray")))
end

function rgbToHex(array)
	return string.format('%.2x%.2x%.2x', array[1], array[2], array[3])
end

function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function formatTime(millisecond)
    local seconds = math.floor(millisecond / 1000)
    return string.format("%01d:%02d", (seconds / 60) % 60, seconds % 60)  
end

function remainingTime()
    return getProperty('songLength') - (getSongPosition() - noteOffset)
end

function checkAnimationExists(char, anim, suffix)
    if suffix == nil then
      return runHaxeCode("game.]]..char..[[.anim.exists(']]..anim..[[');")
     else
      return runHaxeCode("game.]]..char..[[.anim.exists(']]..anim..[[' + ']]..suffix..[[');")
    end
      --return runHaxeCode("game.]]..char..[[.animOffsets.exists(']]..anim..[[' + ']]..animSuffix..[[');")
end

language = 'en-US'

function getFont(type)
    font = ''
   if type == nil or type == '' then type = 'aller' end
      if type == 'aller' then
        if language == 'ru-RU' then
          font = 'Ubuntu-Bold.ttf'
        elseif language == 'jp-JP' then
          font = 'NotoSansJP-Medium.otf'
        else
          font = 'Aller_Rg.ttf'
        end
      elseif type == 'riffic' then
        if language == 'ru-RU' then
          font = 'Ubuntu-Bold.ttf'
        elseif language == 'jp-JP' then
          font = 'NotoSansJP-Medium.otf'
        else
          font = 'riffic.ttf'
        end
      elseif type == 'halogen' then
        if language == 'ru-RU' then
          font = 'Ubuntu-Bold.ttf'
        elseif language == 'jp-JP' then
          font = 'NotoSansJP-Medium.otf'
        else
          font = 'Halogen.otf'
        end
      elseif type == 'grotesk' then
        if language == 'ru-RU' then
          font = 'Ubuntu-Bold.ttf'
        elseif language == 'jp-JP' then
          font = 'NotoSansJP-Medium.otf'
        else
          font = 'HKGrotesk-Bold.otf'
        end
      elseif type == 'pixel' then
          font = 'LanaPixel.ttf'
      elseif type == 'dos' then
        if language == 'ru-RU' then
          font = 'Ubuntu-Bold.ttf'
        elseif language == 'jp-JP' then
          font = 'NotoSansJP-Medium.otf'
        else
          font = 'Perfect DOS VGA 437 Win.ttf'
        end
      elseif type == 'vcr' then
        if language == 'ru-RU' then
          font = 'Ubuntu-Bold.ttf'
        elseif language == 'jp-JP' then
          font = 'NotoSansJP-Medium.otf'
        else
          font = 'vcr.ttf'
        end
      elseif type == 'waifu' then
        if language == 'en-US' then
          font = 'CyberpunkWaifus.ttf'
        else
          font = 'LanaPixel.ttf'
        end
    end
   return font;
end