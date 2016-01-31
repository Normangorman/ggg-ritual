GamePlay = {}
GamePlay.__index = GamePlay

GamePlay.tasksByDay = {
    {
        {"Enter the Forest", {
            {123, 28},
            {123, 29},
            {123, 30},
            {123, 31}
            }
        },
        {"Find the Wood Nymphs’ home", {
            {}
        }},
        {"Find a way to heal the blacksmith", 0, 0 },
        {"Return to your Elder", 0, 0 }
    },{
        {"Find the bandits at the lakeside", 0, 0},
        {"Clear the lakeside of bandits, or defeat the Lake King", 0, 0},
        {"Defeat the Lake King", 0, 0},
        {"Return to the bandit leader", 0, 0},
        {"Bring the ring to your Elder", 0, 0}
    },
    {
        {"Enter the Mines", 0, 0},
        {"Find the Three Witches", 0, 0},
        {"Defeat the Three Witches", 0, 0},
        {"Take the staff back to your Elder", 0, 0}
    }
}

local secondsInDay = 5*60

function GamePlay.new()
    gamePlay = {}
    setmetatable(gamePlay, GamePlay)

    gamePlay.secondsElapsedInDay = 0
    gamePlay.day = 1

    return gamePlay
end

function GamePlay:getTaskTextAtIndex(i)
    return GamePlay.tasksByDay[self.day][i][1]
end

function GamePlay:getNumberOfTasks()
    return #GamePlay.tasksByDay[self.day]
end

function GamePlay:getTilesForTask(taskI)
    return GamePlay.tasksByDay[self.day][taskI][2]
end

function GamePlay:death()
    print("Death")
end

function GamePlay:win()
    print("You win")
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
    table.remove(GamePlay.tasksByDay[self.day], taskI)
    if #GamePlay.tasksByDay[self.day] == 0 then
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
            end
        end
    end

    gamePlay.secondsElapsedInDay = gamePlay.secondsElapsedInDay + dt
    if gamePlay.secondsElapsedInDay >  secondsInDay then
        self:death()
    end
end
