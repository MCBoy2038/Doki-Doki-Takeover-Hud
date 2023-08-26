--[[
 INSTRUCTIONS:
  1.Do not duplicate the script(or if you wanna change the extension to anything else Ex: .hx) the script will break and the hitsound playing will be multiplied
  2.feel free to report any bugs or feedbacks and credit the respective owners :)
--]]

-- DO NOT TOUCH --
local noteHit = false

function onCreatePost()
   precache = getDataFromSave('ddtoOptions', 'precacheAssets')
   hitSoundVolume = getDataFromSave('ddtoOptions', 'hitSoundVolume')
   judgeHitSound = getDataFromSave('ddtoOptions', 'judgeHitSound')
   hitSound = getDataFromSave('ddtoOptions', 'hitSound')

   if precache then 
     precacheSound('hitsound/snap')
     precacheSound('hitsound/perfect')
     precacheSound('hitsound/great')
     precacheSound('hitsound/good')
     precacheSound('hitsound/tap')
   end
end

function goodNoteHit(noteID, noteData, noteType, isSustainNote)
   daRating = getPropertyFromGroup('notes', noteID, 'rating')
   if not isSustainNote and hitSound then
     hitsoundPlay(daRating)
   end
end

function onGhostTap()
   if hitSound then
     hitsoundPlay(daRating)
   end
end

function hitsoundPlay(rating)
  sfx = ''
   if judgeHitSound then
     noteHit = true
       if rating == 'sick' then
         sfx = 'perfect'
       elseif rating == 'good' then
         sfx = 'great'
       elseif rating == 'bad' then
         sfx = 'good'
       else
         sfx = 'tap'
         noteHit = false
       end
   else
       sfx = 'snap'
   end
   playSound('hitsound/'..sfx, hitSoundVolume, sfx)
end

function onSoundFinished(tag)
  if tag == 'perfect' then
    noteHit = false
  elseif tag == 'great' then
    noteHit = false
  elseif tag == 'good' then
    noteHit = false
  elseif tag == 'bad' then
    noteHit = false
    end
end