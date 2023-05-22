-- THANK YOU Jaldabo#2709 AND Dsfan2#6218 FOR HELPING ME WITH THIS
-- Some edits by superpowers04#3887

-- Config --
local iconPath = 'icons/' -- Path of the icons in the 'mods/images/'
local iconPrefix = 'icon-' -- Prefix before the credit icon name
local ShowCredits = true -- Do you want to show the credits before a song? [true/false]

-- Default Config --
local defaultShow = true -- Should the songName show even if there's none specified? [true/false]
local defaultTimer = 4 -- Default timer before the credits fade out and with "defaultShow" is enabled
local defaultArtist = 'Kawaii Sprite' -- Default artist name if there's no credits data
local defaultIcon = 'pen' -- Default icon if there's no credits data
local defaultIconPixel = 'pen-pixel' -- Default pixel icon if there's no credits data and with "isPixelStage" enabled

-- Song Config --

local songCredits = {
    --[[
        ['SONG NAME'] = {
            song = "Display Song Name", -- changes the song name into something here
            composer = "COMPOSER/ARTIST",
            icon = 'iconName', -- located on iconPath + 'icon-'
            
         -- OPTIONAL CHOICES --
            showOnTimer = [true/false], -- shows the credits base on it's given timer
            showOnStep = [true/false], -- shows the credits base on it's given step
            showOnBeat = [true/false], -- shows the credits base on it's given beat
            timer = timer, -- timer before the credits fade out for "showOnTimer" or "defaultShow" enabled
            step = {start, end}, -- optional only used when "showOnStep" is enabled
            beat = {start, end}, -- optional only used when "showOnBeat" is enabled
            dontShow = [true/false] -- optional toggles the credits default is false
        }
    --]]
    
    -- Tutorial
    ['Tutorial'] = {
        composer = 'Kawaii Sprite', 
        icon = 'mic',
    },
    
    -- Week 1 [Shows on the beat/curBeat]
    ['Bopeebo'] = {showOnBeat = true, beat = {5, 10}},
    -- Week 2 [Shows on the step/curStep]
    ['Spookeez'] = {showOnStep = true, step = {10, 20}},
    -- Week 3 [Shows on the timer]
    ['Philly Nice'] = {showOnTimer = true, timer = 9},
    -- Week 4 [Shows different icon]
    ['Satin Panties'] = {icon = 'file'},
    -- Week 5 [Shows different icon and composer]
    ['Winter Horrorland'] = {composer = 'bassetfilms', icon = 'file'},
    -- Week 6 [Shows a different songName]
    ['Thorns'] = {song = 'Thorns/Phase 3'},
}

function onCreatePost()
    songInfo = songCredits[songName] or {dontShow = not defaultShow};
    if not ShowCredits or songInfo.dontShow then 
        close(); -- forgor if this works tbh
        onSongStart = nil;
        onTimerCompleted = nil;
        return
    end
    -- Pixel thing
    isPixel = getPropertyFromClass('PlayState', 'isPixelStage')
    
    if songInfo.song == nil then
       makeLuaText('song', songName, 0, 0, -100)
    else
       makeLuaText('song', songInfo.song, 0, 0, -100)
    end
    setTextFont('song', 'riffic.ttf')
    setTextAlignment('song', 'right')
    setTextBorder('song', 1, '000000');
    setObjectCamera('song', 'other')
    setTextSize('song', 36)
    setProperty('song.alpha', 0)
    addLuaText('song')

    if songInfo.composer == nil then 
       makeLuaText('artist', defaultArtist, screenWidth, 0, 38)
    else
       if songName == 'Epiphany' and difficulty == 1 then
          makeLuaText('artist', songInfo.composer_encore, screenWidth, 0, 38)
        else
          makeLuaText('artist', songInfo.composer, screenWidth, 0, 38)
       end
    end
    setTextFont('artist', 'Aller_Rg.ttf')
    setTextAlignment('artist', 'right')
    setTextBorder('artist', 1, '000000');
    setTextSize('artist', 20)
    setObjectCamera('artist', 'other')
    setProperty('artist.alpha', 0)
    addLuaText('artist')

    precacheImage(iconAsset)
    if songInfo.icon == nil then
      if isPixel then    
        iconAsset = iconPath..iconPrefix..defaultIconPixel
       elseif not isPixel or defaultIconPixel == nil or defaultIconPixel == '' then
        iconAsset = iconPath..iconPrefix..defaultIcon
      end 
     else
        iconAsset = iconPath..iconPrefix..songInfo.icon
    end
    makeLuaSprite('icon', iconAsset)
    setObjectCamera('icon', 'camHUD')
    scaleObject('icon', 0.35, 0.35)
    --setProperty('icon.y', 15 - (getProperty('icon.height') / 2) + 16)
    setObjectCamera('icon', 'other')
    setProperty('icon.alpha', 0)
    addLuaSprite('icon')
