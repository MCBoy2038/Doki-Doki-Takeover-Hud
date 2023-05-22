-- OPTIONS --
local OpponentHasSplash = false --allows opponent splash?

 -- PLAYER --
--options related to the splash (aplies in all song)--
local customSplashSkin = false --let's you have your custom splashes
local isLibitina = false --sets the splash into libitina version
local splashTexture = 'noteSplashes' --change texture of the splash

 -- OPPONENT --
--options related to the splash (aplies in all song)--
local customSplashSkinOp = false --let's you have your custom splashes
local isLibitinaOp = false --sets the splash into libitina version 
local splashTextureOp = 'noteSplashes' --change texture of the splash

-- TOGGLES --
 -- PLAYER --
--sets the splash skin or options in a certain/selected songs--
local enabledCustomSplash = {'songName1', 'songName2'} --enable custom splash?
local enabledOpponentSplash = {'songName1', 'songName2'} --enable opponent splash?
local enabledPsychSplash = {'songName1', 'songName2'} --enable psych splash?
local enabledLibbieSplash = {'songName1', 'songName2'} --enable libitina splash?

 -- OPPONENT --
--sets the splash skin or options in a certain/selected songs--
local enabledCustomSplashOp = {'songName1', 'songName2'} --enable custom splash?
local enabledOpponentSplashOp = {'songName1', 'songName2'} --enable opponent splash?
local enabledPsychSplashOp = {'songName1', 'songName2'} --enable psych splash?
local enabledLibbieSplashOp = {'songName1', 'songName2'} --enable libitina splash?

-- PSYCH STUFF --
--enables the old/psych splash (applies in all song)--
local enablePsychSplashes = false --sets to the default old splashes
local enablePsychSystem = false --if true makes the properties of the splash appear like the psych

 -- OPPONENT --
local enablePsychSplashesOp = false --sets to the default old splashes
local enablePsychSystemOp = false --if true makes the properties of the splash appear like the psych
--(aplies to splash animations only)

-- Splash Things --
 -- PLAYER --
--Mess with it if you want your own custom splash but customSplashSkin MUST be enabled--
local splashPath = ''
local splashAnims = {}
local splashOffset = {}
local splashScale = 1
local splashFPS = 24
local splashAntialiasing = true --for pixel version (default:false/non-pixel)

 -- OPPONENT --
--Mess with it if you want your own custom splash but customSplashSkin MUST be enabled--
local splashPathOp = ''
local splashAnimsOp = {}
local splashOffsetOp = {}
local splashScaleOp = 1
local splashFPSOp = 24
local splashAntialiasingOp = true --for pixel version (default:false/non-pixel)

-- CODE N STUFF (No touch unless you know what you doin) --
local splashesDestroyed = 0
local splashCount = 0
local sickTrack = -1

local splashesDestroyedOp = 0
local splashCountOp = 0

function onCreatePost()
 for i = 1, #enabledCustomSplash do
   if songName == enabledCustomSplash[i] then
     customSplashSkin = true
        end
    end

 for i = 1, #enabledCustomSplashOp do
   if songName == enabledCustomSplashOp[i] then
     customSplashSkinOp = true
        end
    end

 for i = 1, #enabledPsychSplash do
   if songName == enabledPsychSplash[i] then
     enablePsychSplashes = true
        end
    end

 for i = 1, #enabledPsychSplashOp do
   if songName == enabledPsychSplashOp[i] then
     enablePsychSplashesOp = true
        end
    end

 for i = 1, #enabledLibbieSplash do
   if songName == enabledLibbieSplash[i] then
     isLibitina = true
        end
    end

 for i = 1, #enabledLibbieSplashOp do
   if songName == enabledLibbieSplashOp[i] then
     isLibitinaOp = true
        end
    end

 for i = 1, #enabledOpponentSplash do
   if songName == enabledOpponentSplash[i] then
     OpponentHasSplash = true
        end
    end
end

function goodNoteHit(noteIndex, noteDirection, noteType, isSustainNote)
   ratingTrack = getPropertyFromGroup('notes', noteIndex, 'rating')
      if ratingTrack == 'sick' and not isSustainNote and not enablePsychSplashes then
	spawnPlayerSplash(noteIndex, noteDirection, noteType);
    end
end

function opponentNoteHit(noteIndex, noteDirection, noteType, isSustainNote)
      if OpponentHasSplash and not isSustainNote then
	spawnOpponentSplash(noteIndex, noteDirection, noteType);
    end
end

