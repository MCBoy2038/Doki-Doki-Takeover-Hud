-- OPTIONS --
local hitSound = false -- enables hitsounds [true/false]
local judgeHitSound = false -- sound depend on [sicks, goods, bads, etc.]
local hitSoundVolume = 0.3 -- hitsound volume (0 to 1)

-- DO NOT TOUCH --
local noteHit = false

function onCreate()
	precacheSound('hitsound/snap')
	precacheSound('hitsound/perfect')
	precacheSound('hitsound/great')
	precacheSound('hitsound/good')
	precacheSound('hitsound/tap')
end

function goodNoteHit(noteID, noteData, noteType, isSustainNote)
   rating = getPropertyFromGroup('notes', noteID, 'rating')
    if not isSustainNote and hitSound then
      if rating == 'sick' then
        play('sick')
      elseif rating == 'good' then
        play('good')
      elseif rating == 'bad' then
        play('bad')
      else
        play()
        end
    end
end

function play(rating)
  sfx = ''
   if (judgeHitSound) then
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
  elseif tag == 'good' then
    noteHit = false
  elseif tag == 'bad' then
    noteHit = false
    end
end