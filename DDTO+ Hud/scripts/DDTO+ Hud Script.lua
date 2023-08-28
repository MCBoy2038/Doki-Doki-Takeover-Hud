-- HUD OPTIONS --
local precacheAssets = true -- Preloads every images used in the scripts [true/false]
local judgementCounter = false -- Do you want to enable the judgement counter? [true/false]
local npsEnabled = false -- Do you want to enable NPS? (Notes per second) [true/false]
local earlyLate = false -- Do you want enable earlyLate counter? [true/false]
local customFeatures = false -- Do you want enable custom features (exclusive to this script only!) [true/false]

-- OTHER OPTIONS --

local laneUnderlay = false -- Do you want to enable the lane underlay? [true/false]
local laneTransparency = 0.3 -- Set the underlay on how transparent it is. Max 1
local mirrorMode = false -- Do you want to play as the opponent? [true/false]
local coolGameplay = false -- Do you want to enable coolGameplay?? lol [true/false]
local autoPause = true -- Do you want to enable autoPause? [true/false]
local hudWatermark = true -- Do you want to enable the HUD's watermark?? [true/false] (would recommened!!! /j)

-- PAUSE OPTIONS --
local enableCustomPause = true -- Enables the custom pause [true/false]
local secretPause = true -- Enables a secret pause menu style [true/false]
local isAndroid = false -- Are you on mobile/phone?? (MUST enable customPause first) [true/false]

-- SPLASH OPTIONS --
local enableSplash = true -- Do you want to enable Splashes? [true/false]
local enableOpponentSplash = false -- Do you want to opponent enable Splashes? [true/false]

-- HITSOUND OPTIONS --
local enableHitSound = false -- Do you want to enable hit sound? [true/false]
local hitSoundVolume = 0.3 -- hit sound volume (NOTE: hitSound Should enabled first) [0 - 1]
local judgeHitSound = true -- Do you want to judge hit sound? (hitSound depends on sicks, goods, bads NOTE: hitSound Should enabled first) [true/false]


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------- THE CODE ITSELF (mess if you know how things work i guess :/) ------------------------------------------------------------------------------------------------------------------------------

-- HUD variables --
local maxCombo = 0
local earlys = 0
local lates = 0

-- Nps --
local nps = 0
local maxNps = 0
local canDrain = true

-- Botplay --
local botNotes = 0
local botHits = 0
local botScore = 0
local botRating = 0
local botplaySine = 0

local ratingStuff = {
  doki = {
    {'D', 0.50},
    {'C', 0.60},
    {'B', 0.70},
    {'A', 0.80},
    {'A.', 0.85},
    {'A:', 0.90},
    {'AA', 0.93},
    {'AA.', 0.9650},
    {'AA:', 0.990},
    {'AAA', 0.9970},
    {'AAA.', 0.9980},
    {'AAA:', 0.9990},
    {'AAAA', 0.99955},
    {'AAAA.', 0.99970},
    {'AAAA:', 0.99980},
    {'AAAAA', 0.999935},
  },
  default = {},
}

local scoreStuff = {
   doki = {
       sick = {350, 1},
       good = {200, 0.9},
       bad = {0, 0.7},
       shit = {-300, 0.4}
   },
   default = {
       sick = {350, 1},
       good = {200, 0.67},
       bad = {100, 0.34},
       shit = {50, 0}
   }
}

local scoreShit = {}

local isPixel = false
local globalAntialiasing = false
local comboOffset = {}
local judgementString = ''

