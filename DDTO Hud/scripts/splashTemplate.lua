local settings = {

     -- Script enabled?
     isEnabled = true,

     -- Cache splashes?
     cacheSplashes = true,

     -- Enable splashes for either character? First one is for player, second is opponent.
     enableSplashForCharacter = {
          true, true
     },

     -- Splash textures. First one is for player, second is opponent.
     splashTextures = {
          'NOTE_splashes_doki',
          'noteSplashes'
     },

     -- Splash anims in each XML. First set is for player, second is opponent.
     curSplashAnims = {
          {'note splash purple 2 instance 1', 'note splash blue 2 instance 1', 'note splash green 2 instance 1', 'note splash red 2 instance 1'},
          {'note splash purple 2 instance 1', 'note splash blue 2 instance 1', 'note splash green 2 instance 1', 'note splash red 2 instance 1'},
     },

     -- Scale of the splashes. First set is for player, second is opponent. Default scales are (0.75).
     splashScaling = {
          {0.75, 0.75},
          {0.75, 0.75}
     },

     -- Alphas for the splashes. First one is for player, second is opponent.
     splashAlphas = {
          1, 0.6
     },

     --[[
          Positions for each splash. Keep these nil, since they're handled under onCreatePost(). You'll want to edit this from there.
          First set is for the player, second is for the opponent.
     ]]
     splashPOS = {
          {{nil, nil}, {nil, nil}, {nil, nil}, {nil, nil}},
          {{nil, nil}, {nil, nil}, {nil, nil}, {nil, nil}}
     },

     -- Blacklist of your noteTypes go here. Each not listed is prevented from splashing.
     blackList = {
          'example note',
          'example two note'
     }

}

