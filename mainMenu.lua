MainMenu = {}
MainMenu.__index = MainMenu

local paddingStart = 260
local buttonPadding = 10
local numberOfButtons = 2
local buttonWidth = 200
local buttonHeight = 50

local waitTime = 0
local isWaiting = false

local renderGame = false

local buttonActions = {
    function (menu)
        love.audio.play(menu.selectStartSound)
        menu:startTimer(0.75, function ()
            menu.isButtonPressed = false
            menu:startTimer(1, function ()
                world:load()
            end)
        end)
    end,
    function () love.quit() end
}

function isCoordInRect(x, y, rectX, rectY, widthX, widthY)
    return  x > rectX
        and y > rectY
        and x < rectX + widthX
        and y < rectY + widthY
end

function MainMenu.new()
    local menu = {}
    setmetatable(menu, MainMenu)
    menu.buttons = {}
    menu.isButtonPressed = false
    menu.buttonPressedID = 1
    menu.timerStart = false;
    menu.timeLeft = 0
    menu.timerAction = function () end

    menu.splashScreen = true

    menu.splashScreenImg = love.graphics.newImage("Assets/_UI/splash.png")

    menu:startTimer(2, function ()
        menu.splashScreen = false
    end)

    for i=1, numberOfButtons do
        table.insert(menu.buttons, {})
        menu.buttons[i].normalImg = love.graphics.newImage("Assets/_UI/button"..i.."normal.png")
        menu.buttons[i].pressedImg = love.graphics.newImage("Assets/_UI/button"..i.."pressed.png")
        menu.buttons[i].action = buttonActions[i]
    end

    menu.selectStartSound = love.audio.newSource("Assets/_Sounds/selectstart.wav"
        , static)
    menu.menuBackground = love.graphics.newImage("Assets/_UI/titlescreen.png")
    return menu
end


function MainMenu:draw(dt)
    if self.splashScreen then
        love.graphics.draw(self.splashScreenImg, 0, 0)
    end
    currentDrawPosition = paddingStart
    love.graphics.draw(self.menuBackground, 0, 0)
    for i=1, #self.buttons do
        local drawingImg = nil;
        if self.isButtonPressed and self.buttonPressedID == i then
            drawingImg = self.buttons[i].pressedImg
        else
            drawingImg = self.buttons[i].normalImg
        end
        self.buttons[i].xPos = 420
        self.buttons[i].yPos = currentDrawPosition
        love.graphics.draw(drawingImg,
            self.buttons[i].xPos,
            self.buttons[i].yPos)
        currentDrawPosition = currentDrawPosition + buttonHeight + buttonPadding
    end
end

function MainMenu:mousepressed(x, y, button, istouch)
    for i=1, #self.buttons do
        local hasCollided = isCoordInRect(x, y,
            self.buttons[i].xPos,
            self.buttons[i].yPos,
            buttonWidth,
            buttonHeight)
        if button == "l" and hasCollided then
            self.isButtonPressed = true
            self.buttonPressedID = i
            return;
        end
    end
end

function MainMenu:mousereleased(x, y, button, istouch)
    if self.isButtonPressed then
        self.buttons[self.buttonPressedID].action(self)
        love.audio.play(self.selectStartSound)
    end
end


function MainMenu:startTimer(time, func)
    self.timerStart = true
    self.timeLeft = time
    self.timerAction = func
end

function MainMenu:update(dt)
    if self.timerStart then
        self.timeLeft = self.timeLeft - dt
        if self.timeLeft < 0 then
            self.timerAction()
            self.timerStart = true
        end
    end
end