function onCreate()
    addHaxeLibrary('Std')
    addHaxeLibrary('Type')

    initSaveData('ddtoOptions')
    addOptions()

    isPixel = getPropertyFromClass('PlayState', 'isPixelStage')
    globalAntialiasing = getPropertyFromClass('ClientPrefs', 'globalAntialiasing')
    comboOffset = getPropertyFromClass('ClientPrefs', 'comboOffset')
    ogRatings = getPropertyFromClass('PlayState', 'ratingStuff')

    if autoPause then
      setPropertyFromClass('flixel.FlxG', 'autoPause', false)
    else
      setPropertyFromClass('flixel.FlxG', 'autoPause', true)
    end

    if scoreSystem == 'doki' then
      setRatingData(0, 'score', 350)
      setRatingData(1, 'score', 200)
      setRatingData(2, 'score', 0)
      setRatingData(3, 'score', -300)

      setRatingData(0, 'ratingMod', 1)
      setRatingData(1, 'ratingMod', 0.9)
      setRatingData(2, 'ratingMod', 0.7)
      setRatingData(3, 'ratingMod', 0.4)
    end

    -- compat i guess
    sicks = (version:find('0.7') and getProperty('ratingsData[0].hits') or getProperty('sicks'))
    goods = (version:find('0.7') and getProperty('ratingsData[1].hits') or getProperty('goods'))
    bads = (version:find('0.7') and getProperty('ratingsData[2].hits') or getProperty('bads'))
    shits = (version:find('0.7') and getProperty('ratingsData[3].hits') or getProperty('shits'))

    judgementString = 'Doki: '..sicks..'\nGood: '..goods..'\nOk: '..bads..'\nNo: '..shits..'\nMiss: '..getProperty('songMisses')..'\n'

    if buildTarget == 'android' and not isAndroid then
      isAndroid = true
    end
    
    if getOptionData('judgementCounter') then
      makeLuaText('judgementCounter', '', 0, 20, 0)
      setTextFormat('judgementCounter', (isPixel and getFont('vcr') or getFont('aller')), 20, 'FFFFFF', 'LEFT')
      setTextBorder('judgementCounter', 2, '000000')
      setProperty('judgementCounter.borderQuality', 2)
      setScrollFactor('judgementCounter')
      screenCenter('judgementCounter', 'y')
      setProperty('judgementCounter.visible', not hideHud)
      setProperty('judgementCounter.y', getProperty('judgementCounter.y') - 70)
      if globalAntialiasing then
        setProperty('judgementCounter.antialiasing', not isPixel)
      end
      addLuaText('judgementCounter')
    end 

    if getOptionData('coolGameplay') then
      if getOptionData('precacheAssets') then precacheImage('coolgameplay') end
      makeAnimatedLuaSprite('hueh231', 'coolgameplay')
      addAnimationByPrefix('hueh231', 'idle', 'Symbol', 24, true)
      playAnim('hueh231', 'idle')
      setProperty('hueh231.visible', not hideHud)
      setObjectCamera('hueh231', 'hud')
      addLuaSprite('hueh231', true)
    end
   
    if getOptionData('laneUnderlay') then
      makeLuaSprite('laneunderlayOpponent', '', 70, 0)
      makeGraphic('laneunderlayOpponent', 500, screenHeight * 2, '000000')
      setProperty('laneunderlayOpponent.alpha', getOptionData('laneTransparency'))
      setObjectCamera('laneunderlayOpponent', 'hud')
      screenCenter('laneunderlayOpponent', 'Y')
      setProperty('laneunderlayOpponent.visible', not hideHud)
      addLuaSprite('laneunderlayOpponent')

      makeLuaSprite('laneunderlay', '', 70 + (screenWidth / 2), 0)
      makeGraphic('laneunderlay', 500, screenHeight * 2, '000000')
      setProperty('laneunderlay.alpha', getOptionData('laneTransparency'))
      setObjectCamera('laneunderlay', 'hud')
      screenCenter('laneunderlay', 'Y')
      setProperty('laneunderlay.visible', not hideHud)
      addLuaSprite('laneunderlay')
      if middlescroll then
        screenCenter('laneunderlay', 'X')
        setProperty('laneunderlayOpponent.alpha', 0)
       end
    end

    if getOptionData('hudWatermark') then
      makeLuaText('hudWatermark', songName .. ' ['..string.upper(difficultyName)..'] - DDTO Hud v3', 0, 4, 698)
      setTextFont('hudWatermark', (isPixel and getFont('vcr') or getFont('aller')))
      setTextBorder('hudWatermark', 1, '000000')
      setTextSize('hudWatermark', 15)
      setProperty('hudWatermark.visible', not hideHud)
      if globalAntialiasing then
        setProperty('hudWatermark.antialiasing', not isPixel)
      end
      setProperty('hudWatermark.alpha', 0)
      addLuaText('hudWatermark', true)
    end

    makeLuaText('practiceTxt', 'PRACTICE MODE', 0, 0, 0)
    setTextSize('practiceTxt', 32)
    setTextFont('practiceTxt', (isPixel and getFont('vcr') or getFont('riffic')))
    screenCenter('practiceTxt', 'X')
    setTextAlignment('practiceTxt', 'center')
    setTextBorder('practiceTxt', 1.25, '000000')
    if globalAntialiasing then
      setProperty('practiceTxt.antialiasing', not isPixel)
    end
    addLuaText('practiceTxt')

   makeLuaSprite('timeBarBack', 'timeBar', 0, 10)
   if downscroll then
     setProperty('timeBarBack.y', screenHeight * 0.9 + 40)
   end
   screenCenter('timeBarBack', 'X')
   setObjectCamera('timeBarBack', 'hud')
   setProperty('timeBarBack.alpha', 0)
   addLuaSprite('timeBarBack')

   makeLuaText('timeProgressTxt', '', 400, 0, 0)
   setTextSize('timeProgressTxt', 18)
   setTextFont('timeProgressTxt', (isPixel and getFont('vcr') or getFont('aller')))
   setTextAlignment('timeProgressTxt', 'center')
   setProperty('timeProgressTxt.alpha', 0)
   setTextBorder('timeProgressTxt', 1.2, '000000')
   addLuaText('timeProgressTxt')
