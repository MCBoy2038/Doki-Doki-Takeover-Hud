
-- FUNCTION STUFF (Do not remove) --
dofile('mods/DDTO Hud/scripts/modules/callback.lua')

-- OPTIONS --
local randomSplash = false

-- Opponent -- 
local randomSplashOp = false

-- Pixel Shader Stuff --
local enablePixelShader = true
local precacheBefore = true -- precaches the splash texture before getting loaded

-- Code Variables -- 
local splashSkins = {'doki', 'lib', 'psych', 'vanilla'}

local splashType = ''
local splashState = ''
local splashPath = ''
local splashTexture = ''
local splashSuffix = ''
local splashAnims = {}
local offsetType = ''
local splashOffset = {}
local splashScale = 1
local splashAlpha = 'auto'
local splashAntialiasing = 'auto'
local splashFps = 24

-- Opponent --

local enablePixelShaderOp = true
local precacheBeforeOp = true -- precaches the splash texture before getting loaded

local splashSkinsOp = {'doki', 'lib', 'psych', 'vanilla'}

local splashTypeOp = ''
local splashStateOp = ''
local splashPathOp = ''
local splashTextureOp = ''
local splashSuffixOp = ''
local splashAnimsOp = {}
local offsetTypeOp = ''
local splashOffsetOp = {}
local splashScaleOp = 1
local splashAlphaOp = 'auto'
local splashAntialiasingOp = 'auto'
local splashFpsOp = 24

-- The Code (Important Things Here Do not touch except the options above of course) --
local noPixelSprite = false
local pixelIntensity = 1

local defaultScale = 1
local defaultAlpha = 'auto'
local defaultAntialiasing = 'auto'
local defaultFps = 24

local splashCount = 0
local splashDestroyed = 0

-- Opponent --

local noPixelSpriteOp = false
local pixelIntensityOp = 1

local defaultScaleOp = 1
local defaultAlphaOp = 'auto'
local defaultAntialiasingOp = 'auto'
local defaultFpsOp = 24

local splashCountOp = 0
local splashDestroyedOp = 0

-- DDTO+ Port Exclusive --
local splashMarkov = ''
local splashMarkovOp = ''

function onCreatePost()
   initLuaShader('pixelate')

    precache = getDataFromSave('ddtoOptions', 'precacheAssets')
    precacheOp = getDataFromSave('ddtoOptions', 'precacheAssets')
    enableOpponentSplash = getDataFromSave('ddtoOptions', 'enableOpponentSplash')
    enableSplash = getDataFromSave('ddtoOptions', 'enableSplash')

   isPixel = getClass('PlayState', 'isPixelStage')
   globalAntialiasing = getPropertyFromClass('ClientPrefs', 'globalAntialiasing')
   setOnLuas('splashState', splashState)
   setOnLuas('splashStateOp', splashStateOp)
   if isPixel then
     splashState = 'pixel'
     splashStateOp = 'pixel'
     pixelIntensity = 6
     pixelIntensityOp = 6
   end
   setProperty('grpNoteSplashes.visible', false)
end

function goodNoteHit(noteIndex, noteDirection, noteType, isSustainNote)
   daRating = getPropertyFromGroup('notes', noteIndex, 'rating')
    if daRating == 'sick' and not isSustainNote and enableSplash then
	spawnSplash(noteIndex, noteDirection, noteType, false)
    end
end

function opponentNoteHit(noteIndex, noteDirection, noteType, isSustainNote)
    if not isSustainNote and enableOpponentSplash then
	spawnSplash(noteIndex, noteDirection, noteType, true)
    end
end

