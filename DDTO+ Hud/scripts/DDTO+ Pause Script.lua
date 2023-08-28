local pauseStyle = '' -- the pause menu style current values are [libitina/lib & vallhalla]
local defaultPause = 'fumo' -- the default pause art when there's none specified
local customCursor = true -- shows the ddto+ cursor instead of the default
local showCursor = true -- shows cursor (pc only)
local creditVer = true -- alternate version of the logo

local pauseOptions = {
    --[[
      ['song name from chart'] = {
        name = '', -- song display name (OPTIONAL)
        art = 'gf', -- pause menu art
        deathText = 'Blueballed' -- the 'blueballed' text (OPTIONAL)
      }
    ]]
}

--[[
  if you want to change your pause menu art/style mid song just use the following:
    -- Pause Art --
      callOnLuas('forcedPause', {art})
      callScript('scripts/DDTO+ Pause Menu', 'forcedPause', {art})
      triggerEvent('Change Pause Art', 'art', '')
    -- Pause Style --
      callOnLuas('changeStyle', {art})
      callScript('scripts/DDTO+ Pause Menu', 'changeStyle', {art})
      triggerEvent('Change Pause Style', 'art', '')
]]

-- Pause Controls Keybinds --
local controls = {
  scrollUp = 'W', -- extra keybind for scrolling up
  scrollDown = 'S', -- extra keybind for scrolling down
  scrollLeft = 'A', -- extra keybind for scrolling left
  scrollRight = 'D', -- extra keybind for scrolling right
  escape = 'P', -- extra keybind for exit/back
  reset = 'O', -- extra keybind for resetting
  confirm = 'I', -- extra keybind for confirming selection
  toggle = 'Z', -- extra keybind for toggling the controls info
}


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------ CODE N STUFF ([RECOMMENDED] Do not mess unless you know how things work) ---------------------------------------------------------------
-- Death Counter Stuff --
local curCharacter = 1
local deathInfo = {'Deleted', 'Blue balled', 'Pastad'}

-- Pause Color Stuff --
local itmColor = 'FF7CFF'
local selColor = 'FFCFFF'

-- Pause Menu Stuff --
local hasData = false
local forcePauseArt = ''
local isAndroid = false
local selectedSomethin = false
local canPress = false
local replaySelect = false

-- Pause Choices Stuff --
local pauseOG = {'Resume', 'Restart Song', 'Change Difficulty', 'Exit To Menu'}
local debugItems = {'Practice Mode', 'Botplay', 'Chart Editor', 'Leave Debug', 'Back'}
local menuChoices = {'Title', 'Main Menu', 'Story', 'Freeplay', 'Credits', 'Options', 'Back'}
local difficultyChoices = {}
local menuItems = {}

-- Pause Selection Stuff (Highly recommended not to mess with) --
local curSelected = 1
local currentState = ''
local currentPause = ''
local selectedPractice = false
local canPause = false

-- Pause Skip Time --
local holdTime = 0
local curTime = 0
local skipMult = 1
local difficultyLength = 1

-- Button Stuff --
local buttonSprites = {'up', 'down', 'left', 'right', 'confirm', 'exit', 'reset'}


function onCreate()
   addHaxeLibrary('FlxTransitionableState', 'flixel.addons.transition')
   addHaxeLibrary('ChartingState')
   addHaxeLibrary('MusicBeatState')

   isAndroid = getOptionData('androidBuild')
   enablePause = getOptionData('enablePause')
   allowSecret = getOptionData('secretPause')
   precache = getOptionData('precacheAssets')

   difficultyLength = getPropertyFromClass('CoolUtil', 'difficulties.length')
   isPixel = getPropertyFromClass('PlayState', 'isPixelStage')
   globalAntialiasing = getPropertyFromClass('ClientPrefs', 'globalAntialiasing')
   chartingMode = getPropertyFromClass('PlayState', 'chartingMode')
   deathCounter = getPropertyFromClass('PlayState', 'deathCounter')

   if boyfriendName:find('bf') then
     curCharacter = 2
   elseif boyfriendName:find('senpai') then
     curCharacter = 3
   else
     curCharacter = 1
   end

   pauseStuff = pauseOptions[songName]

   hasData = not pauseStuff == nil

   if hasData then
     artData = pauseStuff.art or defaultPause
     deathData = pauseStuff.deathText or deathInfo[curCharacter]
   else
     artData = defaultPause
     deathData = deathInfo[curCharacter]
   end

   if isAndroid then createButton('pause', 'Android_Buttons', 1195, 635, 0.7, true) end
   if customCursor then
     makeLuaSprite('gameCursor', 'cursor')
     setObjectCamera('gameCursor', 'other')
     setProperty('gameCursor.visible', false)
     addLuaSprite('gameCursor', true)
   end

   if precache then
     precacheStuff()
   end
   updatePauseOptions()
end

function onPause()
   if enablePause then
     return Function_Stop
   end
end

function onCountdownStarted()
   showButton('pause', isAndroid)
   setProperty('gameCursor.visible', isAndroid)
end

function onEvent(name, value1, value2)
   if name == 'Change Pause Art' then
     forcePause(value1)
   elseif name == 'Change Pause Style' then
     changeStyle(value1)
   end
end

function onSongStart()
   if getProperty('skipCountdown') then
     showButton('pause', isAndroid)
     showCursor(isAndroid)
   end
   table.insert(debugItems, 1, 'Skip Time')
end

function onUpdate(elapsed)
   if getProperty('gameCursor.visible') then
      setPosition('gameCursor', getMouseX('camOTHER'), getMouseY('camOTHER'))
   end
   if isAndroid then
     playButtonAnim('pause', 'idle')
     if mouseReleasedObject('pauseButton') or androidControlReleased('BACK') and getProperty('startedCountdown') and currentState ~= 'closing' then
        playButtonAnim('pause', 'pressed')
        pauseState(allowSecret)
      end
   else
      if getProperty('controls.PAUSE') and getProperty('startedCountdown') and currentState ~= 'closing' then
        pauseState(allowSecret)
      end
   end
end

