GamePlay = {}
GamePlay.__index = GamePlay

GamePlay.tasksByDay = {{
        {"Enter the Forest", {
            {123, 28},
            {123, 29},
            {123, 30},
            {123, 31}
            }
        },
        {"Find the Wood Nymphs’ home", {
            {30, 38},
            {31, 38},
            {32, 38},
            {33, 38},
            {34, 38},
            {35, 38}
        }},
        {"Find a way to heal the blacksmith", {
          -- kill the nymf or touch --
           {30, 23},
           {31, 23},
           {32, 23},
           {33, 23},
           {34, 23}
        }},
        {"Return to your Elder", {
          {149, 18},
          {150, 18}
        }}
    },
    {
        {"Find the bandits at the lakeside", 0, 0},
        -- collide bandit --
        {"Clear the lakeside of bandits", 0, 0},
        -- or --
        {"Defeat the Lake King", 0, 0},
        {"Return to the bandit leader", 0, 0},
        {"Bring the ring to your Elder", 0, 0}
    },
    {
        {"Enter the Mines", 0, 0},

        {"Bring the ring to your Elder", {
            {149, 18},
            {150, 18}
        }}
    },{
        {"Enter the Mines", {
            {168, 69},
            {169, 69}
        }},
        {"Find the Three Witches", 0, 0},
        {"Defeat the Three Witches", 0, 0},
        {"Take the staff back to your Elder", {
            {149, 18},
            {150, 18}
        }}
    }
}

local cutSceneImgsNum = 3


function GamePlay.new()
    gamePlay = {}
    setmetatable(gamePlay, GamePlay)

    gamePlay.secondsInDay = 1
    gamePlay.secondsElapsedInDay = 0
    gamePlay.day = 1
    gamePlay.lose = false
    --gamePlay.numberOfTasks = #GamePlay.tasksByDay[self.day]

    gamePlay.cutSceneImgs = {}

    for i=1,cutSceneImgsNum do
        table.insert(gamePlay.cutSceneImgs, love.graphics.newImage("Assets/_UI/cutscene_" .. i ..".png"))
    end

    return gamePlay
end

function GamePlay:getTaskTextAtIndex(i)
    return GamePlay.tasksByDay[self.day][i][1]
end

function GamePlay:getNumberOfTasks()
    --print(#GamePlay.tasksByDay[self.day])
    return #GamePlay.tasksByDay[self.day]
end

function GamePlay:getTilesForTask(taskI)
    --print(self.day, taskI, GamePlay.tasksByDay[self.day][taskI])
    return GamePlay.tasksByDay[self.day][taskI][2]
end

function GamePlay:death()
    gamePlay.lose = true
    Timer.new(0.25, function()
        mainMenu.currCutSceneImg = self.cutSceneImgs[1]
        Timer.new(0.5, function()
            mainMenu.currCutSceneImg = self.cutSceneImgs[2]
            Timer.new(0.5, function()
                mainMenu.currCutSceneImg = self.cutSceneImgs[3]
                Timer.new(0.5, function()
                    love.event.quit()
                end)
            end)
        end)
    end)
end

function GamePlay:win()
    onMenu = true
    mainMenu.endingScene = true
end

function GamePlay:completeDay()
    --Play end day animation
    if self.day == #GamePlay.tasksByDay then
        self:win()
        return
    end
    self.day = self.day + 1
    self.secondsElapsedInDay = 0
end

function GamePlay:completeTask(taskI)
    --Play animation then
    print("complete task")
    table.remove(GamePlay.tasksByDay[self.day], taskI)
    if #GamePlay.tasksByDay[self.day] == 0 then
        print("Complete day")
        self:completeDay()
    end
end

function GamePlay:update(dt)
    sX, sY = world.map:convertScreenToTile(player.x, player.y)
    sX = math.ceil(sX)
    sY = math.ceil(sY)
    for taskI=1,self:getNumberOfTasks() do
        local tilesPos = self:getTilesForTask(taskI)
        for i=1,#tilesPos do
            if sX == tilesPos[i][1] and sY == tilesPos[i][2] then
                self:completeTask(taskI)
                return
            end
        end
    end

    gamePlay.secondsElapsedInDay = gamePlay.secondsElapsedInDay + dt
    if gamePlay.secondsElapsedInDay >= gamePlay.secondsInDay then
        self:death()
    end
end
