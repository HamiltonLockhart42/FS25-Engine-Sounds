ShopEnginePreview = {
    MOD_NAME = g_currentModName,
    ACTION_NAME = "TOGGLE_SHOP_ENGINE_PREVIEW"
}

local ShopEnginePreview_mt = Class(ShopEnginePreview)

function ShopEnginePreview.new()
    local self = setmetatable({}, ShopEnginePreview_mt)
    self.actionEventId = nil
    self.currentVehicle = nil
    self.currentScreen = nil
    self.hooksInstalled = false
    return self
end

function ShopEnginePreview:loadMap()
    if g_dedicatedServer ~= nil then
        return
    end

    if g_gui == nil or g_inputBinding == nil then
        Logging.info("[%s] GUI systems unavailable.", ShopEnginePreview.MOD_NAME)
        return
    end

    self:installHooksIfAvailable()
end

function ShopEnginePreview:update(dt)
    if g_dedicatedServer ~= nil then
        return
    end

    if self.hooksInstalled then
        return
    end

    if g_gui == nil or g_inputBinding == nil then
        return
    end

    self:installHooksIfAvailable()
end

function ShopEnginePreview:installHooksIfAvailable()
    if ShopConfigScreen == nil then
        return
    end

    self:installHooks(ShopConfigScreen)
end

function ShopEnginePreview:installHooks(screenClass)
    if self.hooksInstalled then
        return
    end

    screenClass.onOpen = Utils.appendedFunction(screenClass.onOpen, function(screen, ...)
        self:onShopOpen(screen)
    end)

    screenClass.onClose = Utils.appendedFunction(screenClass.onClose, function(screen, ...)
        self:onShopClose(screen)
    end)

    screenClass.update = Utils.appendedFunction(screenClass.update, function(screen, dt)
        self:onShopUpdate(screen, dt)
    end)

    self.hooksInstalled = true
end

function ShopEnginePreview:onShopOpen(screen)
    self.currentScreen = screen
    self.currentVehicle = self:getPreviewVehicle(screen)
    self:registerActionEvent()
end

function ShopEnginePreview:onShopClose(screen)
    if self.currentScreen ~= screen then
        return
    end

    self:stopPreviewEngine(self.currentVehicle)
    self:unregisterActionEvent()
    self.currentVehicle = nil
    self.currentScreen = nil
end

function ShopEnginePreview:onShopUpdate(screen, dt)
    if self.currentScreen ~= screen then
        return
    end

    local vehicle = self:getPreviewVehicle(screen)
    if vehicle ~= self.currentVehicle then
        self:stopPreviewEngine(self.currentVehicle)
        self.currentVehicle = vehicle
    end
end

function ShopEnginePreview:getPreviewVehicle(screen)
    if screen == nil then
        return nil
    end

    if screen.vehicle ~= nil then
        return screen.vehicle
    end

    if screen.currentVehicle ~= nil then
        return screen.currentVehicle
    end

    if screen.vehiclePreview ~= nil and screen.vehiclePreview.vehicle ~= nil then
        return screen.vehiclePreview.vehicle
    end

    return nil
end

function ShopEnginePreview:registerActionEvent()
    self:unregisterActionEvent()

    if g_inputBinding == nil then
        return
    end

    local actionId = InputAction[self.ACTION_NAME]
    if actionId == nil then
        Logging.warning("[%s] Missing input action '%s'.", ShopEnginePreview.MOD_NAME, self.ACTION_NAME)
        return
    end

    local _, eventId = g_inputBinding:registerActionEvent(actionId, self, self.onActionTogglePreview, false, true, false, true)
    self.actionEventId = eventId

    if self.actionEventId ~= nil then
        local actionText = g_i18n:getText("shop_engine_preview_action")
        g_inputBinding:setActionEventText(self.actionEventId, actionText)
        g_inputBinding:setActionEventTextPriority(self.actionEventId, GS_PRIO_HIGH)
        g_inputBinding:setActionEventActive(self.actionEventId, true)
    end
end

function ShopEnginePreview:unregisterActionEvent()
    if self.actionEventId ~= nil and g_inputBinding ~= nil then
        g_inputBinding:removeActionEvent(self.actionEventId)
    end

    self.actionEventId = nil
end

function ShopEnginePreview:onActionTogglePreview(_, inputValue, _, isAnalog)
    if isAnalog then
        if math.abs(inputValue) < 0.5 then
            return
        end
    elseif inputValue == 0 then
        return
    end

    local vehicle = self.currentVehicle
    if vehicle == nil then
        return
    end

    if self:isPreviewEngineRunning(vehicle) then
        self:stopPreviewEngine(vehicle)
    else
        self:startPreviewEngine(vehicle)
    end
end

function ShopEnginePreview:isPreviewEngineRunning(vehicle)
    if vehicle == nil then
        return false
    end

    if vehicle.getIsMotorStarted ~= nil then
        return vehicle:getIsMotorStarted()
    end

    local motor = vehicle.getMotor ~= nil and vehicle:getMotor() or nil
    if motor ~= nil and motor.getIsMotorStarted ~= nil then
        return motor:getIsMotorStarted()
    end

    return false
end

function ShopEnginePreview:startPreviewEngine(vehicle)
    if vehicle == nil then
        return
    end

    if vehicle.startMotor ~= nil then
        vehicle:startMotor()
        return
    end

    local motor = vehicle.getMotor ~= nil and vehicle:getMotor() or nil
    if motor ~= nil and motor.setMotorStarted ~= nil then
        motor:setMotorStarted(true)
    end
end

function ShopEnginePreview:stopPreviewEngine(vehicle)
    if vehicle == nil then
        return
    end

    if vehicle.stopMotor ~= nil then
        vehicle:stopMotor()
        return
    end

    local motor = vehicle.getMotor ~= nil and vehicle:getMotor() or nil
    if motor ~= nil and motor.setMotorStarted ~= nil then
        motor:setMotorStarted(false)
    end
end

addModEventListener(ShopEnginePreview.new())