end

function onCreatePost()
   for i = 1, #ogRatings do
      table.insert(ratingStuff.default, ogRatings[i])
   end
   setPropertyFromClass('PlayState', 'ratingStuff', ratingStuff.doki)
   reloadGradientBar()
   runHaxeCode([[
     game.timeBarBG.kill();
     game.timeTxt.kill();
   ]])

   setProperty('practiceTxt.y', getPropertyFromGroup('playerStrums', 0, 'y') + 35)

   setTextFont('scoreTxt', (isPixel and getFont('vcr') or getFont('aller')))
   setTextFont('timeTxt', (isPixel and getFont('vcr') or getFont('aller')))
   setTextFont('botplayTxt', (isPixel and getFont('vcr') or getFont('riffic')))

   setTextSize('timeTxt', 18)
   setTextBorder('timeTxt', 1.2, '000000')
   setProperty('timeTxt.y', getProperty('timeBarBack.y'))

   setPosition('timeProgressTxt', getProperty('timeBarBack.x'), getProperty('timeBarBack.y'))
   setPosition('timeBar', getProperty('timeBarBack.x') + 4, getProperty('timeBarBack.y') + 4)

   setObjectOrder('timeBarBack', getObjectOrder('timeBarBG'))
   setObjectOrder('practiceTxt', getObjectOrder('botplayTxt'))
   setObjectOrder('judgementCounter', getObjectOrder('scoreTxt'))
   setObjectOrder('hudWatermark', getObjectOrder('scoreTxt'))
   setObjectOrder('timeProgressTxt', getObjectOrder('scoreTxt'))
end

function onCountdownTick(swagCounter)
    runHaxeCode([[
      if (game.countdownReady != null && game.countdownReady.exists && !PlayState.isPixelStage)
        game.countdownReady.scale.set(0.6, 0.6);

      if (game.countdownSet != null && game.countdownSet.exists && !PlayState.isPixelStage)
        game.countdownSet.scale.set(0.6, 0.6);

      if (game.countdownGo != null && game.countdownGo.exists && !PlayState.isPixelStage)
        game.countdownGo.scale.set(0.6, 0.6);
   ]])