end

function onUpdate(elapsed)
    -- THANK YOU Dsfan2 FOR HELPING
    setProperty('artist.x', screenWidth - (getProperty('artist.width') + 20))
    setProperty('song.x', screenWidth - (getProperty('song.width') + 16))
    setProperty('icon.x', getProperty('song.x') - 48)
    --setProperty('icon.y', getProperty('song.y') - 10)
    setProperty('icon.alpha', getProperty('song.alpha'))
    if isPixel then
      setTextFont('artist', 'vcr.ttf')
      setTextFont('song', 'vcr.ttf')
    end
end

function onBeatHit()
  if not songInfo.showOnStep then
    if songInfo.showOnBeat then
        if curBeat == songInfo.beat[1] then
            TweenIn()
        elseif curBeat == songInfo.beat[2] then 
            TweenOut()
            end
        end
    end
end 

function onStepHit()
  if not songInfo.showOnBeat then
    if songInfo.showOnStep then
        if curStep == songInfo.step[1] then
            TweenIn()
        elseif curStep == songInfo.step[2] then
            TweenOut()
            end
        end
    end
end

function onCountdownTick(counter)
  if counter == 0 then
    if defaultShow and not songInfo.showOnStep and not songInfo.showOnBeat then
         TweenIn()
            if songInfo.timer == nil then
               runTimer('creditsOut', defaultTimer)
            else
               runTimer('creditsOut', songInfo.timer)
            end
        end
    end
end

function onSongStart()
  if getProperty('skipCountdown') == true then
    if defaultShow and not songInfo.showOnStep and not songInfo.showOnBeat then
         TweenIn()
            if songInfo.timer == nil then
               runTimer('creditsOut', defaultTimer)
            else
               runTimer('creditsOut', songInfo.timer)
            end
        end
    end
end

function onTimerCompleted(tag)
  if defaultShow or songInfo.timer then
    if tag == 'creditsOut' then
      TweenOut()
        end
    end
end

function TweenIn()
   doTweenAlpha('songAIn', 'song', 1, 0.7, 'quartInOut')
   doTweenY('songYIn', 'song', 20, 0.7, 'quartInOut')

  if luaSpriteExists('icon') then
   doTweenAlpha('iconAIn', 'icon', 1, 0.7, 'quartInOut')
   doTweenY('iconYIn', 'icon', 20 - (getProperty('icon.height') / 2) + 16, 0.7, 'quartInOut')
  end

  if luaTextExists('artist') then
   doTweenAlpha('artistAIn', 'artist', 1, 0.8, 'quartInOut')
   doTweenY('artistYIn', 'artist', 58, 0.8, 'quartInOut')
    end
end

function TweenOut()
   doTweenAlpha('songAOut', 'song', 0, 0.7, 'quartInOut')
   doTweenY('songYOut', 'song', 0, 0.7, 'quartInOut')

  if luaSpriteExists('icon') then
   doTweenAlpha('iconAOut', 'icon', 0, 0.7, 'quartInOut')
   doTweenY('iconYOut', 'icon', 0 - getProperty('icon.height') / 2 + 16, 0.7, 'quartInOut')
  end

  if luaTextExists('artist') then
   doTweenAlpha('artistAOut', 'artist', 0, 0.7, 'quartInOut')
   doTweenY('artistYOut', 'artist', 38, 0.7, 'quartInOut')
    end
end

function onTweenCompleted(tag)
   if tag == 'songAOut' then
    removeLuaText('song')
   elseif tag == 'iconAOut' then
    removeLuaSprite('icon')
   elseif tag == 'artistAOut' then
    removeLuaText('artist')
    end
end