-- THANK YOU Jaldabo#2709 FOR HELPING ME WITH THIS
-- Some edits by superpowers04#3887

-- Config

local ShowCredits = true -- Do you want to show the credits before a song? [true/false]
local defaultShow = true -- Should the songName show even if there's none specified? [true/false]


-- Mess around with the code if you know what you're doing
local creditsRemoved = false;
local songInfo = {};

local songCredits = {
    --[[
        ['SONG NAME'] = {
            composer = "COMPOSER/ARTIST",
            icon = 'ICONPATH',
            dontShow = true or false -- Toggles the credits 
        }
    --]]
    ['Tutorial'] = {composer = 'Kawaii Sprite', icon = 'icons/pen', dontShow = false},
    -- Week 3
    ['Pico'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Philly Nice'] = {composer = 'Kawaii Sprite', icon = 'icons/pen', dontShow = false},
    ['Blammed'] = {composer = 'Kawaii Sprite', icon = 'icons/pen', dontShow = false},
    -- Week 7
    ['Ugh'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Guns'] = {composer = 'Kawaii Sprite', icon = 'icons/pen', dontShow = false},
    ['Stress'] = {composer = 'Kawaii Sprite', icon = 'icons/pen', dontShow = false}
}



function onCreate()
    songInfo = songCredits[songName] or {dontShow = not defaultShow};
    if not ShowCredits or songInfo.dontShow then 
        close(); -- forgor if this works tbh
        onSongStart = nil;
        onTimerCompleted = nil;
        return
    end

    makeLuaText('song', songName, screenWidth, -30, 15)
    setTextFont('song','riffic.ttf')
    setTextAlignment('song','right')
    setTextBorder('song', 1, '000000');
    setTextSize('song', 36)
    setObjectCamera('song', 'camOther')
    setProperty('song.alpha', 0)
    addLuaText('song');

    if(songInfo.composer) then
        makeLuaText('artist', songInfo.composer, screenWidth, -30, 55)
        setTextFont('artist','Aller_rg.ttf')
        setTextAlignment('artist','right')
        setTextBorder('artist', 1, '000000');
        setTextSize('artist', 19)
        setObjectCamera('artist', 'camOther')
        addLuaText('artist');
        setProperty('artist.alpha', 0)
    end

    if(songInfo.icon) then
        -- idk how to make this work, im sorry :(

        -- makeLuaSprite('icon', songInfo.icon, getProperty('song.width') - 230, 11)
        -- makeLuaSprite('icon', songInfo.icon, getProperty('song.x') + 875, 11)
        setObjectCamera('icon', 'camOther')
        scaleObject('icon', 0.3, 0.3)
        setProperty('icon.alpha', 0)
        addLuaSprite('icon')
    end
end

function onSongStart()
    runTimer('creditsWait', 5);
    doTweenAlpha('songFadeIn', 'song', 1, 1, linear)
    if(songInfo.composer) then doTweenAlpha('artistFadeIn', 'artist', 1, 1, linear) end
    if(songInfo.icon) then doTweenAlpha('iconFadeIn', 'icon', 1, 1, linear) end
end

function onTimerCompleted(tag)
    -- Not Accurate but whatever
    if tag == 'creditsWait' then
        doTweenAlpha('songFadeOut', 'song', 0, 0.5, linear)
        doTweenY('songFadeOutUp', 'song', -120, 1.5, linear)
        if(songInfo.composer) then
            doTweenAlpha('artistFadeOut', 'artist', 0, 0.5, linear)
            doTweenY('artistFadeOutUp', 'artist', -100, 1.5, linear)
        end
        if(songInfo.icon) then
            doTweenAlpha('iconFadeOut', 'icon', 0, 0.5, linear)
            doTweenY('iconFadeOutUp', 'icon', -120, 1.5, linear)
        end
        creditsRemoved = true
    end
end