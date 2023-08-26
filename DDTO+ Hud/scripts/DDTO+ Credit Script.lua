
-- Default Values --
local defaultIcon = 'mic' -- default value for the icon
local defaultArtist = 'Kawaii Sprite' -- default artist
local defaultTimer = 3
local defaultStep = {1, 5}
local defaultBeat = {1, 2.5}

local songData = {
    --[[
      ['song name from chart'] = {
        name = 'display song name', (OPTIONAL)
        icon = 'display icon',
        artist = 'display artist',

        -- The Way The Credits Appear/Disappear (ENABLE ONLY ONE) --
        showTimer = true/false, -- disappears through the sepecific timer (OPTIONAL)
        showStep = true/false, -- appear/disappears using the specific stepData set (OPTIONAL)
        showBeat = true/false, -- appear/disappears using the specific beatData set (OPTIONAL)

        -- The Data Stuff (LEAVE BLANK FOR DEFAULT) --
        timer = 2, -- the timer till it disappears (only for 'showTimer')
        -- you could look at the 'Chart Editor' for additional help for this one --
        step = {2, 5}, -- the given step data (first one:appear, second:disappear)
        beat = {1, 5}, -- the given beat data (first one:appear, second:disappear)

        -- Misc. --
        showCredit = true/false, -- should it appear? (default is true)
      }
    ]]
  ['Bopeebo'] = {icon = 'pen'}, -- Different Icon
  ['Ugh'] = {artist = 'Kawaii Sprite'} -- Different Artist
}
     
local isPixel = false
local globalAntialiasing = false
local hasData = false

function onCreate()
    isPixel = getPropertyFromClass('PlayState', 'isPixelStage')
    globalAntialiasing = getPropertyFromClass('ClientPrefs', 'globalAntialiasing')
    skipCountdown = getProperty('skipCountdown') and getProperty('startedCountdown')

    song = songData[songName]
    hasData = song ~= nil

    if hasData then
      songData = song.name ~= nil and song.name or songName
      songIcon = song.icon ~= nil and song.icon or defaultIcon
      songArtist = song.artist ~= nil and song.artist or defaultArtist

      showTimer = song.showTimer or false
      showStep = song.showStep or false
      showBeat = song.showBeat or false

      timerData = song.timer or defaultTimer
      stepData = song.step or defaultStep
      beatData = song.beat or defaultBeat
      showData = song.showCredit or true
    else
      songData = songName
      songIcon = defaultIcon
      songArtist = defaultArtist

      timerData = defaultTimer
      stepData = defaultStep
      beatData = defaultBeat
    end

    addMeta(songData, songIcon, songArtist)
end

function addMeta(songDisplay, songIcon, songArtist)
    makeLuaText('metaName', '', 0, 20, 15)
    setTextFormat('metaName', isPixel and getFont('vcr') or getFont('riffic'), 36, 'FFFFFF', 'right')
    setTextBorder('metaName', 1, '000000')
    setTextString('metaName', songDisplay)
    updateHitbox('metaName')
    setScrollFactor('metaName')
    setObjectCamera('metaName', 'other')
    setProperty('metaName.alpha', 0)
    if globalAntialiasing then
      setProperty('metaName.antialiasing', not isPixel)
    end
    setProperty('metaName.x', screenWidth - (getProperty('metaName.width') + 20))

    createHealthIcon('metaIcon', songIcon)
    scaleObject('metaIcon', 0.35, 0.35)
    setProperty('metaIcon.alpha', 0)
    setPosition('metaIcon', screenWidth - (getProperty('metaName.width')) - 65, 15 - (getProperty('metaIcon.height') / 2) + 16)
    setObjectCamera('metaIcon', 'other')

    makeLuaText('metaArtist', '', 0, 38, 38)
    setTextFormat('metaArtist', isPixel and getFont('vcr') or getFont('aller'), 20, 'FFFFFF', 'right')
    setTextBorder('metaArtist', 1, '000000')
    setProperty('metaArtist.alpha', 0)
    setTextString('metaArtist', songArtist)
    setObjectCamera('metaArtist', 'other')
    updateHitbox('metaArtist')
    setScrollFactor('metaArtist')
    if globalAntialiasing then
      setProperty('metaArtist.antialiasing', not isPixel)
    end
    setPosition('metaArtist', screenWidth - (getProperty('metaArtist.width') + 20), getProperty('metaArtist.y'))
    
    addLuaText('metaName', true)
    addLuaSprite('metaIcon', true)
    addLuaText('metaArtist', true)
end

function tweenIn()
   runHaxeCode([[
	FlxTween.tween(game.getLuaObject('metaName'), {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
	FlxTween.tween(game.getLuaObject('metaIcon'), {alpha: 1, y: 20 - (game.getLuaObject('metaIcon').height / 2) + 16}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
	FlxTween.tween(game.getLuaObject('metaArtist'), {alpha: 1, y: 58}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.4});
   ]])
   runTimer('creditOut', (showTimer and timerData or calcSectionLength() + 3))
end

function tweenOut()
   runHaxeCode([[
	FlxTween.tween(game.getLuaObject('metaName'), {alpha: 0, y: 0}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
	FlxTween.tween(game.getLuaObject('metaIcon'), {alpha: 0, y: 0 - (game.getLuaObject('metaIcon').height / 2) + 16}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
	FlxTween.tween(game.getLuaObject('metaArtist'), {alpha: 0, y: 38}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
   ]])
   runTimer('removeTimer', 0.8)
end

function createHealthIcon(tag, icon, crop)
    crop = crop or false
    makeLuaSprite(tag, 'icons/icon-'..icon)
    if crop then
      loadGraphic(tag, 'icons/icon-'..icon, getProperty(tag..'.width') / 2, getProperty(tag..'.height'))
    end
end

function onTimerCompleted(tag)
   if tag == 'creditOut' then
     tweenOut()
   end
   if tag == 'removeTimer' then
     removeLuaSprite('metaIcon')
     removeLuaSprite('metaArtist')
     removeLuaSprite('metaName')
   end
end

function onStartCountdown()
  if not skipCountdown then
    if not showStep and not showBeat then
       tweenIn()
        end
    end
end

function onSongStart()
  if skipCountdown then
    if not showStep and not showBeat then
       tweenIn()
        end
    end
end

function onBeatHit()
  if showBeat and not showStep and not showTimer then
    if curBeat == beatData[1] then
      tweenIn()
    elseif curBeat == beatData[2] then 
      tweenOut()
        end
    end
end 

function onStepHit()
  if showStep and not showBeat and not showTimer then
    if curStep == stepData[1] then
      tweenIn()
    elseif curStep == stepData[2] then
      tweenOut()
        end
    end
end

function calcSectionLength(multiplier)
   multiplier = multiplier or 1
   return (stepCrochet / (64 / multiplier) / playbackRate)
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

function getOptionData(var)
   return getData('ddtoOptions', var)
end

function setOptionData(var, val)
   saveData('ddtoOptions', var, val)
end
