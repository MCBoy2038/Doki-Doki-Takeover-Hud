local defaultColor = 'FFFFFF'
local defaultTimer = 1
local tweenFade = true

function onCreate()
    makeLuaText('lyrics', '')
    setProperty('lyrics.frameWidth', screenWidth)
    if getClass('PlayState', 'isPixelStage', 'states') then
      setTextFont('lyrics', 'vcr.ttf')
    else
      setTextFont('lyrics', 'HKGrotesk-Bold.otf')
    end
    setTextSize('lyrics', 32)
    setTextColor('lyrics', color)
    setTextBorder('lyrics', 1.25, '000000')
    setTextAlignment('lyrics', 'CENTER')
    setProperty('lyrics.y', (screenHeight) * 0.72)
    setObjectCamera('lyrics', 'camHUD')
    setProperty('lyrics.visible', false)
    setProperty('lyrics.alpha', 0)
    screenCenter('lyrics', 'X')
    addLuaText('lyrics', true)
end

function onEvent(name, value1, value2)
    if name == 'DDTO Lyrics' then
      valOptions = stringSplit(value2, ':')
      resetLyric(value1, valOptions[1], valOptions[2], valOptions[3])
    end
end

function onTimerCompleted(tag)
   if tag == 'lyricsTimer' then
      if tweenFade then
        doTweenAlpha('lyricFade', 'lyrics', 0, 0.5, 'circOut')
      else
        setProperty('lyrics.visible', false)
      end
   end
end

function resetLyric(daLyric, daTimer, daColor, customColor)
   daLyric = daLyric or ''
   daTimer = daTimer or defaultTimer
   daColor = daColor or getTextColor('WHITE')
   customColor = customColor or defaultColor
   setProperty('lyrics.visible', true)
   setProperty('lyrics.alpha', 1)
   setTextString('lyrics', daLyric)
   screenCenter('lyrics', 'X')
   if getClass('PlayState', 'isPixelStage', 'states') then
     setTextFont('lyrics', 'vcr.ttf')
   else
     setTextFont('lyrics', 'HKGrotesk-Bold.otf')
   end
   if daColor:lower() == 'custom' then
     setTextColor('lyrics', customColor)
   else
     setTextColor('lyrics', getTextColor(daColor))
   end
   runTimer('lyricsTimer', daTimer)
end


function getTextColor(color)
   color = color or 'BLACK'
   if color == 'BLACK' then
     daColor = '000000'
   elseif color == 'BLUE' then
     daColor = '0000FF'
   elseif color == 'BROWN' then
     daColor = '8B4513'
   elseif color == 'CYAN' then
     daColor = '00FFFF'
   elseif color == 'GRAY' or color == 'GREY' then
     daColor = '808080'
   elseif color == 'GREEN' then
     daColor = '008000'
   elseif color == 'LIME' then
     daColor = '00FF00'
   elseif color == 'MAGENTA' then
     daColor = 'FF00FF'
   elseif color == 'ORANGE' then
     daColor = 'FFA500'
   elseif color == 'PINK' then
     daColor = 'FFC0CB'
   elseif color == 'PURPLE' then
     daColor = '800080'
   elseif color == 'RED' then
     daColor = 'FF0000'
   elseif color == 'TRANSPARENT' then
     daColor = '0x00000000'
   elseif color == 'WHITE' then
     daColor = 'FFFFFF'
   elseif color == 'YELLOW' then
     daColor = 'FFFF00'
   end
   return daColor
end

function getClass(class, data, classVar)
   if stringStartsWith(version, 0.6) then
     daClass = getPropertyFromClass(class, data)
   else
     daClass = getPropertyFromClass(classVar..'.'..class, data)
   end
   return daClass
end