function spawnPlayerSplash(noteId, noteDirection, noteType)
	splashThing = splashAnims[noteDirection + 1]
	splashCount = splashCount + 1
   
        precacheImage(splashPath..splashTexture)
	makeAnimatedLuaSprite('noteSplashPlayer'..splashCount, splashPath..splashTexture, getPropertyFromGroup('playerStrums', noteDirection, 'x') - splashOffset[1], getPropertyFromGroup('playerStrums', noteDirection, 'y') - splashOffset[2]);
	addAnimationByPrefix('noteSplashPlayer'..splashCount, 'anim', splashThing, splashFPS, false);
        if (enablePsychSystem == true) then
	  addAnimationByPrefix('noteSplashPlayer'..splashCount, 'anim', splashThing .. getRandomInt(1, 2), 24, false);
        end
        scaleObject('noteSplashPlayer' .. splashCount, splashScale, splashScale)
	setProperty('noteSplashPlayer' .. splashCount .. '.antialiasing', splashAntialiasing);

	setObjectCamera('noteSplashPlayer'..splashCount, 'hud');
	setObjectOrder('noteSplashPlayer'..splashCount, getObjectOrder('notes') + 1); -- this better make the splashes go in front-
	setProperty('noteSplashPlayer'..splashCount..'.visible', getPropertyFromGroup('playerStrums', noteDirection, 'visible'));
	setProperty('noteSplashPlayer'..splashCount..'.alpha', getPropertyFromGroup('playerStrums', noteDirection, 'alpha'));
	addLuaSprite('noteSplashPlayer'..splashCount);
end

function spawnOpponentSplash(noteId, noteDirection, type)
	splashThingOp = splashAnimsOp[noteDirection + 1]
	splashCountOp = splashCountOp + 1

        precacheImage(splashPathOp..splashTextureOp)
	makeAnimatedLuaSprite('noteSplashOpponent'..splashCountOp, splashPathOp..splashTextureOp, getPropertyFromGroup('opponentStrums', noteDirection, 'x') - splashOffsetOp[1], getPropertyFromGroup('opponentStrums', noteDirection, 'y') - splashOffsetOp[2]);
        if (enablePsychSplashes == true or enablePsychSystem == true) then
	  addAnimationByPrefix('noteSplashOpponent'..splashCountOp, 'anim', splashThingOp .. getRandomInt(1, 2), splashFPSOp, false);
        end
	addAnimationByPrefix('noteSplashOpponent'..splashCountOp, 'anim', splashThingOp, splashFPSOp, false);
        scaleObject('noteSplashOpponent' .. splashCountOp, splashScale, splashScaleOp)
	setProperty('noteSplashOpponent' .. splashCountOp .. '.antialiasing', splashAntialiasingOp);
	setProperty('noteSplashOpponent'..splashCountOp..'.visible', getPropertyFromGroup('opponentStrums', noteDirection, 'visible'));
	setProperty('noteSplashOpponent'..splashCountOp..'.alpha', getPropertyFromGroup('opponentStrums', noteDirection, 'alpha'));

	setObjectCamera('noteSplashOpponent'..splashCountOp, 'hud');
	setObjectOrder('noteSplashOpponent'..splashCountOp, getObjectOrder('notes') + 1); -- this better make the splashes go in front-
	addLuaSprite('noteSplashOpponent'..splashCountOp);
end

