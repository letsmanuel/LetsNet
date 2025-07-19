local Starlight = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Starlight-Interface-Suite/master/Source.lua"))()  
local NebulaIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/Loader.lua"))()

local SpeedboostEnabled = false
local amountOfSpeedBoost = 0

local Window = Starlight:CreateWindow({
    Name = "LetsNet DOORS",
    Subtitle = "v1.0",
    Icon = 123456789,

    LoadingSettings = {
        Title = "Builing the gaming chair!",
        Subtitle = "by letsnet software",
    },

    ConfigurationSettings = { -- Not Implemented Yet
        FolderName = "letsnetdoorshub"
    },
})

local Tab = TabSection:CreateTab({
    Name = "Tab",
    Icon = NebulaIcons:GetIcon('view_in_ar', 'Material'),
    Columns = 2,
}, "INDEX")

local Groupbox = Tab:CreateGroupbox({
    Name = "Groupbox",
    Column = 1,
}, "INDEX")

local Button = Groupbox:CreateButton({
    Name = "Button",
    Icon = NebulaIcons:GetIcon('check', 'Material'),
    Callback = function()
        
    end,
}, "INDEX")
