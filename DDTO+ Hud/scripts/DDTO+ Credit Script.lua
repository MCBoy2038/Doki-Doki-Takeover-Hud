-- THANK YOU Jaldabo#2709 AND Dsfan2#6218 FOR HELPING ME WITH THIS
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
    -- Tutorial
    ['Tutorial'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    -- Week 1
    ['Bopeebo'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Fresh'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Dadbattle'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    -- Week 2
    ['Spookeez'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['South'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Monster'] = {composer = 'bassetfilms', icon = 'icons/mic', dontShow = false},
    -- Week 3
    ['Pico'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Philly Nice'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Blammed'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    -- Week 4
    ['Satin Panties'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['High'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Milf'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    -- Week 5
    ['Cocoa'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Eggnog'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Winter Horrorland'] = {composer = 'bassetfilms', icon = 'icons/mic', dontShow = false},
    -- Week 6
    ['Senpai'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Roses'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Thorns'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    -- Week 7
    ['Ugh'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Guns'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false},
    ['Stress'] = {composer = 'Kawaii Sprite', icon = 'icons/mic', dontShow = false}
}



function onCreate()
    songInfo = songCredits[songName] or {dontShow = not defaultShow};
    if not ShowCredits or songInfo.dontShow then 
        close(); -- forgor if this works tbh
        onSongStart = nil;
        onTimerCompleted = nil;
        return
    end

    makeLuaText('song', songName, 0, 0, -100)
    setTextFont('song','riffic.ttf')
    setTextAlignment('song','right')
    setTextBorder('song', 1, '000000');
    setTextSize('song', 36)
    setObjectCamera('song', 'camOther')
    setProperty('song.alpha', 0)
    setProperty('song.x', screenWidth - (getProperty('song.width') + 20))
    addLuaText('song');

    if(songInfo.composer) then
        makeLuaText('artist', songInfo.composer, 0, 0, -80)
        setTextFont('artist','Aller_rg.ttf')
        setTextAlignment('artist','right')
        setTextBorder('artist', 1, '000000');
        setTextSize('artist', 19)
        setObjectCamera('artist', 'camOther')
        setProperty('artist.x', screenWidth - (getProperty('artist.width') + 20))
        addLuaText('artist');
        setProperty('artist.alpha', 0)
    end

    if(songInfo.icon) then
        makeLuaSprite('icon', songInfo.icon, 500, 500)
        setObjectCamera('icon', 'camOther')
        scaleObject('icon', 0.3, 0.3)
        setProperty('icon.alpha', 0)
        addLuaSprite('icon')
    end
end

function onCountdownTick(counter)
    if counter == 1 then
        runTimer('creditsWait', 5);
        doTweenY('songFadeInDown', 'song', 15, 0.8, linear)
        doTweenAlpha('songFadeIn', 'song', 1, 1.15, linear)
        if(songInfo.composer) then 
            doTweenAlpha('artistFadeIn', 'artist', 1, 1.15, linear) 
            doTweenY('artistFadeInDown', 'artist', 55, 0.8, linear)
        end
        if(songInfo.icon) then 
            doTweenAlpha('iconFadeIn', 'icon', 1, 1.15, linear) 
        end
    end
end

function onTimerCompleted(tag)
    -- Accurate :yippe:
    if tag == 'creditsWait' then
        doTweenAlpha('songFadeOut', 'song', 0, 0.15, linear)
        doTweenY('songFadeOutUp', 'song', -130, 1.15, linear)
        if(songInfo.composer) then
            doTweenAlpha('artistFadeOut', 'artist', 0, 0.15, linear)
            doTweenY('artistFadeOutUp', 'artist', -100, 1.15, linear)
        end
        if(songInfo.icon) then
            doTweenAlpha('iconFadeOut', 'icon', 0, 0.15, linear)
            doTweenY('iconFadeOutUp', 'icon', -130, 1.15, linear)
        end
        creditsRemoved = true
    end
end

function onUpdate(elapsed)
    -- THANK YOU Dsfan2#6218 FOR HELPING
    setProperty('icon.x', getProperty('song.x') - 42)
    setProperty('icon.y', getProperty('song.y'))
    setProperty('icon.alpha', getProperty('song.alpha'))
end