function onUpdate()
  isPixel = getPropertyFromClass('PlayState', 'isPixelStage')
  curNoteskin = getPropertyFromClass('PlayState', 'SONG.arrowSkin')
   if isPixel and not customSplashSkin and not isLibitina then
     splashTexture = 'pixel_Splash'
     splashAnims = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'}
     splashOffset = {80, 80}
     splashScale = 6
     splashAntialiasing = false

   if OpponentHasSplash and not isLibitinaOp then
     splashTextureOp = 'pixel_Splash'
     splashAnimsOp = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'}
     splashOffsetOp = {80, 80}
     splashScaleOp = 6
     splashAntialiasingOp = false
   end

    elseif not isPixel and not customSplashSkin and not isLibitina then
     splashTexture = 'NOTE_splashes_doki'
     splashAnims = {'note splash purple 2', 'note splash blue 2', 'note splash green 2', 'note splash red 2'}
     splashOffset = {140, 140}
     splashScale = 1
     splashAntialiasing = true

    if not isPixel and OpponentHasSplash and not isLibitinaOp then
     splashTextureOp = 'NOTE_splashes_doki'
     splashAnimsOp = {'note splash purple 2', 'note splash blue 2', 'note splash green 2', 'note splash red 2'}
     splashOffsetOp = {140, 140}
     splashScaleOp = 1
     splashAntialiasingOp = true
       end
   end

    if isLibitina then
      splashTexture = 'libbie_Splash'
      splashAnims = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'}
      splashOffset = {75, 80}
      splashScale = 1
      splashAntialiasing = true

    if OpponentHasSplash and isLibitinaOp then
      splashTextureOp = 'libbie_Splash'
      splashAnimsOp = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'}
      splashOffsetOp = {75, 80}
      splashScaleOp = 1
      splashAntialiasingOp = true
        end
    end

   if enablePsychSplashes then
      for i = 0, getProperty('unspawnNotes.length')-1 do
         setPropertyFromGroup('unspawnNotes', i, 'noteSplashTexture', splashTexture)
         splashAnims = {'note splash purple ', 'note splash blue ', 'note splash green ', 'note splash red '}
         splashOffset = {100, 120}
         splashScale = 1
         splashAlpha = 0.8
         splashAntialiasing = true

       if OpponentHasSplash and enablePsychSplashes then
         splashAnimsOp = {'note splash purple ', 'note splash blue ', 'note splash green ', 'note splash red '}
         splashOffsetOp = {100, 120}
         splashScaleOp = 1
         splashAlphaOp = 0.8
         splashAntialiasingOp = true
       end

     if isPixel and enablePsychSplashes then
         setPropertyFromGroup('unspawnNotes', i, 'noteSplashTexture', splashPath..splashTexture)
         splashPath = 'pixelUI/'
         splashTexture = 'noteSplashes-pixel'

       if OpponentHasSplash and enablePsychSplashes then
         splashPathOp = 'pixelUI/'
         splashTextureOp = 'noteSplashes-pixel'
               end
           end
       end
   end

   if OpponentHasSplash and customSplashSkin and enabledPsychSystem then
          splashPathOp = splashPathOp
          splashTextureOp = splashTextureOp
          splashAnimsOp = {'note splash purple ', 'note splash blue ', 'note splash green ', 'note splash red '}
          splashOffsetOp = {splashOffsetOp[1], splashOffsetOp[2]}
          splashScaleOp = splashScaleOp
          splashAntialiasingOp = splashAntialiasingOp
      elseif customSplashSkin then
          splashPath = splashPath
          splashTexture = splashTexture
          splashAnims = {splashAnims[1], splashAnims[2], splashAnims[3], splashAnims[4]}
          splashOffset = {splashOffset[1], splashOffset[2]}
          splashScale = splashScale
          splashAntialiasing = splashAntialiasing
   end

   if customSplashSkinOp and enabledPsychSystemOp then
          splashPathOp = splashPathOp
          splashTextureOp = splashTextureOp
          splashAnimsOp = {'note splash purple ', 'note splash blue ', 'note splash green ', 'note splash red '}
          splashOffsetOp = {splashOffsetOp[1], splashOffsetOp[2]}
          splashScaleOp = splashScaleOp
          splashAntialiasingOp = splashAntialiasingOp
      elseif customSplashSkin then
          splashPathOp = splashPathOp
          splashTextureOp = splashTextureOp
          splashAnimsOp = {splashAnimsOp[1], splashAnimsOp[2], splashAnimsOp[3], splashAnimsOp[4]}
          splashOffsetOp = {splashOffsetOp[1], splashOffsetOp[2]}
          splashScaleOp = splashScaleOp
          splashAntialiasingOp = splashAntialiasingOp
   end

   if songName:lower() == 'libitina' or curNoteskin == 'NOTE_assetsLibitina' then
     isLibitina = true
     isLibitinaOp = true
   end

   if sickTrack ~= 0 then
     for splashes = splashesDestroyed, splashCount do
	if getProperty('noteSplashPlayer'..splashes..'.animation.curAnim.finished') then
		setProperty('noteSplashPlayer'..splashes..'.visible', false)
		removeLuaSprite('noteSplashPlayer'..splashes, true)
		splashesDestroyed = splashesDestroyed + 1
            end
	end

	for splashesDefault = 0, getProperty('grpNoteSplashes.length') do
              if enablePsychSplashes == true then
		setPropertyFromGroup('grpNoteSplashes', splashesDefault, 'visible', true)
                enablePsychSplashes = true
               else
		setPropertyFromGroup('grpNoteSplashes', splashesDefault, 'visible', false)
                enablePsychSplashes = false
                 end
	     end
         end

     for splashesOp = splashesDestroyedOp, splashCountOp do
	if getProperty('noteSplashOpponent'..splashesOp..'.animation.curAnim.finished') then
		setProperty('noteSplashOpponent'..splashesOp..'.visible', false)
		removeLuaSprite('noteSplashOpponent'..splashesOp, true)
		splashesDestroyedOp = splashesDestroyedOp + 1
        end
    end
end