function onCreatePost()

     if settings.isEnabled then

          luaDebugMode = true

          for k, v in pairs(settings.blackList) do settings.blackList[k] = ('"'..v:gsub('"', '\\"')..'"') end

          if settings.cacheSplashes then for guh = 1, #settings.splashTextures do precacheImage(settings.splashTextures[guh]); end end
     
          -- Y values for upscroll and downscroll here. "u" means upscroll, "d" means downscroll, pretty self-explanatory.
          y = {u = -30, d = 500}
     
          if (not middlescroll) and (not downscroll) then -- upscroll
               settings.splashPOS = {
                    {{660, y.u}, {770, y.u}, {883, y.u}, {993, y.u}},
                    {{18, y.u}, {130, y.u}, {243, y.u}, {353, y.u}}
               }
          elseif (not middlescroll) and (downscroll) then -- downscroll
               settings.splashPOS = {
                    {{550, y.d}, {660, y.d}, {773, y.d}, {883, y.d}},
                    {{18, y.d}, {130, y.d}, {243, y.d}, {353, y.d}}
               }
          elseif (middlescroll) and (not downscroll) then -- upscroll + middlescroll
               settings.splashPOS = {
                    {{340, y.u}, {450, y.u}, {563, y.u}, {673, y.u}},
                    {{8, y.u}, {118, y.u}, {893, y.u}, {1013, y.u}}
               }
          elseif (middlescroll) and (downscroll) then -- downscroll + middlescroll
               settings.splashPOS = {
                    {{340, y.d}, {450, y.d}, {563, y.d}, {673, y.d}},
                    {{8, y.d}, {118, y.d}, {893, y.d}, {1013, y.d}}
               }
          end

          -- I could theoretically put these under splashIndex, but if I want these to be editable and not as confusing, I should keep them here...
     
          makeAnimatedLuaSprite('splash_0', settings.splashTextures[1], settings.splashPOS[1][1][1], settings.splashPOS[1][1][2]);
          makeAnimatedLuaSprite('splash_1', settings.splashTextures[1], settings.splashPOS[1][2][1], settings.splashPOS[1][2][2]);
          makeAnimatedLuaSprite('splash_2', settings.splashTextures[1], settings.splashPOS[1][3][1], settings.splashPOS[1][3][2]);
          makeAnimatedLuaSprite('splash_3', settings.splashTextures[1], settings.splashPOS[1][4][1], settings.splashPOS[1][4][2]);

          makeAnimatedLuaSprite('Osplash_0', settings.splashTextures[1], settings.splashPOS[2][1][1], settings.splashPOS[2][1][2]);
          makeAnimatedLuaSprite('Osplash_1', settings.splashTextures[1], settings.splashPOS[2][2][1], settings.splashPOS[2][2][2]);
          makeAnimatedLuaSprite('Osplash_2', settings.splashTextures[1], settings.splashPOS[2][3][1], settings.splashPOS[2][3][2]);
          makeAnimatedLuaSprite('Osplash_3', settings.splashTextures[1], settings.splashPOS[2][4][1], settings.splashPOS[2][4][2]);

          -- Edit all the splash stuff here!

          for splashIndex = 0, 3 do

               addAnimationByPrefix('splash_'..splashIndex, 'spurt', settings.curSplashAnims[1][(splashIndex + 1)], 24, false);
               addAnimationByPrefix('Osplash_'..splashIndex, 'spurt', settings.curSplashAnims[2][(splashIndex + 1)], 24, false);

               -- Camera.
               setObjectCamera('splash_'..splashIndex, 'camHUD');
               setObjectCamera('Osplash_'..splashIndex, 'camHUD');

               -- Over the strums, but not the notes themselves under onUpdatePost() or smth.
               setObjectOrder('splash_'..splashIndex, getObjectOrder('strumLineNotes') + 1);
               setObjectOrder('Osplash_'..splashIndex, getObjectOrder('strumLineNotes') + 1);

               -- Scaling.
               scaleObject('splash_'..splashIndex, settings.splashScaling[1][1], settings.splashScaling[1][2]);
               scaleObject('Osplash_'..splashIndex, settings.splashScaling[2][1], settings.splashScaling[2][2]);

               -- Alphas.
               setProperty('splash_'..splashIndex..'.alpha', settings.splashAlphas[1]);
               setProperty('Osplash_'..splashIndex..'.alpha', settings.splashAlphas[2]);

               -- Visibility (they'll be visible when sick note is hit.)
               setProperty('splash_'..splashIndex..'.visible', false);
               setProperty('Osplash_'..splashIndex..'.visible', false);

               -- uh..
               addLuaSprite('splash_'..splashIndex, false);
               addLuaSprite('Osplash_'..splashIndex, false);

          end

     end

end

-- gotta check da note
function goodNoteHit(i, d, n, s) check(i, d, n, s, true); end
function opponentNoteHit(i, d, n, s) check(i, d, n, s, false); end

function check(i, d, n, s, isPlayer)
     local isBlackList = runHaxeCode('return ['..table.concat(settings.blackList, ', ')..'].contains("'..n:lower()..'");')
     if (not isBlackList) and (settings.isEnabled) then
          if (isPlayer) and (settings.enableSplashForCharacter[1]) then playerSplash(i, d, n, s);
          elseif (not isPlayer) and (settings.enableSplashForCharacter[2]) then opponentSplash(i, d, n, s);
          end
     end
end

function playerSplash(i, d, n, s)
     sick = (getPropertyFromGroup('notes', i, 'rating') == 'sick')
     setProperty('grpNoteSplashes.visible', false);
     if (sick) and (not s) then setProperty('splash_'..d..'.visible', true); playAnim('splash_'..d, 'spurt', true); end
end

function opponentSplash(i, d, n, s)
     if (not s) then setProperty('Osplash_'..d..'.visible', true); playAnim('Osplash_'..d, 'spurt', true); end
end

function onUpdatePost(e)
     if (settings.isEnabled) then
          for i = 0, 3 do
               -- Couldn't put together as an elseif statement or they'd break (from what I've tested).
               if (settings.enableSplashForCharacter[1]) and getProperty('splash_'..i..'.animation.curAnim.name') == 'spurt' and getProperty('splash_'..i..'.animation.curAnim.finished') then
                    setProperty('splash_'..i..'.visible', false);
               end
               if (settings.enableSplashForCharacter[2]) and getProperty('Osplash_'..i..'.animation.curAnim.name') == 'spurt' and getProperty('Osplash_'..i..'.animation.curAnim.finished') then
                    setProperty('Osplash_'..i..'.visible', false);
               end
          end
     end
end