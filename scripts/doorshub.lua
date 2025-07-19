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
