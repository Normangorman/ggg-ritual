SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
    s = {}
    setmetatable(s, SoundManager)

    s.current_sound = nil

    s.sound_loops = {}
    s.sound_loops.mine = {
        love.audio.newSource("Assets/_Sounds/ambienceloops/cavedripping01.wav", "static"),
        love.audio.newSource("Assets/_Sounds/ambienceloops/indoorrumble01.wav", "static"),
        love.audio.newSource("Assets/_Sounds/ambienceloops/mineshaft01.wav", "static"),
        love.audio.newSource("Assets/_Sounds/ambienceloops/mineshaft01.wav", "static")
    }

    s.sound_loops.village = {
        love.audio.newSource("Assets/_Sounds/ambienceloops/rivercrickets01.wav", "static"),
        love.audio.newSource("Assets/_Sounds/ambienceloops/windtrees01.wav", "static"),
        love.audio.newSource("Assets/_Sounds/ambienceloops/rivercrickets02.wav", "static"),
        love.audio.newSource("Assets/_Sounds/ambienceloops/field01.wav", "static")
    }

    s.sound_loops.lake = {
        love.audio.newSource("Assets/_Sounds/ambienceloops/nearwater01.wav", "static"),
        love.audio.newSource("Assets/_Sounds/ambienceloops/lake01.wav", "static"),
        love.audio.newSource("Assets/_Sounds/ambienceloops/river01.wav", "static")
    }

    s.sound_loops.forest = {
        love.audio.newSource("Assets/_Sounds/ambienceloops/deepforest01.wav", "static"),
        love.audio.newSource("Assets/_Sounds/ambienceloops/forest01.wav", "static")
    }

    s.sound_bites = {}
    s.sound_bites.task_complete = love.audio.newSource("Assets/_Sounds/scroll foley/nextpage.wav", "static")

    s.last_player_zone = world.player_current_zone
    s.current_loop = nil
    s:update_sound()

    return s
end

function SoundManager:update(dt)
    local zone = world.player_current_zone
    if zone ~= self.last_player_zone then
        -- transition to a new sound
        self.last_player_zone = zone
        self:update_sound()
    end
end

function SoundManager:update_sound()
    local zone = world.player_current_zone

    love.audio.stop()

    if zone == "Mine" then
        -- CHANGE THIS RANDOM LOOP
        self.current_loop = self.sound_loops.mine[math.random(1, #self.sound_loops.mine)]
    elseif zone == "Forest" then
        self.current_loop = self.sound_loops.forest[math.random(1, #self.sound_loops.forest)]
    elseif zone == "Village" then
        self.current_loop = self.sound_loops.village[math.random(1, #self.sound_loops.village)]
    elseif zone == "Lake" then
        self.current_loop = self.sound_loops.lake[math.random(1, #self.sound_loops.lake)]
    end

    love.audio.play(self.current_loop)
end

function SoundManager:playTaskCompleteSound()
    love.audio.play(self.sound_bites.task_complete)
end
