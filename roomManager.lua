RoomManager = {}
RoomManager.__index = RoomManager

function RoomManager.new()
    local roomManager = {}
    setmetatable(roomManager, RoomManager)
    roomManager.currentClass = {}


    return roomManager
end

function RoomManager:dispatchEvent(eventName, ...)
    if self.currentClass[eventName] ~= nil then
        self.currentClass[eventName](self.currentClass, unpack(arg))
        --Call with self and the arguments
    end
end

function RoomManager:changeRoom(newRoom)
    newRoom:load()
    self.currentClass = newRoom
end
