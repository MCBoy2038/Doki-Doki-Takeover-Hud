-- OPTIONS --
--currently not supported for android so the "isAndroid" option is for only disabling the custom menu whoopsies
local isAndroid = false --enable it if you're on android/phone

-- PAUSE OPTIONS --
local pauseStyle = '' --style of pause you want only choices for now are:[libitina, vallhalla] leave it as blank for default
local pausePath = 'pause/' --where should be the pause art path located in 'mods/images/' don't forget it should always ends with a '/'

--- The Pause Stuff (put the songName MUST be the same name as the chart json file or else it won't work) --

local metaData = {
  -- Examples(used all possible pause art in ddto+) --
   --[[
      ['SongName'] = 'pauseart', -- pause art
   --]]
   ['Tutorial'] = 'gf',
   ['High School Conflict'] = 'monika',
   ['My Confession'] = 'sayori',
   ['Baka'] = 'natsuki',
   ["Crucify (Yuri Mix)"] = 'yuri',
   ["Titular (Mc Mix)"] = 'protag',
   ['Epiphany'] = 'epiphany',
   ['Love N Funkin'] = 'gf',
   ['Wilted'] = 'senpai',
   ['Libitina'] = 'libitina',
   ['Drinks on Me'] = 'jill',
   ['Takeover Medley'] = 'monika',
   ['songName'] = 'pauseArt',
}

-- Pause Style in Certain songs --
--these option makes you have a certain pause menu style in a certain/selected song just put the names
local vallhallPause = {'songName1', 'songName2'} --vallhalla style
local libitinaPause = {'songName1', 'songName2'} --libitina style

--[[
  if you want to make it force/change mid song to your desired pause art then
   forcePauseArt = art -- still located in the same folder path
   Ex: forcePauseArt = 'protag'
  and if you want to use it on other scripts
   callScript('scripts/DDTO+ Pause Script', 'forcePause', {'art'})
  put blank to undo
]]--

-- Code N Stuff (highly suggested not to mess with unless ya know it) --
local pauseOG = {'Resume', 'Restart Song', 'Exit To Menu'}
local curSelected = 0

local curCharacter = 1
local deathInfo = {'Deleted', 'Blue balled', 'Pastad'}

local canPress = true

local isLibitina = false
local isVallHallA = false

local itmColor = 'FF7CFF'
local selColor = 'FFCFFF'

local isPaused = false
local isForced = false

local forcePauseArt = ''
local selectedSomethin = false
local selectedPractice = false

function onPause()
   if not isAndroid then
    return Function_Stop
   end
end

function onCreatePost()
  metaThing = metaData[songName]
  isLibitina = songName:lower() == 'libitina'
  isVallHallA = songName:lower() == 'drinks on me'
  curPlayer = getProperty('boyfriend.curCharacter') or getProperty('dad.curCharacter')
  inDebug = getPropertyFromClass('PlayState', 'chartingMode')
   if inDebug then
     pauseOG = {'Resume', 'Restart Song', 'Practice Mode', 'Botplay', 'Leave Debug', 'Exit To Menu'}
   elseif isStoryMode then
     pauseOG = {'Resume', 'Restart Song', 'Exit To Menu'}
   else
     pauseOG = {'Resume', 'Restart Song', 'Practice Mode', 'Exit To Menu'}
   end
   if curPlayer:find('bf') then
     curCharacter = 2
   elseif dadName:find('senpai') then
     curCharacter = 3
   else
     curCharacter = 1
    end
end

function onStartCountdown()
  isPaused = true
end

function onSongStart()
  isPaused = false
end

function onGameOver()
  isPaused = false
end

function onGameOverStart()
  isPaused = false
end

function onGameOverConfirm(retry)
  if retry then
    isPaused = false
    end
end

function onUpdate()
  if keyboardJustPressed('ENTER') or keyJustPressed('pause') and not isPaused and not inGameOver and not isAndroid then
     openCustomSubstate('DDTOPause', true)
    end
end

function forcePause(pauseChar)
    pauseForced = pauseChar
   if pauseChar == nil or pauseChar == '' then
    pauseForced = metaThing
   end
end

function onCustomSubstateCreate(tag)
   if tag == 'DDTOPause' then
        menuItems = pauseOG
        precacheSound('scrollMenu')
        precacheSound('confirmMenu')
        precacheSound('disco')
	isPaused = true

        playSound('disco', 0, 'pauseMusic')

	makeLuaSprite('pausebg')
	setObjectCamera('pausebg', 'other')
	makeGraphic('pausebg', screenWidth * 3, screenHeight * 3, '000000')
	setProperty('pausebg.alpha', 0)
	addLuaSprite('pausebg')

        precacheImage('cursor')
        makeLuaSprite('cursorDDTO', 'cursor')
        setObjectCamera('cursorDDTO', 'other')
        addLuaSprite('cursorDDTO', true)
 
        if metaThing == nil or metaThing == '' then
           pauseImg = 'fumo'
        else
           pauseImg = metaThing
        end
        precacheImage(pausePath .. pauseImg)
        if forcePauseArt == nil or forcePauseArt == '' then
	   makeLuaSprite('pauseArt', pausePath .. pauseImg, screenWidth, 0)
         else
	   makeLuaSprite('pauseArt', pausePath .. pauseForced, screenWidth, 0)
        end
	setObjectCamera('pauseArt', 'other')
        if isLibitina or pauseStyle == 'libitina' then
          setProperty('pauseArt.x', screenWidth - getProperty('pauseArt.width'))
        end
	addLuaSprite('pauseArt')
        doTweenX('pauseArt', 'pauseArt', screenWidth - getProperty('pauseArt.width'), 1.4, 'elasticOut')

	makeLuaText('levelInfo', songName, screenWidth, 20, 15)
	setTextAlignment('levelInfo', 'right')
	setTextFont('levelInfo', getFont())
	setObjectCamera('levelInfo', 'other')
	setTextSize('levelInfo', 32)
	setTextBorder('levelInfo', 1.25, '000000')
	addLuaText('levelInfo')

	makeLuaText('deathText', deathInfo[curCharacter]..': '..getPropertyFromClass('PlayState', 'deathCounter'), screenWidth, 20, 15 + 64)
	setTextAlignment('deathText', 'right')
	setTextFont('deathText', getFont())
	setObjectCamera('deathText', 'other')
	setTextSize('deathText', 32)
	setTextBorder('deathText', 1.25, '000000')
	addLuaText('deathText')

	makeLuaText('practiceText', 'Practice Mode', screenWidth, 20, 15 + 96)
        setProperty('practiceText.visible', getProperty('practiceMode'))
	setTextAlignment('practiceText', 'right')
	setTextFont('practiceText', getFont())
	setObjectCamera('practiceText', 'other')
	setTextSize('practiceText', 32)
	setTextBorder('practiceText', 1.25, '000000')
	addLuaText('practiceText')

	makeLuaText('levelDifficulty', difficultyName:upper(), screenWidth, 0, 15 + 32)
	setTextAlignment('levelDifficulty', 'right')
	setTextFont('levelDifficulty', getFont())
	setObjectCamera('levelDifficulty', 'other')
	setTextSize('levelDifficulty', 32)
	setTextBorder('levelDifficulty', 1.25, '000000')
	addLuaText('levelDifficulty')

	makeLuaText('speedText', 'Speed: '..playbackRate..'x (Control + Left/Right)', 0, 410, 15)
	setTextAlignment('speedText', 'right')
	setTextFont('speedText', getFont())
	setObjectCamera('speedText', 'other')
	setTextSize('speedText', 32)
	setTextBorder('speedText', 1.25, '000000')
	addLuaText('speedText')

	makeLuaText('botplayText', 'BOTPLAY', 0, 240, 630)
        setProperty('botplayText.visible', getProperty('cpuControlled'))
	setTextAlignment('botplayText', 'right')
	setTextFont('botplayText', getFont())
	setObjectCamera('botplayText', 'other')
	setTextSize('botplayText', 32)
	setTextBorder('botplayText', 1.25, '000000')
	addLuaText('botplayText')

	makeLuaText('chartText', 'Charting Mode', 0, 0, 660)
        setProperty('chartText.visible', getPropertyFromClass('PlayState', 'chartingMode'))
	setTextAlignment('chartText', 'right')
	setTextFont('chartText', getFont())
	setObjectCamera('chartText', 'other')
	setTextSize('chartText', 32)
	setTextBorder('chartText', 1.25, '000000')
	addLuaText('chartText')

        setProperty('leveInfo.alpha', 0)
        setProperty('levelDifficulty.alpha', 0)
        setProperty('deathText.alpha', 0)
        setProperty('practiceText.alpha', 0)
        setProperty('speedText.alpha', 0)
        setProperty('botplayText.alpha', 0)
        setProperty('chartText.alpha', 0)

        setProperty('levelInfo.x', screenWidth - getProperty('levelInfo.width') - 20)
        setProperty('levelDifficulty.x', screenWidth - getProperty('levelDifficulty.width') - 20)
        setProperty('deathText.x', screenWidth - getProperty('deathText.width') - 20)
        setProperty('practiceText.x', screenWidth - getProperty('practiceText.width') - 20)
        setProperty('botplayText.x', screenWidth - getProperty('botplayText.width'))
        setProperty('chartText.x', screenWidth - getProperty('chartText.width'))

        doTweenAlpha('pausebg', 'pausebg', 0.6, 0.4, 'quartInOut')

        doTweenAlpha('levelInfoAlpha', 'levelInfo', 1, 0.7, 'quartInOut')
        doTweenY('levelInfoY', 'levelInfo', 20, 0.7, 'quartInOut')

        doTweenAlpha('levelDifficultyAlpha', 'levelDifficulty', 1, 0.9, 'quartInOut')
        doTweenY('levelDifficultyY', 'levelDifficulty', getProperty('levelDifficulty.y') + 5, 0.9, 'quartInOut')

        doTweenAlpha('deathTextAlpha', 'deathText', 1, 1.1, 'quartInOut')
        doTweenY('deathTextY', 'deathText', getProperty('deathText.y') + 5, 1.1, 'quartInOut')

        doTweenAlpha('practiceTextAlpha', 'practiceText', 1, 1.3, 'quartInOut')
        doTweenY('practiceTextY', 'practiceText', getProperty('practiceText.y') + 5, 1.3, 'quartInOut')

        doTweenAlpha('speedTextAlpha', 'speedText', 1, 0.7, 'quartInOut')
        doTweenY('speedTextY', 'speedText', getProperty('speedText.y') + 5, 0.7, 'quartInOut')

        doTweenAlpha('botplayTextAlpha', 'botplayText', 1, 0.7, 'quartInOut')
        doTweenY('botplayTextY', 'botplayText', getProperty('botplayText.y') + 5, 0.7, 'quartInOut')

        doTweenAlpha('chartTextAlpha', 'chartText', 1, 0.7, 'quartInOut')
        doTweenY('chartTextY', 'chartText', getProperty('chartText.y') + 5, 0.7, 'quartInOut')
 
        if pauseStyle == 'libitina' or isLibitina and isStoryMode then
          setProperty('pauseArt.visible', false)
          setProperty('levelInfo.visible', false)
        end

        precacheImage('Credits_LeftSide')
	makeLuaSprite('logo', 'Credits_LeftSide', -260, 0)
	setObjectCamera('logo', 'other')
	addLuaSprite('logo')

        doTweenX('logo', 'logo', -60, 1.2, 'elasticOut')

        precacheImage('DDLCStart_Screen_Assets')
        makeAnimatedLuaSprite('logoBl', 'DDLCStart_Screen_Assets', -160, -40)
        scaleObject('logoBl', 0.5, 0.5)
        addAnimationByPrefix('logoBl', 'bump', 'logo bumpin', 24, false)
        setObjectCamera('logoBl', 'other')
        addLuaSprite('logoBl')

        doTweenX('logoBl', 'logoBl', 40, 1.2, 'elasticOut')

        textX = 50
        if (isVallHallA or pauseStyle == 'vallhalla') then textX = textX + 25 end

	for i = 1, #pauseOG do
	    makeLuaText('songText'..i, menuItems[i], 0, -350, 370 + (i * 50))
	    setTextAlignment('songText'..i, 'left')
            setTextFormat('songText'..i, getFont('riffic'), 27, 'FFFFFF', 'LEFT')
            setObjectCamera('songText'..i, 'other')
            setTextBorder('songText'..i, 2, itmColor)
	    setScrollFactor('songText'..i, 0, 0);
	    addLuaText('songText'..i)
         if curSelected == 0 and pauseStyle == nil or pauseStyle == '' or pauseStyle == 'doki' then
               setTextBorder('songText1', 2, selColor)
         end

         if pauseStyle == 'libitina' or isLibitina then
           itmColor = '8BA9F0'
              setTextBorder('songText'..i, 0, '000000')
              setTextFormat('songText'..i, getFont('dos'), 27, '8BA9F0', 'LEFT')
               if curSelected == 0 then
                  setTextColor('songText1', 'FFFFFF')
               end
         elseif pauseStyle == 'vallhalla' or isVallHallA then
           itmColor = 'FF3A89'
              setTextBorder('songText'..i, 0, '000000')
              setProperty('songText'..i..'.y', getProperty('songText'..i..'.y') - 75)
              setProperty('songText'..i..'.antialiasing', false)
              setTextFormat('songText'..i, getFont('waifu'), 32, 'FFFFFF', 'LEFT')
               if curSelected == 0 then
                  setTextColor('songText1', itmColor)
               end
         end
            doTweenX('songText'..i, 'songText'..i, textX, 1.2 + (i * 0.2), 'elasticOut')
       end

        if pauseStyle == 'libitina' or isLibitina then
           pauseSound('pauseMusic')
           setProperty('pauseArt.x', -getProperty('pauseArt.width'))
           setProperty('logoBl.visible', false)
           loadGraphic('logo', 'LibitinaPause')
        elseif pauseStyle == 'vallhalla' or isVallHallA then
           setProperty('speedText.x', screenWidth - getProperty('speedText.x') + 60)
           setProperty('logoBl.visible', false)
           loadGraphic('logo', 'Va11Pause')
           setProperty('logo.antialiasing', false)
        end

        changeSelection()
     end
end

function onCustomSubstateCreatePost(tag)
  if tag == 'DDTOPause' then
    items = {'pausebg', 'pauseArt', 'levelInfo', 'levelDifficulty', 'deathText', 'practiceText', 'speedText', 'logo', 'logoBl', 'chartText', 'botplayText'}
        for ii = 1, #items do
          setObjectOrder(items[ii], 100)
        end
        for i = 1, #pauseOG do
          setObjectOrder('songText'..i, 100)
        end
    end
end

function onCustomSubstateUpdate(tag, elapsed)
   if tag == 'DDTOPause' then
     setObjectOrder('cursorDDTO', 9999)
     setProperty('cursorDDTO.x', getMouseX('hud'))
     setProperty('cursorDDTO.y', getMouseY('hud'))

    if getSoundVolume('pauseMusic') < 0.5 then
       setSoundVolume('pauseMusic', getSoundVolume('pauseMusic') + 0.01 * elapsed)
    elseif getSoundVolume('pauseMusic') > 0.5 then
       setSoundVolume('pauseMusic', 0.5)
    end

     setProperty('practiceText.visible', getProperty('practiceMode'))
     setProperty('botplayText.visible', getProperty('cpuControlled'))
     setProperty('speedText.visible', getProperty('practiceText.visible'))
     setProperty('chartText.visible', getPropertyFromClass('PlayState', 'chartingMode'))

    if not selectedSomethin then
      if keyboardJustPressed('UP') or keyboardJustPressed('W') then 
	  changeSelection(-1);

      elseif keyboardJustPressed('DOWN') or keyboardJustPressed('S') then
	  changeSelection(1)

      elseif keyboardJustPressed('ESCAPE') then 
          closeCustomSubstate()

      elseif keyboardJustPressed('ENTER') and isPaused then
	  selectedCheck()

      elseif keyboardPressed('CONTROL') and keyboardJustPressed('LEFT') and selectedPractice then 
          setProperty('playbackRate', getProperty('playbackRate') - 0.05)
          setTextString('speedText', 'Speed: '..playbackRate..'x')

      elseif keyboardPressed('CONTROL') and keyboardJustPressed('RIGHT') and selectedPractice then 
          setProperty('playbackRate', getProperty('playbackRate') + 0.05)
          setTextString('speedText', 'Speed: '..playbackRate..'x')

      elseif keyboardPressed('CONTROL') and keyboardJustPressed('R') and selectedPractice then 
          setProperty('playbackRate', 1)
          setTextString('speedText', 'Speed: '..playbackRate..'x')
            end
        end
    end
end

function closeMenu()
      --Tweens!
        canPress = false
        cancelTween('pauseArt')
        cancelTween('logo')
        cancelTween('logoBl')
        cancelTween('pausebg')

        cancelTween('levelInfo')
        cancelTween('levelDifficulty')
        cancelTween('deathText')
        cancelTween('practiceText')
        cancelTween('speedText')

        cancelTween('botplayText')
        cancelTween('chartText')

	for i = 1, #pauseOG do
           doTweenX('songText'..i, 'songText'..i, -350, 0.5, 'elasticOut')
	end

        doTweenX('pauseArt', 'pauseArt', screenWidth, 0.7, 'quartInOut')

        doTweenX('logo', 'logo', -500, 0.7, 'elasticOut')
        doTweenX('logoBl', 'logoBl', -500, 0.7, 'elasticOut')
        doTweenAlpha('pausebg', 'pausebg', 0, 0.6, 'quartInOut')

        doTweenAlpha('levelInfo', 'levelInfo', 0, 0.6, 'quartInOut')
        doTweenAlpha('levelDifficulty', 'levelDifficulty', 0, 0.6, 'quartInOut')
        doTweenAlpha('deathText', 'deathText', 0, 0.6, 'quartInOut')
        doTweenAlpha('practiceText', 'practiceText', 0, 0.6, 'quartInOut')
        doTweenAlpha('speedText', 'speedText', 0, 0.6, 'quartInOut')

        doTweenAlpha('botplayText', 'botplayText', 0, 0.6, 'quartInOut')
        doTweenAlpha('chartText', 'chartText', 0, 0.6, 'quartInOut')

        runTimer('close', 0.6)
end

function changeSelection(change)
   playSound('scrollMenu', 0.7)
        change = change
        curSelected = curSelected + change;

          if curSelected >= #pauseOG then
            curSelected = 0;
          end

          if curSelected < 0 then
            curSelected = #pauseOG - 1;
          end

          for i = 1, #pauseOG do
           if pauseStyle == 'libitina' or isLibitina then
            itmColor = '8BA9F0'
            setTextColor('songText'..i, itmColor)
           if curSelected == i-1 then
            setTextColor('songText'..i, 'FFFFFF')
           end

           elseif pauseStyle == 'vallhalla' or isVallHallA then
            itmColor = 'FF3A89'
            setTextColor('songText'..i, 'FFFFFF')
           if curSelected == i-1 then
            setTextColor('songText'..i, itmColor)
	   end

           else
            setTextBorder('songText'..i, 2, itmColor)
           if curSelected == i-1 then
            setTextBorder('songText'..i, 2, selColor)
            end
	end
    end
end

function checkSelectedItems()
   daSelected = pauseOG[curSelected]
 
  if daSelected == 'Resume' then
     closeCustomSubstate()
     closeMenu()

  elseif daSelected == 'Restart Song' then
     restartSong()

  elseif daSelected == 'Practice Mode' then
     setToggleProperty('practiceMode')
     
  elseif daSelected == 'Exit To Menu' then
     exitSong()
    end
end

function selectedCheck()
   if inDebug then
       if curSelected == 0 then
	   closeCustomSubstate()
           playSound('confirmMenu')
       elseif curSelected == 1 then
	   restartSong(false)
       elseif curSelected == 2 then
           setToggleProperty('practiceMode')
       elseif curSelected == 3 then
	  if not getProperty('cpuControlled') then
	      setProperty('cpuControlled', true)
              setProperty('botplayTxt.visible', true)
	  else
	      setProperty('cpuControlled', false)
              setProperty('botplayTxt.visible', false)
	   end
       elseif curSelected == 4 then
          setPropertyFromClass('PlayState', 'chartingMode', false)
	   restartSong()
       elseif curSelected == 5 then
	   exitSong()
       end
   elseif isStoryMode then
       if curSelected == 0 then
	   closeCustomSubstate()
           playSound('confirmMenu')
       elseif curSelected == 1 then
	   restartSong()
       elseif curSelected == 2 then
	   exitSong()
       end
   else
       if curSelected == 0 then
	   closeCustomSubstate()
           playSound('confirmMenu')
       elseif curSelected == 1 then
	   restartSong()
       elseif curSelected == 2 then
           setToggleProperty('practiceMode')
       elseif curSelected == 3 then
	   exitSong()
        end
    end
end

function onCustomSubstateDestroy(tag)
   if tag == 'DDTOPause' then
        isPaused = false
           closeMenu()
      end
end

function destroyPause()
	removeLuaSprite('pausebg')
	removeLuaSprite('cursorDDTO')
	removeLuaSprite('logo')
	removeLuaSprite('logoBl')
	removeLuaText('songText'..i)
	removeLuaText('chartText')
	removeLuaText('speedText')
	removeLuaText('levelInfo')
	removeLuaText('levelDifficulty')
	removeLuaText('deathText')
	removeLuaText('practiceText')
	removeLuaText('botplayText')
	removeLuaText('chartText')
        stopSound('pauseMusic')
end

function onSoundFinished(tag)
   if tag == 'pauseMusic' then
        playSound('disco', 0, 'pauseMusic')
    end
end

function onTimerCompleted(tag)
   if tag == 'close' then
       destroyPause()
    end
end

function destroy()
    stopSound('pauseMusic')
    isPaused = false
end

function setTextFormat(tag, font, size, color, alignment)
   setTextFont(tag, font)
   setTextSize(tag, size)
   setTextColor(tag, color)
   setTextAlignment(tag, alignment)
end

function setToggleProperty(var)
    if not getProperty(var) then
	setProperty(var, true)
       if not getProperty('cpuControlled') then
	setProperty('practiceTxt.visible', true)
       end    
        selectedPractice = true
    else
	setProperty(var, false)
	setProperty('practiceTxt.visible', false)
    end
end

function formatTime(millisecond)
    local seconds = math.floor(millisecond / 1000)
    return string.format("%01d:%02d", (seconds / 60) % 60, seconds % 60)  
end

function remainingTime()
    return getProperty('songLength') - (getSongPosition() - noteOffset)
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