end

function onSongStart()
   -- 99.9% accurate lmao
   if timeBarType ~= 'Disabled' then
     doTweenAlpha('timeTween', 'timeBarBack', 1, 0.5, 'circOut')
     doTweenAlpha('timeTween2', 'timeProgressTxt', 1, 0.5, 'circOut')
   end
   doTweenAlpha('watermarkTween', 'hudWatermark', 1, 0.5, 'circOut')
end

function onUpdate()
   if nps > 0 and canDrain then
     canDrain = false
     runTimer('drainTimer', 1 / nps, 1)
   end

   if nps == 0 then
     canDrain = true
   end

   if nps > maxNps then
     maxNps = nps
   end

   if timeBarType == 'Time Left' then
     setTextString('timeProgressTxt', songName..(playbackRate ~= 1 and ' ('..playbackRate..'x)' or '')..' ('..formatTime(remainingTime())..')')
   elseif timeBarType == 'Song Name' then
     setTextString('timeProgressTxt', songName..(playbackRate ~= 1 and ' ('..playbackRate..'x)' or '')..' ('..difficultyName..')')
   elseif timeBarType == 'Time Elapsed' then
     setTextString('timeProgressTxt', songName..(playbackRate ~= 1 and ' ('..playbackRate..'x)' or '')..' ('..formatTime(getSongPosition() - noteOffset)..')')
   end
end

function onUpdatePost(elapsed)
   botplaySine = botplaySine + 180 * elapsed

   setProperty('practiceTxt.visible', getProperty('practiceMode'))
   if getProperty('practiceTxt.visible') then
     setProperty('practiceTxt.alpha', 1 - math.sin(math.pi * botplaySine / 180))
   end
end

function goodNoteHit(noteID, noteData, noteType, isSustainNote)
   noteDiff = getPropertyFromGroup('notes', noteID, 'strumTime') - getSongPosition()
   daRating = getPropertyFromGroup('notes', noteID, 'rating')
   dokiRati = scoreStuff.doki
   psychRati = scoreStuff.default
   if not isSustainNote then
      if scoreZoom then
        startTextZoom('scoreTxt', 1.075, 1, 0.2)
          if getOptionData('customFeatures') then
            startTextZoom('judgementCounter', 1.075, 1, 0.2)
          end
      end
      nps = nps + 1

      if botPlay then
        botHits = botHits + 1

         if daRating == 'sick' then
           botScore = botScore + getRatingData(0, 'score')
           botNotes = botNotes + getRatingData(0, 'ratingMod')
         elseif daRating == 'good' then
           botScore = botScore + getRatingData(1, 'score')
           botNotes = botNotes + getRatingData(1, 'ratingMod')
         elseif daRating == 'bad' then
           botScore = botScore + getRatingData(2, 'score')
           botNotes = botNotes + getRatingData(2, 'ratingMod')
         elseif daRating == 'shit' then
           botScore = botScore + getRatingData(3, 'score')
           botNotes = botNotes + getRatingData(3, 'ratingMod')
         end
      end

      if getOptionData('earlyLate') then
         if daRating ~= 'sick' then
            if noteDiff > 0 then
              popupDelay('late', 'FF0000')
              lates = lates + 1
            elseif noteDiff < 0 then
              popupDelay('early', '00FFFF')
              earlys = earlys + 1
            end
         end
      end
   end
   onRecalculateRating()
end

function noteMiss(noteID, noteData, noteType, isSustainNote)
   if nps > 0 then nps = nps - 1 end
   if getOptionData('customFeatures') then
     onUpdateScore(true)
     startTextColor('scoreTxt', 'FF0000', 'FFFFFF', (isSustainNote and 0.1 or 0.25))
     startTextColor('judgementCounter', 'FF0000', 'FFFFFF', (isSustainNote and 0.1 or 0.25))
   end
