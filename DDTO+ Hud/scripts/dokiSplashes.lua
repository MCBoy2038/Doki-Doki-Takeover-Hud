local enablePsychSplashes = false
local isLibitina = false
local OpponentHasSplash = true

local textureSplash = {
 'NOTE_splashes_doki',
 'pixel_Splash',
 'libbie_Splash'
}

local splashAnims = {
 'note splash purple ',
 'note splash blue ',
 'note splash green ',
 'note splash red '
}

local splashOffset = {140, 140}
local splashScale = {1, 1}
local splashFPS = 24
local splashAlpha = 1
local splashAntialiasing = true

local splashesDestroyed = 0
local splashCount = 0
local sickTrack = -1

local splashesDestroyedOp = 0
local splashCountOp = 0

local excludedNote = 'Markov'


function goodNoteHit(note, direction, type, sus)
  isPixel = getPropertyFromClass('PlayState', 'isPixelStage')
   sickTrack = getProperty('sicks');
      if sickTrack == getProperty('sicks') and not enablePsychSplashes then
	 if sus == false then
          if isPixel == true then
	      spawnPlayerSplash(note, direction, type, textureSplash[2], '1');
              splashOffset = {80, 80}
              splashScale = {6, 6}
              splashAntialiasing = false
           elseif isLibitina == true then
	      spawnPlayerSplash(note, direction, type, textureSplash[3], '1');
              splashOffset = {80, 80}
              splashScale = {1, 1}
              splashAntialiasing = true
          else
	      spawnPlayerSplash(note, direction, type, textureSplash[1], '2');
              splashOffset = {140, 140}
              splashScale = {1, 1}
              splashAntialiasing = true
            end
        end
    end
end

function opponentNoteHit(note, direction, type, sus)
  isPixel = getPropertyFromClass('PlayState', 'isPixelStage')
   sickTrack = getProperty('sicks');
      if sickTrack == getProperty('sicks') and not enablePsychSplashes and OpponentHasSplash then
	 if sus == false then
          if isPixel == true then
	      spawnOpponentSplash(note, direction, type, textureSplash[2], '1');
              splashOffset = {80, 80}
              splashScale = {6, 6}
              splashAntialiasing = false
           elseif isLibitina == true then
	      spawnOpponentSplash(note, direction, type, textureSplash[3], '1');
              splashOffset = {80, 80}
              splashScale = {1, 1}
              splashAntialiasing = true
          elseif enablePsychSplashes then
	      spawnOpponentSplash(note, direction, type, 'noteSplashes');
              splashOffset = {100, 120}
              splashScale = {1, 1}
              splashAntialiasing = true
          else
	      spawnOpponentSplash(note, direction, type, textureSplash[1], '2');
              splashOffset = {140, 140}
              splashScale = {1, 1}
              splashAntialiasing = true
            end
        end
    end
end

function spawnPlayerSplash(noteId, noteDirection, type, textureNote, num)
	splashThing = splashAnims[noteDirection + 1]
	splashCount = splashCount + 1

        precacheImage(textureNote)
	makeAnimatedLuaSprite('noteSplashPlayer'..splashCount, textureNote, getPropertyFromGroup('playerStrums', noteDirection, 'x') - splashOffset[1], getPropertyFromGroup('playerStrums', noteDirection, 'y') - splashOffset[2]);
	addAnimationByPrefix('noteSplashPlayer'..splashCount, 'anim', splashThing .. num, splashFPS, false);

        scaleObject('noteSplashPlayer' .. splashCount, splashScale[1], splashScale[2])
	setProperty('noteSplashPlayer' .. splashCount .. '.alpha', splashAlpha);
	setProperty('noteSplashPlayer' .. splashCount .. '.antialiasing', splashAntialiasing);

	setObjectCamera('noteSplashPlayer'..splashCount, 'hud');
	setObjectOrder('noteSplashPlayer'..splashCount, getObjectOrder('notes') + 1); -- this better make the splashes go in front-
	addLuaSprite('noteSplashPlayer'..splashCount);
end

function spawnOpponentSplash(noteId, noteDirection, type, textureNote, num)
	splashThingOp = splashAnims[noteDirection + 1]
	splashCountOp = splashCountOp + 1

        precacheImage(textureNote)
	makeAnimatedLuaSprite('noteSplashOpponent'..splashCountOp, textureNote, getPropertyFromGroup('opponentStrums', noteDirection, 'x') - splashOffset[1], getPropertyFromGroup('opponentStrums', noteDirection, 'y') - splashOffset[2]);

      if num == nil then
	addAnimationByPrefix('noteSplashOpponent'..splashCountOp, 'anim', splashThingOp .. getRandomInt(1, 2), splashFPS, false);
       else
	addAnimationByPrefix('noteSplashOpponent'..splashCountOp, 'anim', splashThingOp .. num, splashFPS, false);
      end

        scaleObject('noteSplashOpponent' .. splashCountOp, splashScale[1], splashScale[2])
	setProperty('noteSplashOpponent' .. splashCountOp .. '.alpha', splashAlpha);
	setProperty('noteSplashOpponent' .. splashCountOp .. '.antialiasing', splashAntialiasing);

	setObjectCamera('noteSplashOpponent'..splashCountOp, 'hud');
	setObjectOrder('noteSplashOpponent'..splashCountOp, getObjectOrder('notes') + 1); -- this better make the splashes go in front-
	addLuaSprite('noteSplashOpponent'..splashCountOp);
end

function setOffset(tag, offsetX, offsetY)
    setProperty(tag .. '.offset.x', offsetX);
    setProperty(tag .. '.offset.y', offsetY);
end

function onUpdate()
  if songName == 'Libitina' then
    isLibitina = true
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
               else
		setPropertyFromGroup('grpNoteSplashes', splashesDefault, 'visible', false)
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