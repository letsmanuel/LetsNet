local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-----------------------------
--- LETSNET DOORS SPEEDHACK --
-----------------------------

local speedboostAmount = 0
local speedBoostOn = false
local defaultWalkSpeed = 16

local Window = Library:CreateWindow({
    Title = 'LetsNet - DOORS',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Speedhack')

LeftGroupBox:AddSlider('speedboost', {
    Text = 'Speedboost',
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        speedboostAmount = Value
    end
})

local function playNotificationSound()
    local sound = Instance.new('Sound')
    sound.SoundId = 'rbxassetid://6026984224' -- Simple notification sound
    sound.Volume = 1
    sound.Parent = game:GetService('SoundService')
    sound:Play()
    game:GetService('Debris'):AddItem(sound, 2)
end

local function notify(text)
    if Library and Library:Notify then
        Library:Notify(text)
    end
    playNotificationSound()
end

LeftGroupBox:AddToggle('speedhack', {
    Text = 'Enable Speedhack',
    Default = false,
    Tooltip = 'Apply the selected speedhack',
    Callback = function(Value)
        speedBoostOn = Value
        if Value then
            notify('Speedhack enabled!')
        else
            notify('Speedhack disabled!')
        end
    end
})

-- Speedhack logic
task.spawn(function()
    local player = game:GetService('Players').LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass('Humanoid')
    
    player.CharacterAdded:Connect(function(newChar)
        char = newChar
        humanoid = char:WaitForChild('Humanoid')
    end)

    while true do
        task.wait(0.1)
        if humanoid then
            if speedBoostOn then
                humanoid.WalkSpeed = defaultWalkSpeed + speedboostAmount
            else
                humanoid.WalkSpeed = defaultWalkSpeed
            end
        end
    end
end)

-- Watermark
Library:SetWatermarkVisibility(true)
local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    Library:SetWatermark(('LetsNet DOORS | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings, Config, Theme
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

-- Ensure Options is defined after UI creation
local Options = getgenv().Options

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