end

function noteMissPress(noteID, noteData, noteType, isSustainNote)
   if nps > 0 then nps = nps - 1 end
   if getOptionData('customFeatures') then
     onUpdateScore(true)
     startTextColor('scoreTxt', 'FF0000', 'FFFFFF', (isSustainNote and 0.1 or 0.25))
     startTextColor('judgementCounter', 'FF0000', 'FFFFFF', (isSustainNote and 0.1 or 0.25))
   end
end

function onRecalculateRating()
   botRating = math.min(1, math.max(botNotes / botHits))

   curRating = (botPlay and botRating or getProperty('ratingPercent'))
   notesPlayed = (botPlay and botHits or getProperty('totalPlayed'))

   if notesPlayed < 1 then
     ratingName = '?'
   else
      if curRating >= 0.9935 then
        ratingName = ratingStuff.doki[#ratingStuff.doki][1]
          for i = 1, #ratingStuff.doki do
             if curRating >= ratingStuff.doki[i][2] then
               ratingName = ratingStuff.doki[i][1]
             elseif curRating < 0.60 then
               ratingName = ratingStuff.doki[i][1]
             end
          end
      end
   end
   getRatingFC()
   onUpdateScore()
end

function getRatingFC()
   -- compat i guess
   sicks = (version:find('0.7') and getProperty('ratingsData[0].hits') or getProperty('sicks'))
   goods = (version:find('0.7') and getProperty('ratingsData[1].hits') or getProperty('goods'))
   bads = (version:find('0.7') and getProperty('ratingsData[2].hits') or getProperty('bads'))
   shits = (version:find('0.7') and getProperty('ratingsData[3].hits') or getProperty('shits'))

   ratingFC = ''
   if getProperty('songMisses') == 0 and bads == 0 and shits == 0 and goods == 0 then
      ratingFC = 'SFC' -- Sick Full Combo
   elseif getProperty('songMisses') == 0 and bads == 0 and shits == 0 and goods >= 1 then
      ratingFC = 'GFC' -- Good Full Combo
   elseif getProperty('songMisses') == 0 then
      ratingFC = 'FC' -- Full Combo
   elseif getProperty('songMisses') < 10 then
      ratingFC = 'SDCB' -- Single Digit Combo Break
   else
      ratingFC = 'Clear'
   end
end

function onUpdateScore(miss)
   ratingCalc = (botPlay and botRating or getProperty('ratingPercent'))
   scoreString = (botPlay and botScore or getProperty('songScore'))
   missString = getProperty('songMisses')
   ratingString = round(ratingCalc * 100, 2)

   sicks = (version:find('0.7') and getProperty('ratingsData[0].hits') or getProperty('sicks'))
   goods = (version:find('0.7') and getProperty('ratingsData[1].hits') or getProperty('goods'))
   bads = (version:find('0.7') and getProperty('ratingsData[2].hits') or getProperty('bads'))
   shits = (version:find('0.7') and getProperty('ratingsData[3].hits') or getProperty('shits'))

   beforeScore = (getOptionData('npsEnabled') and 'NPS: 0 (Max: 0) | ' or '')..'Score: 0 | Breaks: 0 | Rating: ?'
   finalScore = (getOptionData('npsEnabled') and 'NPS: '..nps..' (Max: '..maxNps..') | ' or '')..'Score: '..scoreString..' | Breaks: '..missString..' | Rating: '..ratingName..' ('..ratingString..'%) - '..(botPlay and 'BOT' or ratingFC)

   setProperty('scoreTxt.text', (ratingName ~= '?' and finalScore or beforeScore))

   if getProperty('combo') > maxCombo then
     maxCombo = getProperty('combo')
   end

   judgementString = 'Doki: '..sicks..'\nGood: '..goods..'\nOk: '..bads..'\nNo: '..shits..'\nMiss: '..getProperty('songMisses')..'\n'

    if getOptionData('judgementCounter') then
      if getOptionData('earlyLate') then
         setProperty('judgementCounter.text', judgementString..'\nEarly: '..earlys..'\nLate: '..lates..'\n\nMax: '..maxCombo)
      else
         setProperty('judgementCounter.text', judgementString..'\nMax: '..maxCombo) 
      end
   end
end

function onDestroy()
  setPropertyFromClass('PlayState', 'ratingStuff', ratingStuff.default)
end

function onTimerCompleted(tag, loops, loopsLeft)
   if tag == 'drainTimer' then
     reloadNps()
   end
end

function onTweenCompleted(tag)
   if tag == 'delayShown' then
     removeLuaText('currentTimingShown')
   end
end

function reloadNps()
   if nps > 0 then 
     runTimer('drainTimer', 1 / nps, 1)
     nps = nps - 1
   end
   onUpdateScore(false)
end

function startTextZoom(daText, zoomScale, defaultZoom, duration) 
   zoomScale = zoomScale or 1.075
   defaultZoom = defaultZoom or 1
   duration = duration or 0.25
   cancelTween(daText..'ZoomTweenX')
   cancelTween(daText..'ZoomTweenY')
   setProperty(daText..'.scale.x', zoomScale)
   setProperty(daText..'.scale.y', zoomScale)
   doTweenX(daText..'ZoomTweenX', daText..'.scale', defaultZoom, duration)
   doTweenY(daText..'ZoomTweenY', daText..'.scale', defaultZoom, duration)
end

function startTextColor(daText, daColor, ogColor, duration)
   daColor = daColor or 'FF0000'
   ogColor = ogColor or 'FFFFFF'
   duration = duration or 0.25
   setProperty(daText..'.color', getColorFromHex(daColor))
   cancelTween(daText..'ColorTween')
   doTweenColor(daText..'ColorTween', daText, ogColor, duration)
end

function popupDelay(text, color) 
   makeLuaText('currentTimingShown', text:upper(), 0, 0, 0)
   setTextFont('currentTimingShown', (isPixel and getFont('vcr') or getFont('riffic')))
   setTextSize('currentTimingShown', 28)
   setTextBorder('currentTimingShown', 1.5, '000000')
   screenCenter('currentTimingShown')
   setTextColor('currentTimingShown', (color == nil and 'FFFFFFF' or color))
   setProperty('currentTimingShown.x', 405 + comboOffset[1] + 100)
   setProperty('currentTimingShown.y', 230 - comboOffset[2] + 75)
   setProperty('currentTimingShown.visible', not hideHud)
   addLuaText('currentTimingShown')
   doTweenAlpha('delayShown', 'currentTimingShown', 0, 0.2 + (crochet * 0.002))
end

function changeGradientBar(colorShitDad, colorShitBF)
   reloadGradientColor()
    if colorShitBF == nil  or colorShitBF:lower() == 'default' then
      reloadGradientBar()
    else
      runHaxeCode([[
        game.timeBar.createGradientBar([0x0], [Std.parseInt('0xFF' + ']]..colorShitBF..[['), Std.parseInt('0xFF' + dadColor.join(''))]);
      ]])
    end
    if colorShitDad == nil or colorShitDad:lower() == 'default' then
      reloadGradientBar()
    else
      runHaxeCode([[
        game.timeBar.createGradientBar([0x0], [Std.parseInt('0xFF' + bfColor.join('')), Std.parseInt('0xFF' + ']]..colorShitDad..[[')]);
      ]])
    end
end

function reloadGradientBar()
   reloadGradientColor()
   runHaxeCode([[
      game.timeBar.createGradientBar([0x0], [Std.parseInt('0xFF' + defaultBfColor.join('')), Std.parseInt('0xFF' + defaultDadColor.join(''))]);
   ]])
end

function getRatingData(ratingNum, data)
   return getProperty('ratingsData['..ratingNum..'].'..data)
end

function setRatingData(ratingNum, data, val)
   setProperty('ratingsData['..ratingNum..'].'..data, val)
end

function reloadGradientColor()
   runHaxeCode([[
     defaultDadColor = [];
     for (i in game.dad.healthColorArray) defaultDadColor.push(StringTools.hex(i, 2));
     defaultBfColor = [];
     for (i in game.boyfriend.healthColorArray) defaultBfColor.push(StringTools.hex(i, 2));
     defaultGfColor = [];
     for (i in game.gf.healthColorArray) defaultGfColor.push(StringTools.hex(i, 2));
   ]])
end

function addValue(var, value)
   daVar = var
   daVar = daVar + value
end

function addOptions()
    -- put em here
    saveData('ddtoOptions', 'judgementCounter', judgementCounter)
    saveData('ddtoOptions', 'precacheAssets', precacheAssets)
    saveData('ddtoOptions', 'coolGameplay', coolGameplay)
    saveData('ddtoOptions', 'laneUnderlay', laneUnderlay)
    saveData('ddtoOptions', 'laneTransparency', laneTransparency)
    saveData('ddtoOptions', 'mirrorMode', mirrorMode)
    saveData('ddtoOptions', 'gfCountdown', gfCountdown)
    saveData('ddtoOptions', 'npsEnabled', npsEnabled)
    saveData('ddtoOptions', 'earlyLate', earlyLate)
    saveData('ddtoOptions', 'androidBuild', isAndroid)
    saveData('ddtoOptions', 'enablePause', enableCustomPause)
    saveData('ddtoOptions', 'secretPause', secretPause)
    saveData('ddtoOptions', 'enableOpponentSplash', enableOpponentSplash)
    saveData('ddtoOptions', 'enableSplash', enableSplash)
    saveData('ddtoOptions', 'hitSoundVolume', hitSoundVolume)
    saveData('ddtoOptions', 'judgeHitSound', judgeHitSound)
    saveData('ddtoOptions', 'hitSound', enableHitSound)
    saveData('ddtoOptions', 'showCredits', showCredits)
    saveData('ddtoOptions', 'hudWatermark', hudWatermark)
    saveData('ddtoOptions', 'customFeatures', customFeatures)
end

function getOptionData(var)
   return getData('ddtoOptions', var)
end

function setOptionData(var, val)
   saveData('ddtoOptions', var, val)
end

function getFont(type)
    font = ''
    type = type or 'aller'
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

function setPosition(tag, x, y)
   x = x or getProperty(tag, 'x')
   y = y or getProperty(tag, 'y')
   setProperty(tag..'.x', x)
   setProperty(tag..'.y', y)
end

function setTextFormat(tag, font, size, color, alignment)
   setTextFont(tag, font)
   setTextSize(tag, size)
   setTextColor(tag, color)
   setTextAlignment(tag, alignment)
end

function saveData(dataGrp, dataField, dataValue)
  setDataFromSave(dataGrp, dataField, dataValue)
end

function getData(dataGrp, dataField, dataValue)
  return getDataFromSave(dataGrp, dataField, dataValue)
end

function formatTime(millisecond)
    seconds = math.floor(millisecond / 1000)
    return string.format("%01d:%02d", (seconds / 60) % 60, seconds % 60)  
end

function remainingTime()
    return getProperty('songLength') - (getSongPosition() - noteOffset)
end

function getHealthColor(chr)
   return rgbToHex(getProperty(chr .. ".healthColorArray"))
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

function getRating(noteDiff, char)
   noteDiff = math.abs(noteDiff)
   if noteDiff <= getPropertyFromClass('ClientPrefs', 'badWindow') then
     if noteDiff <= getPropertyFromClass('ClientPrefs', 'goodWindow') then
       if noteDiff <= getPropertyFromClass('ClientPrefs', 'sickWindow') then
	 return 'sick'
	    end
	    return 'good'
        end
        return 'bad'
    end
    return 'shit'
end