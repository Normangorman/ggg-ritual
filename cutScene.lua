CutScene = {}
CutScene.__index = CutScene

function CutScene.new(cutSceneImgPath)
    local cutScene = {}
    setmetatable(className, CutScene)

    cutScene.img = love.graphics.newImage(cutSceneImgPath)

    return cutScene
end

function CutScene:draw(dt)
    love.graphics.draw(self.img)
end