function onBeatHit()
   if curBeat % 5 == 0 and randomSplash then
     splashType = splashSkins[getRandomInt(1, #splashSkins, splashType)]
   end
   if curBeat % 5 == 0 and randomSplashOp then
     splashTypeOp = splashSkinsOp[getRandomInt(1, #splashSkinsOp, splashTypeOp)]
   end
end

function onEvent(name, value1, value2)
   if name == 'Change Splash Skin' then
      if value2 == 'true' then
        splashTypeOp = value1
      else
        splashType = value1
      end
   end
end

function onUpdate(elapsed)
   for splashes = splashDestroyed, splashCount do
      if getProperty('noteSplash'..splashes..'.animation.curAnim.finished') then
        removeLuaSprite('noteSplash'..splashes, true)
	splashDestroyed = splashDestroyed + 1
      end
   end
   for splashesOp = splashDestroyedOp, splashCountOp do
      if getProperty('noteSplashOp'..splashesOp..'.animation.curAnim.finished') then
        removeLuaSprite('noteSplashOp'..splashesOp, true)
	splashDestroyedOp = splashDestroyedOp + 1
      end
   end
end

function spawnSplash(noteIndex, noteDirection, noteType, isOpponent)
   addSplashSkin(isOpponent)
     strumType = (isOpponent and 'opponent' or 'player')
     animString = (isOpponent and splashAnimsOp[noteDirection + 1] or splashAnims[noteDirection + 1])
     markovString = (isOpponent and splashMarkovOp or splashMarkov)
     if isOpponent then
       offsetString = (offsetTypeOp == 'group' and splashOffsetOp[noteDirection + 1] or splashOffsetOp)
     else
       offsetString = (offsetType == 'group' and splashOffset[noteDirection + 1] or splashOffset)
     end
     imgString = (isOpponent and splashPathOp .. splashTextureOp .. splashSuffixOp or splashPath .. splashTexture .. splashSuffix)
     posString = {getNoteProperty(strumType..'Strums', noteDirection, 'x'), getNoteProperty(strumType..'Strums', noteDirection, 'y')}
   
     if isOpponent then
       splashCountOp = splashCountOp + 1
     else
       splashCount = splashCount + 1
     end
     splashString = (isOpponent and 'noteSplashOp'..splashCountOp or 'noteSplash'..splashCount)

     if isOpponent then
       fpsString = (splashFpsOp == defaultFpsOp and defaultFpsOp or splashFpsOp)
     else
       fpsString = (splashFps == defaultFps and defaultFps or splashFps)
     end
     if isOpponent then
       scaleString = (splashScaleOp == defaultScaleOp or splashScaleOp == nil and defaultScaleOp or splashScaleOp)
     else
       scaleString = (splashScale == defaultScale or splashScale == nil and defaultScale or splashScale)
     end

     if precache and not precacheBefore then precacheImage(imgString) end
     makeAnimatedLuaSprite(splashString, imgString, posString[1] - offsetString[1], posString[2] - offsetString[2])
     addAnimationByPrefix(splashString, 'spurt', animString, fpsString, false)
     addAnimationByPrefix(splashString, 'markov', markovString, fpsString, false)
     scaleObject(splashString, scaleString, scaleString)
     if isOpponent then
       setProperty(splashString..'.antialiasing', (splashAntialiasingOp == 'auto' and globalAntialiasing or splashAntialiasingOp))
     else
       setProperty(splashString..'.antialiasing', (splashAntialiasing == 'auto' and globalAntialiasing or splashAntialiasing))
     end
     if isOpponent then
       setProperty(splashString..'.alpha', (splashAlphaOp == 'auto' and getNoteProperty('opponentStrums', noteDirection, 'alpha') or splashAlphaOp))
     else
       setProperty(splashString..'.alpha', (splashAlpha == 'auto' and getNoteProperty('playerStrums', noteDirection, 'alpha') or splashAlpha))
     end

     setObjectCamera(splashString, 'hud')
     setObjectOrder(splashString, getObjectOrder('notes') + 1)
     if isOpponent then
       setProperty(splashString..'.visible', showSplash or getNoteProperty('opponentStrums', noteDirection, 'visible'))
     else
       setProperty(splashString..'.visible', showSplash or getNoteProperty('playerStrums', noteDirection, 'visible'))
     end
     addLuaSprite(splashString)

     if isOpponent then
       markovString = splashMarkovOp == nil or splashMarkovOp == ''
     else
       markovString = splashMarkov == nil or splashMarkov == ''
     end

     if noteType == 'Markov' or noteType == 'Hurt Note' then
         playAnim(splashString, (markovString and 'spurt' or 'markov'), true)  
         setProperty(splashString..'.color', getColorFromHex((markovString and 'FF0000' or 'FFFFFF')))
     end

     if enablePixelShader and shadersEnabled and noPixelSprite then
        if isPixel or (isOpponent and splashStateOp or splashState) == 'pixel' then
          pixelizeSprite(splashString, (isOpponent and pixelIntensityOp or pixelIntensity), false)
        end
     end
   setOnLuas('splashSkin', splashType)
   setOnLuas('splashSkinOp', splashTypeOp)
end

function addSplashSkin(isOpponent)
  -- set up yo skins here
  splash = (isOpponent and splashTypeOp or splashType)
    if splash == '' or splash == 'doki' or splash == nil then
      if isPixel then
        setSplash((isOpponent and 'doki-pixelOp' or 'doki-pixel'))
        noPixelSprite = false
        noPixelSpriteOp = false
      else
        setSplash((isOpponent and 'dokiOp' or 'doki'))
      end

    elseif splash == 'doki-pixel' and splashState ~= 'pixel' then
        setSplash((isOpponent and 'doki-pixelOp' or 'doki-pixel'))

    elseif splash == 'lib' then
        setSplash((isOpponent and 'libOp' or 'lib'))
        if isPixel then
          noPixelSprite = true
          pixelIntensity = 3
          noPixelSpriteOp = true
          pixelIntensityOp = 3
        end

    elseif splash == 'psych' then
       setSplash((isOpponent and 'psychOp' or 'psych'))
       if isPixel then
          noPixelSprite = true
          pixelIntensity = 6
          noPixelSpriteOp = true
          pixelIntensityOp = 6
       end

    elseif splash == 'vanilla' then
        setSplash((isOpponent and 'vanillaOp' or 'vanilla'))
        if isPixel then
          noPixelSprite = true
          pixelIntensity = 6
          noPixelSpriteOp = true
          pixelIntensityOp = 6
        end
    end
end

function setSplash(skin)
   -- Put the splash offset
   if skin == 'doki' then
     resetDefault()
     if precache and precacheBefore then
       precacheImage('NOTE_splashes_doki')
     end
     splashMarkov = 'note splash markov 2'
     splashTexture = 'NOTE_splashes_doki'
     splashAnims = {'note splash purple 2', 'note splash blue 2', 'note splash green 2', 'note splash red 2'}
     splashOffset = {140, 140}
   end

   if skin == 'dokiOp' then
     resetDefault()
     if precacheOp and precacheBeforeOp then
       precacheImage('NOTE_splashes_doki')
     end
     splashMarkovOp = 'note splash markov 2'
     splashTextureOp = 'NOTE_splashes_doki'
     splashAnimsOp = {'note splash purple 2', 'note splash blue 2', 'note splash green 2', 'note splash red 2'}
     splashOffsetOp = {140, 140}
   end

   if skin == 'doki-pixel' then
     resetDefault()
     if precache and precacheBefore then
       precacheImage('pixel_Splash')
     end
     splashMarkov = 'note splash markov 1'
     splashTexture = 'pixel_Splash'
     splashAnims = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'}
     splashOffset = {80, 80}
     splashScale = 6
     splashAntialiasing = false
   end

   if skin == 'doki-pixelOp' then
     resetDefault()
     if precacheOp and precacheBeforeOp then
       precacheImage('pixel_Splash')
     end
     splashMarkovOp = 'note splash markov 1'
     splashTextureOp = 'pixel_Splash'
     splashAnimsOp = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'}
     splashOffsetOp = {80, 80}
     splashScaleOp = 6
     splashAntialiasingOp = false
   end

   if skin == 'lib' then
     resetDefault()
     if precache and precacheBefore then
       precacheImage('libbie_Splash')
     end
     splashMarkov = 'note splash blue 1'
     splashTexture = 'libbie_Splash'
     splashAnims = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'}
     splashOffset = {75, 80}
   end

   if skin == 'libOp' then
     resetDefault()
     if precacheOp and precacheBeforeOp then
       precacheImage('libbie_Splash')
     end
     splashMarkovOp = 'note splash blue 1'
     splashTextureOp = 'libbie_Splash'
     splashAnimsOp = {'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1'}
     splashOffsetOp = {75, 80}
   end

   if skin == 'psych' then
     resetDefault()
     if precache and precacheBefore then
       precacheImage('noteSplashes')
     end
     splashTexture = 'noteSplashes'
     randomChance = getRandomInt(1, 2) -- psych randomizer shit
     daAnims = {'note splash purple '..randomChance, 'note splash blue '..randomChance, 'note splash green '..randomChance, 'note splash red '..randomChance}
     splashAnims = daAnims
     splashOffset = {110, 120}
   end

   if skin == 'psychOp' then
     resetDefault()
     if precacheOp and precacheBeforeOp then
       precacheImage('noteSplashes')
     end
     splashTextureOp = 'noteSplashes'
     randomChanceOp = getRandomInt(1, 2) -- psych randomizer shit
     daAnimsOp = {'note splash purple '..randomChanceOp, 'note splash blue '..randomChanceOp, 'note splash green '..randomChanceOp, 'note splash red '..randomChanceOp}
     splashAnimsOp = daAnimsOp
     splashOffsetOp = {110, 120}
   end

   if skin == 'vanilla' then
     resetDefault()
     if precache and precacheBefore then
       precacheImage('vanillaSplashes')
     end
     splashTexture = 'vanillaSplashes'
     randomChance = getRandomInt(1, 2) -- psych randomizer shit
     daAnims = {'note splash purple '..randomChance, 'note splash blue '..randomChance, 'note splash green '..randomChance, 'note splash red '..randomChance}
     splashAnims = daAnims
     offsetType = 'group'
     splashOffset = {{100, 110}, {90, 110}, {90, 110}, {85, 110}}
   end

   if skin == 'vanillaOp' then
     resetDefault()
     if precacheOp and precacheBeforeOp then
       precacheImage('vanillaSplashes')
     end
     splashTextureOp = 'vanillaSplashes'
     randomChanceOp = getRandomInt(1, 2) -- psych randomizer shit
     daAnimsOp = {'note splash purple '..randomChanceOp, 'note splash blue '..randomChanceOp, 'note splash green '..randomChanceOp, 'note splash red '..randomChanceOp}
     splashAnimsOp = daAnimsOp
     offsetTypeOp = 'group'
     splashOffsetOp = {{100, 110}, {90, 110}, {90, 110}, {85, 110}}
   end
end

function pixelizeSprite(tag, size, removeShader) 
   if removeShader == nil then removeShader = false end
   setSpriteShader(tag, 'pixelate')
   setShaderFloat(tag, 'mult', 0)
   setShaderFloatArray(tag, 'r', {0, 0, 0})
   setShaderFloatArray(tag, 'g', {0, 0, 0})
   setShaderFloatArray(tag, 'b', {0, 0, 0})
   setShaderFloatArray(tag, 'uBlocksize', {size, size})
   if removeShader then
     removeSpriteShader(tag)
   end
end

function resetDefault()
    splashPath = ''
    splashSuffix = ''
    splashMarkov = ''
    splashScale = defaultScale
    splashAntialiasing = defaultAntialiasing
    splashAlpha = defaultAlpha
    splashFps = defaultFps
end

function getNoteProperty(daNote, daDir, daVar)
   return getPropertyFromGroup(daNote, daDir, daVar)
end