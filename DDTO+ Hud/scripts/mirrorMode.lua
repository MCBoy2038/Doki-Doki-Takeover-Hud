local swappedStrums = false
local swappedAnims = false
local swappedIcons = false

function onCreate()
   addHaxeLibrary('FlxMath', 'flixel.math')
   mirrorMode = getData('ddtoOptions', 'mirrorMode')
end

function onCreatePost()
   if mirrorMode and not getProperty('skipCountdown') then
     if not swappedAnims then swapAnimations(true) end
     if not swappedStrums then swapStrumLine(true) end
   end
end

function onSongStart()
   if mirrorMode and getProperty('skipCountdown') then
     if not swappedAnims then swapAnimations(true) end
     if not swappedStrums then swapStrumLine(true) end
   end
end

function onUpdatePost()
   if mirrorMode then 
     swapIcons(true)
   end
end

function goodNoteHit(noteID, noteData, noteType, isSustainNote)
   if mirrorMode then
     hitNote(id, noteData, noteType, isSustainNote, true)
   end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
   if mirrorMode then
     hitNote(id, noteData, noteType, isSustainNote, false)
   end
end

function hitNote(id, noteData, noteType, isSustainNote, isDad)
     animToPlay = getProperty('singAnimations')[noteData + 1]
     char = (isDad and 'dad' or 'boyfriend')
     if noteType == 'GF Sing' then
       char = 'gf'
       playAnim(char, animToPlay, true)
     end

     if noteType == 'Hey!' then
       playAnim(char, 'hey', true)
       setProperty(char..'.specialAnim', true)
       setProperty(char..'.heyTimer', 0.6)
     end

     if noteType == '' then
       playAnim(char, animToPlay, true)
     end

     if gfSection then
       playAnim('gf', animToPlay, true)
       char = 'gf'
     elseif altAnim or noteType == 'Alt Animation' then
       playAnim(char, animToPlay..'-alt', true)
     end
     setProperty(char..'.holdTimer', 0)
end

function animExists(char, anim)
   return runHaxeCode("game.]]..char..[[.animOffsets.exists(']]..anim..[[');")
end

-- CALLBACKS --

function swapAnimations(swap)
   if swap then
      for i = 0, getProperty('unspawnNotes.length')-1 do
         setPropertyFromGroup('unspawnNotes', i, 'mustPress', not getPropertyFromGroup('unspawnNotes', i, 'mustPress'))
         setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)
         setPropertyFromGroup('unspawnNotes', i, 'noMissAnimation', true)
         swappedAnims = true
      end
   else
      for i = 0, getProperty('unspawnNotes.length')-1 do
         setPropertyFromGroup('unspawnNotes', i, 'mustPress', getPropertyFromGroup('unspawnNotes', i, 'mustPress'))
         setPropertyFromGroup('unspawnNotes', i, 'noAnimation', false)
         setPropertyFromGroup('unspawnNotes', i, 'noMissAnimation', false)
         swappedAnims = false
      end
   end
end

function swapStrumLine(swap)
   if swap then
      if not middlescroll then
         for i = 0, getProperty('strumLineNotes.members.length') do
            local name = i >= 4 and 'Opponent' or 'Player'
	    setProperty('strumLineNotes.members['..i..'].x', _G['default'..name..'StrumX'..i % 4])
            setProperty('strumLineNotes.members['..i..'].y', _G['default'..name..'StrumY'..i % 4])
         end
      end
      swappedStrums = true
   else
      if not middlescroll then
         for i = 0, getProperty('strumLineNotes.members.length') do
            local name = i >= 4 and 'Player' or 'Opponent'
	    setProperty('strumLineNotes.members['..i..'].x', _G['default'..name..'StrumX'..i % 4])
            setProperty('strumLineNotes.members['..i..'].y', _G['default'..name..'StrumY'..i % 4])
         end
      end
      swappedStrums = false
   end
end

function swapIcons(swap)
   if swap then
     setProperty('healthBar.value', 2 - getHealth())
     runHaxeCode([[
         var iconOffset = 26;
         game.iconP1.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * game.iconP1.scale.x - 150) / 2 - iconOffset;
         game.iconP2.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * game.iconP2.scale.x) / 2 - iconOffset * 2;
         var iconArray = [game.iconP1, game.iconP2];
	 for (icon in iconArray) {
	   var i = iconArray.indexOf(icon);
	   icon.animation.curAnim.curFrame = (i < 1 ? game.healthBar.percent < 20 : game.healthBar.percent > 80) ? 1 : 0;
	 }
     ]])
     swappedIcons = true
   else
     setProperty('healthBar.value', 2 - getHealth())
     runHaxeCode([[
         var iconOffset = 26;
         game.iconP1.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * game.iconP1.scale.x - 150) / 2 - iconOffset;
         game.iconP2.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * game.iconP2.scale.x) / 2 - iconOffset * 2;
         var iconArray = [game.iconP2, game.iconP1];
	 for (icon in iconArray) {
	   var i = iconArray.indexOf(icon);
	   icon.animation.curAnim.curFrame = (i < 1 ? game.healthBar.percent < 20 : game.healthBar.percent > 80) ? 1 : 0;
	 }
     ]])
     swappedIcons = false
   end
end

function checkAnimationExists(char, anim, suffix)
    if suffix == nil then
      return runHaxeCode("game.]]..char..[[.anim.exists(']]..anim..[[');")
     else
      return runHaxeCode("game.]]..char..[[.anim.exists(']]..anim..[[' + ']]..suffix..[[');")
    end
      --return runHaxeCode("game.]]..char..[[.animOffsets.exists(']]..anim..[[' + ']]..animSuffix..[[');")
end

function saveData(dataGrp, dataField, dataValue)
  setDataFromSave(dataGrp, dataField, dataValue)
end

function getData(dataGrp, dataField, dataValue)
  return getDataFromSave(dataGrp, dataField, dataValue)
end