function onCustomSubstateCreate(tag)
   if tag == 'DokiPause' then
     curTime = getSongPosition()

     if pauseStyle == 'libitina' then
       itmColor = '8BA9F0'
     elseif pauseStyle == 'vallhalla' then
       itmColor = 'FF3A89'
     end

     if luaSoundExists('pauseMusic') then
       resumeSound('pauseMusic')
       setSoundVolume('pauseMusic', 0)
     else
       playSound('/../music/disco', 0, 'pauseMusic')
     end

     createObject('graphic', 'pausebg', {width = screenWidth * 3, height = screenHeight * 3, color = '000000'})
     setProperty('pausebg.alpha', 0)
     addSubstateObject('pausebg')

     if not isNullValue(forcePauseArt, true) then
       pauseImg = forcePauseArt
     else
       pauseImg = artData
     end
     makeLuaSprite('pauseArt', 'pause/' .. pauseImg, screenWidth, 0, 0)
     addSubstateObject('pauseArt')
     if pauseStyle == 'libitina' then setProperty('pauseArt.x', -getProperty('pauseArt.width')) end
     runHaxeCode([[FlxTween.tween(game.getLuaObject('pauseArt'), {x: ]]..screenWidth..[[ - ]]..getProperty('pauseArt.width')..[[}, 1.2, {ease: FlxEase.quartInOut, startDelay: 0.2});]])

     createObject('text', 'levelInfo', {text = songName, x = 20, y = 15, width = screenWidth})
     setTextFormat('levelInfo', getFont(), 32, 'FFFFFF', 'right', {1.25, '000000'})
     addSubstateObject('levelInfo')

     createObject('text', 'levelDifficulty', {text = getText('diff'):upper(), x = 20, y = 15 + 32, width = screenWidth})
     setTextFormat('levelDifficulty', getFont(), 32, 'FFFFFF', 'right', {1.25, '000000'})
     addSubstateObject('levelDifficulty')

     if pauseStuff == nil or isNullValue(deathData) then
       deathTag = deathInfo[curCharacter]
     else
       deathTag = deathData
     end

     createObject('text', 'deathText', {text = deathTag..': '..deathCounter, x = 20, y = 15 + 64, width = screenWidth})
     setTextFormat('deathText', getFont(), 32, 'FFFFFF', 'right', {1.25, '000000'})
     addSubstateObject('deathText')

     createObject('text', 'practiceText', {text = getText('practice'):upper(), x = 20, y = 15 + 96, width = screenWidth})
     setTextFormat('practiceText', getFont(), 32, 'FFFFFF', 'right', {1.25, '000000'})
     setProperty('practiceText.visible', getProperty('practiceMode'))
     addSubstateObject('practiceText')

     createObject('text', 'botplayText', {text = getText('botplay'):upper(), x = 240, y = 630, width = screenWidth})
     setTextFormat('botplayText', getFont(), 32, 'FFFFFF', 'right', {1.25, '000000'})
     setProperty('botplayText.visible', getProperty('cpuControlled'))
     addSubstateObject('botplayText')

     createObject('text', 'chartingText', {text = getText('chart'), x = 240, y = 660, width = screenWidth})
     setTextFormat('chartingText', getFont(), 32, 'FFFFFF', 'right', {1.25, '000000'})
     setProperty('chartingText.visible', getPropertyFromClass('PlayState', 'chartingMode'))
     addSubstateObject('chartingText')

     createObject('text', 'speedText', {text = getText('speedControl'), x = 410, y = 15})
     setTextFormat('speedText', getFont(), 32, 'FFFFFF', 'right', {1.25, '000000'})
     setProperty('speedText.visible', getProperty('practiceMode'))
     addSubstateObject('speedText')

     setProperty('leveInfo.alpha', 0)
     setProperty('levelDifficulty.alpha', 0)
     setProperty('deathText.alpha', 0)
     setProperty('practiceText.alpha', 0)
     setProperty('botplayText.alpha', 0)
     setProperty('chartingText.alpha', 0)
     setProperty('speedText.alpha', 0)

     setProperty('levelInfo.x', screenWidth - (getProperty('levelInfo.width') + 20))
     setProperty('levelDifficulty.x', screenWidth - (getProperty('levelDifficulty.width') + 20))
     setProperty('deathText.x', screenWidth - (getProperty('deathText.width') + 20))
     setProperty('practiceText.x', screenWidth - (getProperty('practiceText.width') + 20))
     setProperty('botplayText.x', screenWidth - (getProperty('botplayText.width') + 20))
     setProperty('chartingText.x', screenWidth - (getProperty('chartingText.width') + 20))

     doTweenAlpha('pausebg', 'pausebg', 0.6, 0.4, 'quartInOut')

     -- These will be used until it's not on 0.7+ --
     runHaxeCode([[
        FlxTween.tween(game.getLuaObject('levelInfo'), {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
        FlxTween.tween(game.getLuaObject('levelDifficulty'), {alpha: 1, y: ]]..getProperty('levelDifficulty.y')..[[ + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
        FlxTween.tween(game.getLuaObject('deathText'), {alpha: 1, y: ]]..getProperty('deathText.y')..[[ + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
        FlxTween.tween(game.getLuaObject('practiceText'), {alpha: 1, y: ]]..getProperty('practiceText.y')..[[ + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
        FlxTween.tween(game.getLuaObject('botplayText'), {alpha: 1, y: ]]..getProperty('botplayText.y')..[[ + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.35});
        FlxTween.tween(game.getLuaObject('chartingText'), {alpha: 1, y: ]]..getProperty('chartingText.y')..[[ + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.4});
        FlxTween.tween(game.getLuaObject('speedText'), {alpha: 1, y: ]]..getProperty('speedText.y')..[[ + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
     ]])

     makeLuaSprite('logo', 'Credits_LeftSide', -260, 0)
     addSubstateObject('logo')
     doTweenX('logo', 'logo', -60, 1.2, 'elasticOut')

     makeAnimatedLuaSprite('logoBl', 'DDLCStart_Screen_Assets', -160, -40)
     scaleObject('logoBl', 0.5, 0.5)
     addByPrefix('logoBl', 'bump', 'logo bumpin', 24, true)
     addSubstateObject('logoBl')
     doTweenX('logoBl', 'logoBl', 40, 1.2, 'elasticOut')

     if isAndroid then
        for i = 1, #buttonSprites do
           createButton(buttonSprites[i], 'Android_Buttons', 0, 0, 0.7, 'substate')
           showButton('left', false)
           showButton('right', false)
           showButton('reset', false)
           setPosition('upButton', 400, 545)
           setPosition('downButton', 400, 635)
           setPosition('leftButton', 590, 635)
           setPosition('rightButton', 500, 635)
           setPosition('confirmButton', 750, 635)
           setPosition('exitButton', 840, 635)
           setPosition('resetButton', 930, 635)
        end
     end

     regenMenu(pauseOG)

     createObject('text', 'creditsText', {text = getText('credits'), x = 5, y = screenHeight - 20})
     setTextFormat('creditsText', getFont(), 16, 'FFFFFF', 'left', {1, '000000'})
     setProperty('creditsText.alpha', 0)
     addSubstateObject('creditsText')
     runHaxeCode([[FlxTween.tween(game.getLuaObject('creditsText'), {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});]])

     makeLuaText('controlsText', getText('control'), 200, screenWidth - 200, screenHeight - 500)
     setTextFormat('controlsText', getFont(), 16, getFlxColor('WHITE'), 'left')
     setProperty('controlsText.alpha', 0)

     createObject('graphic', 'controlsBG', {x = 1070, y = 215, width = 220, height = getProperty('controlsText.height') + 15, color = '808080'})
     setProperty('controlsBG.alpha', 0.5)
     addSubstateObject('controlsBG')

     createObject('graphic', 'controlsButton', {x = getProperty('controlsBG.x') - 30, y = getProperty('controlsBG.y'), width = 30, height = 30, color = 'FF0000'})
     setProperty('controlsButton.alpha', 0.5)
     addSubstateObject('controlsButton')

     makeLuaText('controlArrow', '>', 0, getProperty('controlsButton.x') + 5, getProperty('controlsButton.y'))
     setTextSize('controlArrow', 28)
     setTextBorder('controlArrow', 2, '000000')
     addSubstateObject('controlArrow')

     addSubstateObject('controlsText')
     runHaxeCode([[FlxTween.tween(game.getLuaObject('controlsText'), {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});]])

     if pauseStyle == 'libitina' then
       pauseSound('pauseMusic')
       setProperty('logoBl.visible', false)
       loadGraphic('logo', 'LibitinaPause')

     elseif pauseStyle == 'vallhalla' then
       setProperty('speedText.x', getProperty('speedText.x') + 60)
       setProperty('logoBl.visible', false)
       loadGraphic('logo', 'Va11Pause')
       setProperty('logo.antialiasing', false)
     end

     if customCursor then
       makeLuaSprite('pauseCursor', 'cursor')
       addSubstateObject('pauseCursor')
     end
   elseif tag == 'DokiPauseSecret' then
      daPath = 'pause/pauseAlt/'
      createObject('graphic', 'pausebg', {width = screenWidth * 3, height = screenHeight * 3, color = '000000'})
      setProperty('pausebg.alpha', 1)
      addSubstateObject('pausebg')

      makeLuaSprite('bg', daPath .. 'pauseBG')
      addSubstateObject('bg')

      makeAnimatedLuaSprite('bf', daPath .. 'bfLol', 0, 30)
      addByPrefix('bf', 'lol', 'funnyThing', 13)
      playAnim('bf', 'lol')
      addSubstateObject('bf')
      screenCenter('bf', 'X')

      makeAnimatedLuaSprite('replayButton', daPath .. 'pauseUI', screenWidth * 0.28, screenHeight * 0.7)
      addByPrefix('replayButton', 'idle', 'bluereplay', 0, false)
      addByPrefix('replayButton', 'selected', 'yellowreplay', 0, false)
      playAnim('replayButton', 'idle')
      addSubstateObject('replayButton')

      makeAnimatedLuaSprite('cancelButton', daPath .. 'pauseUI', screenWidth * 0.58, getProperty('replayButton.y'))
      addByPrefix('cancelButton', 'idle', 'bluecancel', 0, false)
      addByPrefix('cancelButton', 'selected', 'cancelyellow', 0, false)
      playAnim('cancelButton', 'selected')
      addSubstateObject('cancelButton')
 
      makeLuaSprite('pauseCursor', 'cursor')
      addSubstateObject('pauseCursor')
    end
end

local controlShown = true


function onCustomSubstateUpdate(tag, elapsed)
   if tag == 'DokiPause' then
     setPosition('pauseCursor', getMouseX('camOTHER'), getMouseY('camOTHER'))

     if getSoundVolume('pauseMusic') < 0.5 then
       setSoundVolume('pauseMusic', getSoundVolume('pauseMusic') + 0.01 * elapsed)
     elseif getSoundVolume('pauseMusic') > 0.5 then
       setSoundVolume('pauseMusic', 0.5)
     end

     movingCursor = getMouseProperty('justMoved')

     runHaxeCode([[
        if (FlxG.sound.music != null) {
          FlxG.sound.music.pause();
          game.vocals.pause();
        }
     ]])

     daMulti = skipMult * 1000

     if mouseReleasedObject('controlArrow') then
       tweenControl((controlShown and 'out' or 'in'))
     end

     if movingCursor then
        for i = 1, #menuItems do
            if i ~= curSelected then
              mouseOverlapOptions = mouseOverlaps('songText'..i)
                if mouseOverlapOptions then
                  curSelected = i
                  changeSelection()
                end
            end
        end
     end

     for i = 1, #menuItems do
        if mouseReleasedObject('songText'..i) then
           if currentState == 'menuSelection' then
             checkState()
           else
             checkSelected()
           end
        end
     end
	
     if getMouseProperty('wheel') ~= 0 then
       changeSelection(-getMouseProperty('wheel'))
     end

     daSelection = menuItems[curSelected]
     setProperty('skipTimeText.visible', (daSelection == 'Skip Time'))
     if isAndroid and currentState == 'debug' then
       showButtons('practice', (daSelection == 'Skip Time'))
     end
     switch(daSelection, {
       ['Skip Time'] = function()
          if (isAndroid and mouseReleasedObject('rightButton') or keyboardJustPressed('LEFT')) then
            playButtonAnim('right', 'pressed')
            playSound('scrollMenu', 0.4)
            curTime = curTime - daMulti
            updateSkipTimeText()
             if curTime < 1 then
               curTime = getProperty('songLength')
             end
          end
          if (isAndroid and mouseReleasedObject('leftButton') or keyboardJustPressed('RIGHT')) then
            playButtonAnim('left', 'pressed')
            playSound('scrollMenu', 0.4)
            curTime = curTime + daMulti
            updateSkipTimeText()
             if curTime > songLength then
               curTime = 0
             end
          end
          if keyboardJustPressed('K') then
            skipMult = skipMult - (skipMult ~= 1 and 1 or 0)
            updateSkipTimeText()
          elseif keyboardJustPressed('L') then
            skipMult = skipMult + 1
            updateSkipTimeText()
          elseif (isAndroid and mouseReleasedObject('resetButton') or keyboardJustPressed('R')) then
            playButtonAnim('reset', 'pressed')
            curTime = getSongPosition()
            skipMult = 1
            updateSkipTimeText()
          end
       end
     })

     for i = 1, #buttonSprites do
        playButtonAnim(buttonSprites[i], 'idle', true)
     end

     if isAndroid then
       addControlsAndroid() 
     else
       addControls()
     end

    elseif tag == 'DokiPauseSecret' then
      if not selectedSomethin then
        if mouseOverlaps('cancelButton', 'other') then
          replaySelect = false 
          playAnim('cancelButton', 'selected', true)
          playAnim('replayButton', 'idle', true)
          canPress = false

        elseif mouseOverlaps('replayButton', 'other') then
          replaySelect = true
          playAnim('cancelButton', 'idle', true)
          playAnim('replayButton', 'selected', true)
          canPress = false
        else
          canPress = true
        end
        if keyboardJustPressed('LEFT') or keyboardJustPressed(controls.scrollLeft) or keyboardJustPressed('RIGHT') or keyboardJustPressed(controls.scrollRight) then
          changeThing()
        elseif keyboardJustPressed('ENTER') or keyboardJustPressed(controls.confirm) or mouseReleasedOnObject('replayButton', 'other') or mouseReleasedOnObject('cancelButton', 'other') then
          if replaySelect then
            restartSong()
          else
            exitSong()
          end
        elseif keyboardJustPressed('ESCAPE') or keyboardJustPressed(controls.escape) then
          playSound('cancelMenu')
          closeCustomSubstate()
            end
        end
    end
end

function onCustomSubstateDestroy(tag)
   if tag == 'DokiPause' then
     stopSound('pauseMusic')
   end
end

function onTimerCompleted(tag)
   if tag == 'close' then
      destroy()
   end
end

function showCursor(show)
   if customCursor then
     setProperty((getProperty('paused') and 'pauseCursor' or 'gameCursor')..'.visible', show)
   else
     setMouseProperty('visible', show)
   end
end

function tweenControl(type)
   if type:lower() == 'in' then
     setTextString('controlArrow', '>')
     doTweenX('controlsBG', 'controlsBG', 1070, 0.5)
     doTweenX('controlsButton', 'controlsButton', 1040, 0.5)
     doTweenX('controlArrow', 'controlArrow', 1045, 0.5)
     doTweenX('controlsText', 'controlsText', screenWidth - 200, 0.5)
     controlShown = true
   elseif type:lower() == 'out' then
     setTextString('controlArrow', '<')
     doTweenX('controlsBG', 'controlsBG', 1280, 0.5)
     doTweenX('controlsButton', 'controlsButton', 1250, 0.5)
     doTweenX('controlArrow', 'controlArrow', 1255, 0.5)
     doTweenX('controlsText', 'controlsText', 1280, 0.5)
     controlShown = false
   end
end

function updatePauseOptions()
   difficultyLength = getPropertyFromClass('CoolUtil', 'difficulties.length')
   if isAndroid then
      if chartingMode then
         if difficultyLength < 2 then
            table.remove(pauseOG, 3)
            table.insert(pauseOG, 3, 'Debug Options')
         else
            table.insert(pauseOG, 4, 'Debug Options')
         end

      elseif isStoryMode then
         if difficultyLength < 2 then
            table.remove(pauseOG, 3)
            table.insert(pauseOG, 3, 'Chart Editor')
         else
            table.insert(pauseOG, 4, 'Chart Editor')
         end

      else
         if difficultyLength < 2 then
            table.remove(pauseOG, 3)
            table.insert(pauseOG, 3, 'Practice Mode')
            table.insert(pauseOG, 4, 'Chart Editor')
         else
            table.insert(pauseOG, 3, 'Practice Mode')
            table.insert(pauseOG, 4, 'Chart Editor')
         end
      end
   else
      if chartingMode then
         if difficultyLength < 2 then
            table.remove(pauseOG, 3)
            table.insert(pauseOG, 3, 'Debug Options')
         else
            table.insert(pauseOG, 4, 'Debug Options')
         end

      elseif isStoryMode then
         if difficultyLength < 2 then
            table.remove(pauseOG, 3)
         end

      else
         if difficultyLength < 2 then
            table.remove(pauseOG, 3)
            table.insert(pauseOG, 3, 'Practice Mode')
         else
            table.insert(pauseOG, 3, 'Practice Mode')
            end
        end
    end
    for i = 1, difficultyLength do
      diff = ''..getPropertyFromClass('CoolUtil', 'difficulties')[i]
      table.insert(difficultyChoices, diff)
    end
    table.insert(difficultyChoices, 'Back')
end

function forcePause(pauseChar)
   pauseChar = pauseChar or artData
   forcePauseArt = pauseChar
end
     
function changeStyle(style)
   style = style or ''
   pauseStyle = style
end

function pauseState(canSecret)
   setProperty('persistentUpdate', false)
   setProperty('persistentDraw', true)
   setProperty('paused', true)
   runHaxeCode([[
     if (FlxG.sound.music != null) {
       FlxG.sound.music.pause();
       game.vocals.pause();
     }
   ]])

   if getRandomBool(0.005) and canSecret then
     openCustomSubstate('DokiPauseSecret', false)
     currentPause = 'Gitaroo'
   else
     openCustomSubstate('DokiPause', false)
     currentPause = ''
   end
end

function addControls()
   if not selectedSomethin then
     if keyboardJustPressed('UP') or keyboardJustPressed(controls.scrollUp) then
       changeSelection(-1)

     elseif keyboardJustPressed('DOWN') or keyboardJustPressed(controls.scrollDown) then
       changeSelection(1)
     end

     if currentState == '' then
       if keyboardJustPressed('ESCAPE') or keyboardJustPressed(controls.escape) then
          playSound('cancelMenu')
          closeMenu()
       end

       if keyboardJustPressed('ENTER') then
         checkSelected()
       end
     elseif currentState == 'debug' then
       if keyboardJustPressed('ESCAPE') or keyboardJustPressed(controls.escape) then
          playSound('cancelMenu')
          currentState = ''
          regenMenu(pauseOG)
       end

       if keyboardJustPressed('ENTER') or keyboardJustPressed(controls.confirm) then
         checkSelected()
       end
     elseif currentState == 'difficulty' then
       if keyboardJustPressed('ESCAPE') or keyboardJustPressed(controls.escape) then
          playSound('cancelMenu')
          currentState = ''
          regenMenu(pauseOG)
       end

       if keyboardJustPressed('ENTER') or keyboardJustPressed(controls.confirm) then
         if menuItems[curSelected] == 'Back' then
           checkSelected()
         else
           loadSong(songPath, curSelected-1)
         end
       end
     elseif currentState == 'menuSelection' then
        if keyboardJustPressed('ESCAPE') or keyboardJustPressed(controls.escape) then
          playSound('cancelMenu')
          currentState = ''
          regenMenu(pauseOG)
        end
        if keyboardJustPressed('ENTER') or keyboardJustPressed(controls.confirm) then
          checkState()
        end
     end

     if keyboardJustPressed('N') and keyboardJustPressed('M') then
        playSound('confirmMenu')
        currentState = 'menuSelection'
        regenMenu(menuChoices)
     end
       

     if keyboardJustPressed('E') or keyboardJustPressed(controls.toggle) then
       setProperty('controlsText.visible', not getProperty('controlsText.visible'))
     end

     if selectedPractice then
        if keyboardPressed('CONTROL') and keyboardJustPressed('LEFT') or keyboardJustPressed(controls.scrollLeft) then
          playSound('scrollMenu')
          setProperty('playbackRate', getProperty('playbackRate') - 0.05)
           if playbackRate < 0.25 then
             setProperty('playbackRate', 0.25)
           end
           updatePlaybackText()

        elseif keyboardPressed('CONTROL') and keyboardJustPressed('RIGHT') or keyboardJustPressed(controls.scrollRight) and selectedPractice then
          playSound('scrollMenu')
          setProperty('playbackRate', getProperty('playbackRate') + 0.05)
           if playbackRate > 3 then
             setProperty('playbackRate', 3)
           end
           updatePlaybackText()

        elseif keyboardPressed('CONTROL') and keyboardJustPressed('R') or keyboardJustPressed(controls.reset) then
           playSound('cancelMenu')
           setProperty('playbackRate', 1)
            updatePlaybackText()
            end
        end
    end
end

function addControlsAndroid()
   if not selectedSomethin then
     if mouseReleasedObject('upButton') then
       playButtonAnim('up', 'pressed')
       changeSelection(-1)

     elseif mouseReleasedObject('downButton') then
       playButtonAnim('down', 'pressed')
       changeSelection(1)
     end

     if currentState == '' then
       if mouseReleasedObject('exitButton') then
          playButtonAnim('exit', 'pressed')
          playSound('cancelMenu')
          closeMenu()
       end

       if mouseReleasedObject('confirmButton') then
         playButtonAnim('confirm', 'pressed')
         checkSelected()
       end

     elseif currentState == 'debug' then
       if mouseReleasedObject('exitButton') then
          playButtonAnim('exit', 'pressed')
          playSound('cancelMenu')
          currentState = ''
          regenMenu(pauseOG)
       end

       if mouseReleasedObject('confirmButton') then
         playButtonAnim('confirm', 'pressed')
         checkSelected()
       end

     elseif currentState == 'difficulty' then
       if mouseReleasedObject('exitButton') then
          playButtonAnim('exit', 'pressed')
          playSound('cancelMenu')
          currentState = ''
          regenMenu(pauseOG)
       end

       if mouseReleasedObject('confirmButton') then
          playButtonAnim('confirm', 'pressed')
          if menuItems[curSelected] == 'Back' then
            checkSelected()
          else
            loadSong(songPath, curSelected-1)
          end
       end

     elseif currentState == 'menuSelection' then
        if mouseReleasedObject('exitButton') then
          playButtonAnim('exit', 'pressed')
          playSound('cancelMenu')
          currentState = ''
          regenMenu(pauseOG)
        end
        if mouseReleasedObject('confirmButton') then
          playButtonAnim('confirm', 'pressed')
          checkState()
        end
     end

     if selectedPractice then
        if mouseReleasedObject('rightButton') then
          playButtonAnim('right', 'pressed')
          playSound('scrollMenu')
          setProperty('playbackRate', getProperty('playbackRate') - 0.05)
           if playbackRate < 0.25 then
             setProperty('playbackRate', 0.25)
           end
           updatePlaybackText()

        elseif mouseReleasedObject('leftButton') then
          playButtonAnim('left', 'pressed')
          playSound('scrollMenu')
          setProperty('playbackRate', getProperty('playbackRate') + 0.05)
           if playbackRate > 3 then
             setProperty('playbackRate', 3)
           end
           updatePlaybackText()

        elseif mouseReleasedObject('resetButton') then
          playButtonAnim('reset', 'pressed')
           playSound('cancelMenu')
           setProperty('playbackRate', 1)
            updatePlaybackText()
            end
        end
    end
end

function mouseReleasedObject(obj)
   return mouseReleasedOnObject(obj, 'other')
end

function regenMenu(source)
     for i = 1, #menuItems do 
       removeText('songText'..i)
       destroyText('songText'..i)
     end

     menuItems = source
 
     textX = 50
     if (pauseStyle == 'vallhalla') then textX = textX + 25 end

   for i = 1, #menuItems do 
     makeLuaText('songText'..i, menuItems[i], 0, -350, 370 + (i * 50))
       if pauseStyle == 'libitina' then 
         setTextFormat('songText'..i, getFont('dos'), 27, '8BA9F0', 'LEFT')

       elseif pauseStyle == 'vallhalla' then
         setTextFormat('songText'..i, getFont('waifu'), 32, 'FFFFFF', 'LEFT')
         setProperty('songText'..i..'.y', getProperty('songText'..i..'.y') - 75)
         setProperty('songText'..i..'.antialiasing', false)

       else
         setTextFormat('songText'..i, getFont('riffic'), 27, 'FFFFFF', 'LEFT')
         setTextBorder('songText'..i, 2, itmColor)
       end
      addSubstateObject('songText'..i)
      doTweenX('songText'..i, 'songText'..i, textX, 1.2 + (i * 0.2), 'elasticOut')

      if menuItems[i] == 'Skip Time' then
          makeLuaText('skipTimeText', '', 0, 0, 0)

          if pauseStyle == 'libitina' then
           setTextBorder('skipTimeText', 0, getFlxColor('TRANSPARENT'))
           setTextFormat('skipTimeText', getFont('dos'), 27, '8BA9F0', 'center')

          elseif pauseStyle == 'vallhalla' then
           setTextBorder('skipTimeText', 0, getFlxColor('TRANSPARENT'))
           setProperty('skipTimeText.antialiasing', false)
           setTextFormat('skipTimeText', getFont('waifu'), 32, getFlxColor('WHITE'), 'center')

         else
           setTextBorder('skipTimeText', 2, itmColor)
           setTextFormat('skipTimeText', getFont('riffic'), 27, getFlxColor('WHITE'), 'center')
         end
        addSubstateObject('skipTimeText')
        doTweenX('skipTimeText', 'skipTimeText', textX + 130, 1.4, 'elasticOut')

        updateSkipTextStuff()
        updateSkipTimeText()
      end
   end

   if customCursor then
     makeLuaSprite('pauseCursor', 'cursor')
     addSubstateObject('pauseCursor')
   end
   curSelected = 1
   changeSelection()
end

function changeSelection(change)
   change = change or 0
   playSound('scrollMenu', 0.7)
   daSelection = menuItems[curSelected]
   curSelected = curSelected + change;

   if curSelected < 1 then
     curSelected = #menuItems
   elseif curSelected > #menuItems then
     curSelected = 1
   end

   for i = 1, #menuItems do
      if curSelected > 6 then
          cancelTween('itmTween'..i)
          doTweenY('itmTween'..i, 'songText'..i, 330 + (i * 50), 0.3)
      end
      if curSelected < 7 then
         cancelTween('itmTween'..i)
         doTweenY('itmTween'..i, 'songText'..i, 370 + (i * 50), 0.3)
      end
      switch(pauseStyle, {
        ['libitina'] = function()
          setTextFormat('songText'..i, getFont('dos'), 27, getFlxColor('WHITE'), 'left')
          if curSelected ~= i then
            setTextFormat('songText'..i, getFont('dos'), 27, itmColor, 'left')
          end
        end,
        ['vallhalla'] = function()
          setTextFormat('songText'..i, getFont('dos'), 27, itmColor, 'left')
          if curSelected ~= i then
            setTextFormat('songText'..i, getFont('dos'), 27, getFlxColor('WHITE'), 'left')
          end
        end,
        ['default'] = function()
          setTextBorder('songText'..i, 2, selColor)
          if curSelected ~= i then
            setTextBorder('songText'..i, 2, itmColor)
          end
        end
      })
   end
   if currentState == 'menuSelection' then
     updateDescription()
   end
end

function updatePlaybackText()
   setTextString('speedText', 'Speed: '..playbackRate..'x')
   if timeBarType == 'Time Left' then
     setTextString('timeTxt', songName..(playbackRate ~= 1 and ' ('..playbackRate..'x)' or '')..' ('..formatTime(remainingTime())..')')
     setTextString('timeProgressTxt', songName..(playbackRate ~= 1 and ' ('..playbackRate..'x)' or '')..' ('..formatTime(remainingTime())..')')
   elseif timeBarType == 'Song Name' then
     setTextString('timeTxt', songName..(playbackRate ~= 1 and ' ('..playbackRate..'x)' or '')..' ('..difficultyName..')')
     setTextString('timeProgressTxt', songName..(playbackRate ~= 1 and ' ('..playbackRate..'x)' or '')..' ('..difficultyName..')')
   elseif timeBarType == 'Time Elapsed' then
     setTextString('timeTxt', songName..(playbackRate ~= 1 and ' ('..playbackRate..'x)' or '')..' ('..formatTime(getSongPosition() - noteOffset)..')')
     setTextString('timeProgressTxt', songName..(playbackRate ~= 1 and ' ('..playbackRate..'x)' or '')..' ('..formatTime(getSongPosition() - noteOffset)..')')
   end
end 

function updateSkipTextStuff()
   setProperty('skipTimeText.x', 0)
   setProperty('skipTimeText.y', getProperty('songText1.y'))
   setProperty('skipTimeText.visible', (getProperty('skipTimeText.alpha') >= 1))
end

function updateSkipTimeText()
   setTextString('skipTimeText', formatTime(curTime)..' / '..formatTime(remainingTime())..(skipMult ~= 1 and ' ('..skipMult..'x)' or ''))
end

function updateDescription()
  local daChoice = menuItems[curSelected]
   switch(daChoice, {
      ['Title'] = function() 
        setTextString('creditsText', 'Takes you back in the Title Screen')
      end,
      ['Main Menu'] = function() 
        setTextString('creditsText', 'Takes you back in the Main Menu Selection Screen')
      end,
      ['Story'] = function() 
        setTextString('creditsText', 'Takes you back in the Story Mode Screen')
      end,
      ['Freeplay'] = function() 
        setTextString('creditsText', 'Takes you back in the Song Selection/Freeplay Menu')
      end,
      ['Credits'] = function() 
        setTextString('creditsText', 'Takes you back in the Credits Menu')
      end,
      ['Options'] = function() 
        setTextString('creditsText', 'Takes you back in the Options Menu')
      end,
      ['Back'] = function() 
        setTextString('creditsText', 'Takes you back in the Selection Menu')
      end,
      ['default'] = function() 
        setTextString('creditsText', getText('credit'))
      end
   })
end

function checkSelected()
   local daChoice = menuItems[curSelected]
     switch(daChoice, {
           ['Back'] = function()
             playSound('cancelMenu')
             currentState = ''
             regenMenu(pauseOG)
           end,
           ['Skip Time'] = function()
             skipTime(curTime)
             closeCustomSubstate()
             if isAndroid then showButtons('practice', getProperty('practiceMode')) end
           end,
           ['Practice Mode'] = function()
             setProperty('practiceMode', not getProperty('practiceMode'))
             setProperty('practiceText.visible', getProperty('practiceMode'))
             setProperty('practiceTxt.visible', getProperty('practiceMode'))
             setProperty('speedText.visible', getProperty('practiceMode'))
             if isAndroid then showButtons('practice', getProperty('practiceMode')) end
             playSound((getProperty('practiceMode') and 'confirmMenu' or 'cancelMenu'))
             selectedPractice = not selectedPractice
           end,
           ['Botplay'] = function()
             setProperty('cpuControlled', not getProperty('cpuControlled'))
             setProperty('botplayText.visible', getProperty('cpuControlled'))
             setProperty('botplayTxt.visible', getProperty('cpuControlled'))
             playSound((getProperty('cpuControlled') and 'confirmMenu' or 'cancelMenu'))
           end,
           ['Leave Debug'] = function()
             setPropertyFromClass('PlayState', 'chartingMode', false)
             restartSong()
           end,
           ['Resume'] = function()
             closeMenu()
             playSound('confirmMenu')
           end,
           ['Restart Song'] = function()
             restartSong()
           end,
           ['Change Difficulty'] = function()
             currentState = 'difficulty'
             regenMenu(difficultyChoices)
           end,
           ['Debug Options'] = function()
             currentState = 'debug'
             regenMenu(debugItems)
           end,
           ['Chart Editor'] = function()
             runHaxeCode('game.openChartEditor();')
           end,
           ['Back'] = function()
              playSound('cancelMenu')
              currentState = ''
              regenMenu(pauseOG)
           end,
           ['Exit To Menu'] = function()
             exitSong()
             playSound('cancelMenu')
           end
     })
end

function checkState()
   daChoice = menuItems[curSelected]
     switch(daChoice, {
        ['Title'] = function() switchState('TitleState', true) end,
        ['Main Menu'] = function() switchState('MainMenuState', true) end,
        ['Story'] = function() switchState('StoryMenuState', true) end,
        ['Freeplay'] = function() switchState('FreeplayState', true) end,
        ['Credits'] = function() switchState('CreditsState', true) end,
        ['Options'] = function() switchState('options.OptionsState', true) end,
        ['Back'] = function()
          playSound('cancelMenu')
          currentState = ''
          regenMenu(pauseOG)
          updateDescription()
        end
    })
end
 
function showButtons(type, show)
   if type == 'practice' then
     showButton('left', show)
     showButton('right', show)
     showButton('reset', show)
   else
     showButton('left', show)
     showButton('right', show)
   end
end

function createObject(type, tag, vars)
    type = type or ''
    if type == 'animated' or type == 'anim' then
      makeAnimatedLuaSprite(tag, vars.image, vars.x, vars.y)
    elseif type == 'text' then
      makeLuaText(tag, vars.text, vars.width, vars.x, vars.y)
      setTextSize(tag, vars.size)
    elseif type == 'graphic' then
      makeLuaSprite(tag, nil, vars.x, vars.y)
      makeGraphic(tag, vars.width, vars.height, vars.color)
    else
      makeLuaSprite(tag, vars.img, vars.x, vars.y)
    end
end

function addByPrefix(tag, animName, animXML, fps, loop)
   addAnimationByPrefix(tag, animName, animXML, fps, loop)
end

function setTextFormat(tag, font, size, color, align, border)
   color = color or 'FFFFFF'
   size = size or 8
   font = font or 'vcr.ttf'
   setTextFont(tag, font)
   setTextSize(tag, size)
   setTextColor(tag, color)
   setTextAlignment(tag, align)
   if border ~= nil or border ~= '' then
     setTextBorder(tag, border[1] or 1, border[2] or 'FFFFFF')
   end
end

function getText(type)
   if type == 'practice' then
     daText = 'Practice Mode'
   elseif type == 'botplay' or type == 'bot' then
     daText = 'Botplay'
   elseif type == 'songname' or type == 'song' then
     daText = songName
   elseif type == 'difficulty' or type == 'diff' then
     daText = difficultyName
   elseif type == 'charting' or type == 'chartingMode' or type == 'chart' then
     daText = 'Charting Mode'
   elseif type == 'speedControl' or type == 'speedcont' then
     daText = 'Speed: '..playbackRate..'x (Control + Left/Right)'
   elseif type == 'speed' or type == 'speedNum' then
     daText = 'Speed: '..playbackRate..'x'
   elseif type == 'credits' or type == 'scriptowners' then
     daText = 'Script By: MCBoy2038 - Ported/Recreation By: Zaxh - Original By: Team TBD (DDTO+)'
   elseif type == 'controls' or type == 'control' then
      if isAndroid then
        daText = 'CONTROLS (Android):\n--[BUTTONS]--\n[Up/Down] Change selection\n[Left] Reduces playback speed/rate (Limit: 0.25)\n[Right] Adds playback speed/rate (Limit: 3)\n[D] Resets playback speed/rate\n[E] Confirm selection\n[X] Go Back/Resume\nOr just literally use the mouse lmao'
      else
        daText = 'CONTROLS (PC):\n--[ARROW KEYS]--\n[Up/Down or '..string.upper(controls.scrollUp)..'/'..string.upper(controls.scrollDown)..'] Change selection\n[CONTROL+Left/'..string.upper(controls.scrollLeft)..'] Reduces playback speed/rate (Limit: 0.25)\n[CONTROL+Right/'..string.upper(controls.scrollRight)..'] Adds playback speed/rate (Limit: 3)\n[CONTROL+R/'..string.upper(controls.reset)..'] Resets playback speed/rate\n[ENTER/'..string.upper(controls.confirm)..'] Confirm selection\n[ESCAPE/'..string.upper(controls.escape)..'] Go Back/Resume\nOr just literally use the mouse lmao'
      end
   end
   return daText
end

function setMouseProperty(prop, val)
   setPropertyFromClass('flixel.FlxG', 'mouse.'..prop, val)
end

function getMouseProperty(prop)
   return getPropertyFromClass('flixel.FlxG', 'mouse.'..prop)
end

function closeMenu()
      --Tweens!
        canPress = false
        currentState = 'closing'
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
        cancelTween('chartingText')
        cancelTween('creditsText')
        cancelTween('controlsText')
        cancelTween('skipTimeText')

	for i = 1, #menuItems do
           cancelTween('songText'..i)
           doTweenX('songText'..i, 'songText'..i, -350, 0.5, 'elasticOut')
	end

	for i = 1, #buttonSprites do
           cancelTween('songButton'..i)
           doTweenX('songButton'..i, 'songButton'..i, -350, 0.5, 'elasticOut')
        end

        doTweenX('pauseArt', 'pauseArt', screenWidth, 0.7, 'quartInOut')

        doTweenX('logo', 'logo', -500, 0.7, 'quartInOut')
        doTweenX('logoBl', 'logoBl', -500, 0.7, 'quartInOut')
        doTweenAlpha('pausebg', 'pausebg', 0, 0.6, 'quartInOut')

        doTweenAlpha('levelInfo', 'levelInfo', 0, 0.6, 'quartInOut')
        doTweenAlpha('levelDifficulty', 'levelDifficulty', 0, 0.6, 'quartInOut')
        doTweenAlpha('deathText', 'deathText', 0, 0.6, 'quartInOut')
        doTweenAlpha('practiceText', 'practiceText', 0, 0.6, 'quartInOut')
        doTweenAlpha('speedText', 'speedText', 0, 0.6, 'quartInOut')

        doTweenAlpha('botplayText', 'botplayText', 0, 0.6, 'quartInOut')
        doTweenAlpha('chartingText', 'chartingText', 0, 0.6, 'quartInOut')
        doTweenAlpha('creditsText', 'creditsText', 0, 0.6, 'quartInOut')
        doTweenAlpha('controlsText', 'controlsText', 0, 0.6, 'quartInOut')
        doTweenAlpha('skipTimeText', 'skipTimeText', 0, 0.6, 'quartInOut')
        setProperty('pauseCursor.visible', false)
        pauseSound('pauseMusic')

        runTimer('close', 0.6)
end

function destroy()
     removeSprite('pauseArt')
     removeSprite('logo')
     removeSprite('logoBl')
     removeSprite('pausebg')
     removeSprite('pauseCursor')

     for i = 1, #menuItems do
        removeLuaText('songText'..i)
     end
     removeText('levelInfo')
     removeText('levelDifficulty')
     removeText('deathText')
     removeText('practiceText')
     removeText('speedText')

     removeText('botplayText')
     removeText('chartingText')
     removeText('creditsText')
     removeText('controlsText')
     removeText('skipTimeText')
     destroySound('pauseMusic')
     if isAndroid or showCursor then
       showCursor(true)
       setProperty('gameCursor.visible', true)
     end
     closeCustomSubstate()
     currentState = ''
end

function removeText(tag)
  runHaxeCode('game.modchartTexts.remove("]]..tag..[[");')
end

function removeSprite(tag)
  runHaxeCode('game.modchartSprites.remove("]]..tag..[[");')
end

function removeSound(tag)
  runHaxeCode('game.modchartSounds.remove("]]..tag..[[");')
end

function destroyText(tag)
  runHaxeCode([[
    var pee:FlxText = game.modchartTexts.get("]]..tag..[[");
    pee.kill();
    pee.destroy();
  ]])
end

function destroySprite(tag)
  runHaxeCode([[
    var pee:FlxText = game.modchartSprites.get("]]..tag..[[");
    pee.kill();
    pee.destroy();
  ]])
end

function destroySound(tag)
  runHaxeCode([[
    var pee:FlxText = game.modchartSounds.get("]]..tag..[[");
    pee.kill();
    pee.destroy();
  ]])
end

function androidControlReleased(key)
  runHaxeCode('return FlxG.android.justReleased.]]..key..[[;')
end

function skipTime(position, clearNotes)
   position = position or getSongPosition()
   clearNotes = clearNotes or true
   if clearNotes then runHaxeCode([[game.clearNotesBefore(]]..position..[[);]]) end
   runHaxeCode([[game.setSongTime(]]..position..[[);]])
end

function createButton(tag, image, x, y, scale, front, show)
   show = show or true
   makeAnimatedLuaSprite(tag..'Button', 'android/'..image, x, y)
   addAnimationByPrefix(tag..'Button', 'idle', tag..' idle', 0, false)
   addAnimationByPrefix(tag..'Button', 'pressed', tag..' selected', 0, false)
   playAnim(tag..'Button', 'pressed', true)
   setProperty(tag..'Button.visible', show)
   scaleObject(tag..'Button', scale, scale)
   if front == 'substate' then
     addSubstateObject(tag..'Button')
   else
     addLuaSprite(tag..'Button', front)
     setObjectCamera(tag..'Button', 'other')
   end
end

function playButtonAnim(tag, anim, forced)
   forced = forced or true
   playAnim(tag..'Button', anim, forced)
end

function showButton(tag, show)
  setProperty(tag..'Button.visible', show)
end

function precacheStuff()
   pausePath = 'pause/'
   pausePathAlt = 'pause/pauseAlt/'
   precacheImages({
      'android/Android_Buttons',
      pausePath..artData,
      'Credits_LeftSide',
      'DDLCStart_Screen_Assets',
      'DDLCStart_Screen_AssetsHUD',
      'LibitinaPause',
      'cursor',
      'Va11Pause',
      pausePathAlt..'pauseBG',
      pausePathAlt..'pauseUI'
   })
   precacheSounds({
      'scrollMenu',
      'cancelMenu',
      'confirmMenu',
      'disco'
   })
end

function addSubstateObject(tag)
    runHaxeCode([[
      object = game.getLuaObject("]]..tag..[[");
      if (object.cameras != null)
        object.cameras = null;
      CustomSubstate.instance.add(object);
   ]]) 
end

function precacheImages(imageArray)
   for i = 1, #imageArray do
      precacheImage(imageArray[i])
   end
end 

function precacheSounds(soundArray)
   for i = 1, #soundArray do
      precacheSound(soundArray[i])
   end
end 

function precacheMusics(musicArray)
   for i = 1, #musicArray do
      precacheSound(musicArray[i])
   end
end 

function getOptionData(var)
  return getData('ddtoOptions', var)
end

function setOptionData(var, val)
   saveData('ddtoOptions', var, val)
end

function saveData(dataGrp, dataField, dataValue)
  setDataFromSave(dataGrp, dataField, dataValue)
end

function getData(dataGrp, dataField, dataValue)
  return getDataFromSave(dataGrp, dataField, dataValue)
end

function switch(case, cases)
 if cases[case] ~= nil then
   return cases[case]()
 elseif cases.default ~= nil then
   return cases.default()
   end
end

--[[
ALL STATES TO SWITCH (default):

MainMenuState = the menu
FreeplayState = freeplay menu
AchievementsMenuState = achievement menu
CreditsState = credits menu
LoadingState = HTML5 loading menu
ModsMenuState = mod menu
PauseSubState = pause menu
StoryMenuState = story menu
TitleState = title part
GameOverSubstate = gameover part

OPTIONS (add a 'options.' at the start!):
OptionsState = options menu
GameplaySettingsSubstate = Gameplay Settings
GraphicsSettingSubState = Graphics Menu
VisualsUISubState = visuals and ui 
ControlsSubState = controls menu
NoteOffestState = Note offest menu
]]

function switchState(curState, allow)
    if allow == true then
        runHaxeCode('MusicBeatState.switchState(new '..curState..'());')
        local pauseMusic = string.gsub(string.lower(getPropertyFromClass('ClientPrefs', 'pauseMusic')), ' ', '-')
        switch(curState, {
          ['options.OptionsState'] = function() 
             if pauseMusic ~= 'none' then
               playMusic(pauseMusic)
             end
          end,
          ['default'] = function() playMusic('freakyMenu') end
        })
    elseif allow == false then
        runHaxeCode('')
    else
    debugPrint('ERROR (', debug.getinfo(1, "n").name..'): '..getPropertyFromClass('FunkinLua', 'script')..':'.. debug.getinfo(2, 'l').currentline..'', ': before switch to ', curState..', you need to confirm!', runHaxeCode)
    end
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
     else
       if luaDebugMode then
         debugPrint('getFont: Font Type: '..type..' Not Found')
       end
    end
   return font;
end

function setPosition(tag, x, y)
   x = x or get(tag, 'x')
   y = y or get(tag, 'y')
   setProperty(tag..'.x', x)
   setProperty(tag..'.y', y)
end

function setTextFormat(tag, font, size, color, alignment)
     setTextFont(tag, font)
     setTextSize(tag, size)
     setTextColor(tag, color)
     setTextAlignment(tag, alignment)
end

function multiKeyPressed(keysArray)
  for i = 1, #keysArray do
   return keyPressed(keysArray[i])
    end
end

function multiKeyJustPressed(keysArray)
  for i = 1, #keysArray do
   return keyJustPressed(keysArray[i])
    end
end

function multiKeyboardJustPressed(keysArray)
  for i = 1, #keysArray do
   return keyboardJustPressed(keysArray[i])
    end
end

function multiKeyboardPressed(keysArray)
  for i = 1, #keysArray do
   return keyboardPressed(keysArray[i])
    end
end

function mouseOverlaps(object, camera)
   camera = camera or 'other'
   if checkObject(object) and getMouseX(camera) > getProperty(object..'.x') and getMouseY(camera) > getProperty(object..'.y') and getMouseX(camera) < getProperty(object..'.x') + getProperty(object..'.width') and getMouseY(camera) < getProperty(object..'.y') + getProperty(object..'.height') then
     return true;
   end
   if not checkObject(object) then
     if luaDebugMode then
       debugPrint('mouseOverlaps: The object: '..object..' dosent exists')
     end
     return false
   end
end

function mouseReleasedOnObject(object, camera)
   camera = camera or 'other'
   if checkObject(object) and getMouseX(camera) > getProperty(object..'.x') and getMouseY(camera) > getProperty(object..'.y') and getMouseX(camera) < getProperty(object..'.x') + getProperty(object..'.width') and getMouseY(camera) < getProperty(object..'.y') + getProperty(object..'.height') and mouseReleased() then
     return true;
   end
   if not checkObject(object) then
     if luaDebugMode then
       debugPrint('mouseReleasedOnObject: The object: '..object..' dosent exists')
     end
     return false
   end
end

function mouseClickedOnObject(object, camera)
   camera = camera or 'other'
   if checkObject(object) and getMouseX(camera) > getProperty(object..'.x') and getMouseY(camera) > getProperty(object..'.y') and getMouseX(camera) < getProperty(object..'.x') + getProperty(object..'.width') and getMouseY(camera) < getProperty(object..'.y') + getProperty(object..'.height') and mouseClicked() then
     return true;
   end
   if not checkObject(object) then
     if luaDebugMode then
       debugPrint('mouseClickedOnObject: The object: '..object..' dosent exists')
     end
     return false
   end
end

function mousePressedOnObject(object, camera)
   camera = camera or 'other'
   if checkObject(object) and getMouseX(camera) > getProperty(object..'.x') and getMouseY(camera) > getProperty(object..'.y') and getMouseX(camera) < getProperty(object..'.x') + getProperty(object..'.width') and getMouseY(camera) < getProperty(object..'.y') + getProperty(object..'.height') and mousePressed() then
     return true;
   end
   if not checkObject(object) then
     if luaDebugMode then
       debugPrint('mousePressedOnObject: The object: '..object..' dosent exists')
     end
     return false
   end
end

function checkObject(obj, type)
  type = type or ''
    if type == 'sprite' then
      if luaSpriteExists(obj) then
        return true
      else
        return false
      end
    elseif type == 'text' then
      if luaTextExists(obj) then
        return true
      else
        return false
      end
    elseif type == 'sound' then
      if luaSoundExists(obj) then
        return true
      else
        return false
      end
    else
      if luaSpriteExists(obj) then
        return true
      elseif luaTextExists(obj) then
        return true
      elseif luaSoundExists(obj) then
        return true
      else
        return false
      end
   end
end

function isNullValue(var, includeBlank)
  includeBlank = includeBlank or false
  if includeBlank then
    if var == nil or var == '' then
      return true
    end
  else
    if var == nil then
      return true
    end
   end
end

function getFlxColor(color)
   color = color or 'BLACK'
   if color == 'BLACK' then
     color = '0xFF000000'
   elseif color == 'BLUE' then
     color = '0xFF0000FF'
   elseif color == 'BROWN' then
     color = '0xFF8B4513'
   elseif color == 'CYAN' then
     color = '0xFF00FFFF'
   elseif color == 'GRAY' or color == 'GREY' then
     color = '0xFF808080'
   elseif color == 'GREEN' then
     color = '0xFF008000'
   elseif color == 'LIME' then
     color = '0xFF00FF00'
   elseif color == 'MAGENTA' then
     color = '0xFFFF00FF'
   elseif color == 'ORANGE' then
     color = '0xFFFFA500'
   elseif color == 'PINK' then
     color = '0xFFFFC0CB'
   elseif color == 'PURPLE' then
     color = '0xFF800080'
   elseif color == 'RED' then
     color = '0xFFFF0000'
   elseif color == 'TRANSPARENT' then
     color = '0x00000000'
   elseif color == 'WHITE' then
     color = '0xFFFFFFFF'
   elseif color == 'YELLOW' then
     color = '0xFFFFFF00'
   else
      if luaDebugMode then
        debugPrint('getFlxColor: '..color..' Not Found')
      end
   end
   return color
end

function formatTime(millisecond)
    seconds = math.floor(millisecond / 1000)
    return string.format("%01d:%02d", (seconds / 60) % 60, seconds % 60)  
end

function remainingTime()
    return getProperty('songLength') - (getSongPosition() - noteOffset)
end

function onSoundFinished(name)
  if name == 'pauseMusic' then
      playSound('../music/disco', 0, 'pauseMusic')
    end 
end