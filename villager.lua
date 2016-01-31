Villager = {}
setmetatable(Villager, GameObject)
Villager.__index = Villager

function Villager.new()
    local v = GameObject.new()
    setmetatable(v, Villager)

    v.animation = Animation.newFromFile("Animations/_NPCS/Villagers/villager.lua")
    v.greetings = {
        "I hope the blacksmith recovers soon.",
        "Did you see anyone near my livestock last night? One of my sheep is missing.",
        "I’m glad we have Amu and the Elder looking after us.",
        "When will it be safe to go back to the forest?",
        "Nymphs attacked the blacksmith? He told me it was Forest Demons.",
        "I get the feeling that… nope, you’re not listening. Nevermind.",
        "Did you hear? The camp to the East has been killing my sheep!",
        "One day, I’m going to slay demons in the forest, just like Amu!",
        "My daughter is visiting someone in the Eastern camp. I hope she’s okay.",
        "I swear I saw a shadow of something near the sheep last night. It definitely wasn’t human.",
        "I heard a horrible scream coming from the East a few minutes ago. I hope no-one is hurt."
    }
    return v
end

function Villager:update(dt)
    self.animation:update(dt)

    local dx = self.x - player.x
    local dy = self.y - player.y
    dist_to_player = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

    if dist_to_player <= 100 then
        if not self.speaking then
            self.speaking = true

            local text = self.greetings[math.random(1, #self.greetings)]
            local duration = 3

            world:add_game_object(Speech.new(self, text, duration))
        end
    else
        self.speaking = false
    end
end

function Villager:draw()
    self.animation:draw(self.x, self.y)
end
