EndingScene = {}
EndingScene.__index = EndingScene

local cutSceneImgsNum = 3
local sideBarPos = 150

local invertShader = [[
    extern number xStart;

    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(texture, texture_coords);

        if (screen_coords.x > xStart){
            texcolor.rgb = 1.0 - texcolor.rgb;
        }

        return texcolor * color;
    }
]]

function EndingScene.new()
    local endingScene = {}
    setmetatable(endingScene, EndingScene)

    endingScene.invertOn = false
    endingScene.shader = love.graphics.newShader(invertShader)
    endingScene.shader:send("xStart", sideBarPos)

    return endingScene
end

function EndingScene:load()
    self.screenShot = love.graphics.newImage(love.graphics.newScreenshot())
    Timer.new(0.5, function ()
        self.invertOn = false
        Timer.new(0.2, function ()
            self.invertOn = true
            Timer.new(0.1, function ()
                self.invertOn = false
                Timer.new(0.1, function ()
                    self.invertOn = true
                    Timer.new(0.3, function ()
                        self.invertOn = false
                    end)
                end)
            end)
        end)
    end)
end

function EndingScene:draw(dt)
    if self.invertOn then
        love.graphics.setShader(self.shader)
    end
    love.graphics.draw(self.screenShot, 0, 0)
end
