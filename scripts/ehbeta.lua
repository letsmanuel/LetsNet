local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local SCRIPTRUNNING = true
local INBOOTSTRAP = false
local inputDirection = Vector3.new(0, 0, 0)
local BYPASSKEYSYSTEM = true
local DEBUG = true
local Version = "1.0.4"
if DEBUG == true then
    Version = "DEBUG "..Version.." "..math.random(1, 100)
end

function showIntro()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer
    local username = player.Name
    
    -- GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "WelcomeGui"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 80)
    frame.Position = UDim2.new(1, 10, 0, 10)
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = true
    frame.Parent = gui
    
    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 12)
    leftCorner.Parent = frame
    
    -- Cover the right edge to remove the roundness visually
    local rightCover = Instance.new("Frame")
    rightCover.Size = UDim2.new(0, 12, 1, 0)
    rightCover.Position = UDim2.new(1, -12, 0, 0)
    rightCover.BackgroundColor3 = frame.BackgroundColor3
    rightCover.BorderSizePixel = 0
    rightCover.ZIndex = 2
    rightCover.Parent = frame
    
    -- Text Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.6, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Welcome back\n" .. username
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.ZIndex = 3
    label.Parent = frame
    
    -- Green Bar
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 0.15, 0)
    bar.Position = UDim2.new(0, 0, 0.85, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    bar.BorderSizePixel = 0
    bar.ClipsDescendants = true
    bar.ZIndex = 2
    bar.Parent = frame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 12)
    barCorner.Parent = bar
    
    local barRightCover = Instance.new("Frame")
    barRightCover.Size = UDim2.new(0, 12, 1, 0)
    barRightCover.Position = UDim2.new(1, -12, 0, 0)
    barRightCover.BackgroundColor3 = bar.BackgroundColor3
    barRightCover.BorderSizePixel = 0
    barRightCover.ZIndex = 3
    barRightCover.Parent = bar
    
    -- Tween In
    local fadeIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
        BackgroundTransparency = 0
    })
    local barGrow = TweenService:Create(bar, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
        Size = UDim2.new(1, 0, 0.15, 0)
    })
    
    fadeIn:Play()
    barGrow:Play()
    
    -- Tween Out after delay
    task.delay(5, function()
        local fadeOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
            BackgroundTransparency = 1
        })
        local barShrink = TweenService:Create(bar, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
            Size = UDim2.new(0, 0, 0.15, 0)
        })
    
        fadeOut:Play()
        barShrink:Play()
    
        fadeOut.Completed:Wait()
        gui:Destroy()
    end)
    
end


local function startScript(hasLifeTimeKey)
    showIntro()
    local RunService = game:GetService("RunService")

    local Window = Fluent:CreateWindow({
        Title = "LetsNet - EH: " .. Version,
        SubTitle = "by Manuel",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
        Theme = "Amethyst",
        MinimizeKey = Enum.KeyCode.RightShift -- Used when theres no MinimizeKeybind
    })

    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "" }),
        Practical = Window:AddTab({ Title = "Practical", Icon = "" }),
        AimbotTab = Window:AddTab({ Title = "Gun Mods", Icon = "" }),
        VehicleTab = Window:AddTab({ Title = "Vehicle", Icon = "" }),
        Graphical = Window:AddTab({ Title = "Visuals", Icon = "" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    local Options = Fluent.Options



    -- VARIABLES
    local player = game.Players.LocalPlayer
    local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false

    if not vehicle then
        Fluent:Notify({
            Title = "Error!",
            Content = "Vehicle not found.",
            SubContent = "You HAVE to have a vehicle when starting the script!", -- Optional
            Duration = 5 -- Set to nil to make the notification not disappear
        })
        Tabs.Main:AddParagraph({
            Title = "WARNING",
            Content = "The script has crashed because you have no vehicle under your name currently spawned. You may close the script and reexecute once you have a vehicle.",
        })
        return
    end

    local garagedoorpermanentopen = false
    local deletealldoors = false
    local whileloopcounter1 = 0
    local whileloopcounter2 = 0
    local teleportToLocation = nil
    local hasTriggeredemergencyMove = false
    local autoseattoggle = false
    local savemybutt = false
    local Players = game:GetService("Players")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local PLAYERESP_main = false
    local PLAYERESP_box = false
    local PLAYERESP_highlight = false
    local PLAYERESP_name = false
    local PLAYERESP_distance = false
    local PLAYERESP_team = falsea
    local PLAYERESP_healthbar = false
    local lastlightbank = false
    local SENDNOTIFICTIONS = false
    local LICENSEPLATE = "EH HUB"
    local TUNINGLEVEL = vehicle:GetAttribute("engineLevel")
    local GODCAR = false
    local INTELEPORTPROCESS = false
    local anticopradar = false
    local ANTICOPYRADERTRIGGERED = false
    local antitaser = false
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false
    local inputDirection = Vector3.zero
    local CARFLYspeed = 2
    local CARFLY = false
    local CARFLYteleportetoSeat = false
    local CARFLYunflyTeleportLoopInit = 0
    local speedCamerasMobile = workspace.SpeedCameras:WaitForChild("Mobile")
    local speedCamerasStationary = workspace.SpeedCameras:WaitForChild("Stationary")
    local ANTINORMALRADARTRIGGERED = false
    local antinormradar = false
    local lifetimekey = hasLifeTimeKey
    local aim_config = _G.JALON_AIMCONFIG or {
        Enabled = true,
        KeyActivation = Enum.UserInputType.MouseButton2, -- RightClick
        CloseKey = Enum.KeyCode.L, -- Close with "L"
        
        FOV = 175,
        TeamCheck = false, -- TeamCheck deaktiviert
        DistanceCheck = true,
        VisibleCheck = true,

        Smoothness = 0.975,
        Prediction = {
            Enabled = false,
            Value = 0.185
        }
    }
    _G.JALON_AIMCONFIG = _G.JALON_AIMCONFIG or aim_config
    local input_service = game:GetService("UserInputService")
    local players = game:GetService("Players")
    local run_service = game:GetService("RunService")
    local camera = workspace.CurrentCamera
    local player = players.LocalPlayer
    local fovCircle, targetBox = Drawing.new("Circle"), Drawing.new("Square")
    local current_nearest_plr
    local aim_enabled = true
    local onlyunrobbedvendingmachines = false
    local CITYBUSAUTOFARM = false



    -- ERRORCODE MEANINGS:
    -- 1 = Vehicle not found or no PrimaryPart (Vehicle Teleport)

    -- THATS FOR CARFLY
    local anchoredParts = {}


    if TUNINGLEVEL == nil then
        TUNINGLEVEL = 1
    end




    do
        Fluent:Notify({
            Title = "Thanks.",
            Content = "Welcome back "..game.Players.LocalPlayer.DisplayName.."!",
            SubContent = "", -- Optional
            Duration = 5 -- Set to nil to make the notification not disappear
        })


        if not lifetimekey then
            Tabs.Main:AddParagraph({
                Title = "Information!",
                Content = "You are using the free version of the script. Some features may be limited.\n To unlock all features, get a lifetime key on our discord server!",
            })
            Tabs.Main:AddButton({
                Title = "Join on Discord",
                Description = "Join our discord server to be able to get a lifetime key!",
                Callback = function()
                    local invite = "https://discord.gg/5zErAPgCYm"
                    setclipboard(invite)
                    Fluent:Notify({
                        Title = "Success.",
                        Content = "Link copied to clipboard.",
                        SubContent = "", -- Optional
                        Duration = 5 -- Set to nil to make the notification not disappear
                    })
                end
            })
        end

        local GarageDoorPernOpenToggle = Tabs.Practical:AddToggle("GarageDoorPernOpenToggle", {Title = "Hold Garages open", Default = false })

        GarageDoorPernOpenToggle:OnChanged(function()
            garagedoorpermanentopen = Options.GarageDoorPernOpenToggle.Value
            if garagedoorpermanentopen then
                for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                    if model:IsA("Model") and model.Name == "GarageDoor" then
                        model:SetAttribute("IsTriggered", true)
                    end
                end
                for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                    if model:IsA("Model") and model.Name == "Bollards" then
                        model:SetAttribute("IsTriggered", true)
                    end
                end
                for _, model in pairs(workspace.Gates:GetChildren()) do
                    if model:IsA("Model") and model.Name == "Gate" then
                        model:SetAttribute("IsTriggered", false)
                        model:SetAttribute("IsTriggered", true)
                        model:SetAttribute("OpeningDuration", 0.1)
                    end
                end
                Fluent:Notify({
                    Title = "Garage Doors",
                    Content = "Garage doors, Gates and Bollards will now stay open.",
                    SubContent = "", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })
            else
                for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                    if model:IsA("Model") and model.Name == "GarageDoor" then
                        model:SetAttribute("IsTriggered", false)
                    end
                end
                for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                    if model:IsA("Model") and model.Name == "Bollards" then
                        model:SetAttribute("IsTriggered", false)
                    end
                end
                for _, model in pairs(workspace.Gates:GetChildren()) do
                    if model:IsA("Model") and model.Name == "Gate" then
                        model:SetAttribute("IsTriggered", false)
                    end
                end
                for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                    if model:IsA("Model") and model.Name == "GarageDoor" then
                        model:SetAttribute("IsTriggered", true)
                    end
                end
                for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                    if model:IsA("Model") and model.Name == "Bollards" then
                        model:SetAttribute("IsTriggered", true)
                    end
                end
                for _, model in pairs(workspace.Gates:GetChildren()) do
                    if model:IsA("Model") and model.Name == "Gate" then
                        model:SetAttribute("IsTriggered", false)
                        model:SetAttribute("IsTriggered", true)
                    end
                end
                for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                    if model:IsA("Model") and model.Name == "GarageDoor" then
                        model:SetAttribute("IsTriggered", false)
                    end
                end
                for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                    if model:IsA("Model") and model.Name == "Bollards" then
                        model:SetAttribute("IsTriggered", false)
                    end
                end
                for _, model in pairs(workspace.Gates:GetChildren()) do
                    if model:IsA("Model") and model.Name == "Gate" then
                        model:SetAttribute("IsTriggered", false)
                    end
                end
                Fluent:Notify({
                    Title = "Garage Doors",
                    Content = "Garage doors, Gates and Bollards will now close.",
                    SubContent = "", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })
                task.wait(0.3)
                for _, model in pairs(workspace.Gates:GetChildren()) do
                    if model:IsA("Model") and model.Name == "Gate" then
                        model:SetAttribute("IsTriggered", false)
                    end
                end
            end
            --print("Toggle changed:", Options.GarageDoorPernOpenToggle.Value)
        end)

        local function updateInput(input, isPressed)
            local delta = Vector3.new(0, 0, 0)
        
            if input.KeyCode == Enum.KeyCode.W then delta = Vector3.new(0, 0, -1) end
            if input.KeyCode == Enum.KeyCode.S then delta = Vector3.new(0, 0, 1) end
            if input.KeyCode == Enum.KeyCode.A then delta = Vector3.new(-1, 0, 0) end
            if input.KeyCode == Enum.KeyCode.D then delta = Vector3.new(1, 0, 0) end
            if input.KeyCode == Enum.KeyCode.Space then delta = Vector3.new(0, 1, 0) end
            if input.KeyCode == Enum.KeyCode.LeftShift then delta = Vector3.new(0, -1, 0) end
        
            if isPressed then
                inputDirection += delta
            else
                inputDirection -= delta
            end
        end

        
        
        
        -- Input events (stay connected regardless)
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe then updateInput(input, true) end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            updateInput(input, false)
        end)
        
        -- Store and set Anchored state
        local function setAnchored(state)
            for _, part in pairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    if anchoredParts[part] == nil then
                        anchoredParts[part] = part.Anchored
                    end
                    part.Anchored = state
                end
            end
        end

        local PlayerESPmain = Tabs.Graphical:AddToggle("playerespmain", {Title = "Player ESP", Default = false })

        PlayerESPmain:OnChanged(function()
            PLAYERESP_main = Options.playerespmain.Value
        end)

        local notifyToggle = Tabs.Practical:AddToggle("notifytoggle", {Title = "Notify Toggle", Default = false })

        notifyToggle:OnChanged(function()
            SENDNOTIFICTIONS = Options.notifytoggle.Value
        end)



        local CARFLYToggle = Tabs.VehicleTab:AddToggle("carfly", {Title = "CarFly", Default = false })

        CARFLYToggle:OnChanged(function()
            CARFLY = Options.carfly.Value
        end)
        
        local CARFLYspeedSlider = Tabs.VehicleTab:AddSlider("Slider", {
            Title = "CarFly Speed",
            Description = "Adjust the speed of CarFly. CAN GET YOU BANNED!",
            Default = 2,
            Min = 1,
            Max = 4,
            Rounding = 1,
            Callback = function(Value)
                CARFLYspeed = Value
            end
        })





        -- functions
        local function is_player_valid(plrArg)
            local plrChar = plrArg.Character
            local plrHumanoid, target_part = (plrChar and plrChar:FindFirstChildWhichIsA("Humanoid")), (plrChar and plrChar:FindFirstChild("HumanoidRootPart"))
            -- TeamCheck is now disabled (always returns true for team check)
            return plrArg ~= player and (plrChar and (plrHumanoid and plrHumanoid.Health ~= 0)) and not plrArg.Character:FindFirstChildWhichIsA("ForceField"), target_part
        end

        local function get_rootpart(plr)
            return (if plr.Character then plr.Character:FindFirstChild("HumanoidRootPart") else nil)
        end

        local function in_line_of_sight(origin_pos, ...)
            return #camera:GetPartsObscuringTarget({origin_pos}, {camera, player.Character, ...}) == 0
        end

        local function get_vel_prediction(velocity)
            return Vector3.new(velocity.X, math.clamp((velocity.Y * 0.5), -5, 10), velocity.Z)
        end

        local function get_camera_prediction(predicting_part)
            return predicting_part.CFrame + get_vel_prediction(predicting_part.Velocity) * (aim_config.Prediction.Value)
        end

        -- gets nearest player relative to cursor
        local function get_nearest_player()
            local nearest_plr_data = {aimPart = nil, cursor_dist = math.huge, char_dist = math.huge}

            for _, plr in players:GetPlayers() do
                local passed, target_part = is_player_valid(plr)
                if not (passed and target_part) then continue end
                local screen_pos, on_screen = camera:WorldToViewportPoint(target_part.Position)
                local fov_dist = (input_service:GetMouseLocation() - Vector2.new(screen_pos.X, screen_pos.Y)).Magnitude
                local char_dist = (get_rootpart(player).Position - target_part.Position).Magnitude

                if (not aim_config.VisibleCheck or (on_screen and in_line_of_sight(camera.CFrame, plr.Character))) then
                    if ((fov_dist <= aim_config.FOV) and (fov_dist < nearest_plr_data.cursor_dist)) and (not aim_config.DistanceCheck or (char_dist < nearest_plr_data.char_dist)) then
                        nearest_plr_data.aimPart = target_part
                        nearest_plr_data.cursor_dist = fov_dist
                        nearest_plr_data.char_dist = char_dist
                    end
                end
            end
            return (if nearest_plr_data.aimPart then nearest_plr_data else nil)
        end

        -- main
        targetBox.Color = Color3.fromRGB(0, 185, 35)
        targetBox.Filled = true
        targetBox.Size = Vector2.new(20, 20)
        targetBox.Thickness = 20
        targetBox.Transparency = .6

        fovCircle.Color = Color3.fromRGB(0, 185, 35)
        fovCircle.Thickness = 2
        fovCircle.Transparency = .6
        fovCircle.Visible = true


        run_service.PreSimulation:Connect(function()
            if not aim_enabled then
                -- Hide the FOV circle and target box when the script is disabled
                fovCircle.Visible = false
                targetBox.Visible = false
                return
            end

            current_nearest_plr = get_nearest_player()

            fovCircle.Radius = aim_config.FOV
            fovCircle.Position = input_service:GetMouseLocation()

            if current_nearest_plr then
                local screen_pos, on_screen = camera:WorldToViewportPoint(current_nearest_plr.aimPart.Position)

                targetBox.Visible = on_screen
                targetBox.Position = (Vector2.new(screen_pos.X, screen_pos.Y) - (targetBox.Size / 2))

                if input_service:IsMouseButtonPressed(aim_config.KeyActivation) then -- RightClick to activate aim
                    local target_position = (if aim_config.Prediction.Enabled then get_camera_prediction(current_nearest_plr.aimPart) else current_nearest_plr.aimPart)
                    local horizontal_look = CFrame.lookAt(camera.CFrame.Position, target_position.Position)

                    camera.CFrame = camera.CFrame:Lerp(horizontal_look, aim_config.Smoothness)
                end
            else
                targetBox.Visible = false
                targetBox.Position = Vector3.zero
            end
        end)


        
        local aimbotToggle = Tabs.AimbotTab:AddToggle("aimbot", {Title = "Aimbot", Default = false })

        aimbotToggle:OnChanged(function()
            aim_enabled = Options.aimbot.Value
            if aim_enabled then
                fovCircle.Visible = true
                targetBox.Visible = true
            else
                fovCircle.Visible = false
                targetBox.Visible = false
            end
        end)

        local MultiDropdown = Tabs.Graphical:AddDropdown("PlayerESP", {
            Title = "Player ESP Options",
            Description = "Select multiple ESP options to enable.",
            Values = {
                "box",
                "highlight",
                "name",
                "distance",
                "team",
                "healthbar"
            },
            Multi = true,  -- This enables multiple selection
            Default = {"box", "highlight", "name", "distance"}
        })

        -- You can update the PLAYERESP variables based on selected values
        MultiDropdown:OnChanged(function(Value)
            -- Reset all variables first
            PLAYERESP_box = false
            PLAYERESP_highlight = false
            PLAYERESP_name = false
            PLAYERESP_distance = false
            PLAYERESP_team = false
            PLAYERESP_healthbar = false
            
            -- Loop through selected values and update the corresponding variables
            for selectedOption, _ in next, Value do
                if selectedOption == "box" then
                    PLAYERESP_box = true
                elseif selectedOption == "highlight" then
                    PLAYERESP_highlight = true
                elseif selectedOption == "name" then
                    PLAYERESP_name = true
                elseif selectedOption == "distance" then
                    PLAYERESP_distance = true
                elseif selectedOption == "team" then
                    PLAYERESP_team = true
                elseif selectedOption == "healthbar" then
                    PLAYERESP_healthbar = true
                end
            end
            
            -- You can also print out the selected options to confirm
            local selectedOptions = {}
            for selectedOption, _ in next, Value do
                table.insert(selectedOptions, selectedOption)
            end
            --print("Selected options: " .. table.concat(selectedOptions, ", "))
        end)

        Tabs.Practical:AddButton({
            Title = "Delete all Doors",
            Description = "Deletes all Glass, Sliding or Metal doors.",
            Callback = function()
                Window:Dialog({
                    Title = "Warning:",
                    Content = "This action cannot be undone. This will greatly decrease performance by causing ONE quick lag spike every 20 seconds.",
                    Buttons = {
                        {
                            Title = "Confirm",
                            Callback = function()
                                local function deleteDoors(parent)
                                    for _, obj in pairs(parent:GetChildren()) do
                                        if obj:IsA("Model") then
                                            if obj.Name == "SlidingDoor" or obj.Name == "MetalDoor" or obj.Name == "GlassDoor" or obj.Name == "Destroyable Door" or obj.Name == "HiddenExit" then
                                                obj:Destroy()
                                                task.wait() -- short pause to avoid lag
                                            else
                                                deleteDoors(obj)
                                            end
                                        elseif obj:IsA("Folder") then
                                            deleteDoors(obj)
                                        end
                                    end
                                end
                                
                                task.spawn(function()
                                    deleteDoors(workspace)
                                end)
                                deletealldoors = true
                                Fluent:Notify({
                                    Title = "Door deletion",
                                    Content = "All doors have been deleted.",
                                    SubContent = "", -- Optional
                                    Duration = 5 -- Set to nil to make the notification not disappear
                                })  
                            end
                        },
                        {
                            Title = "Cancel",
                            Callback = function()
                                --print("Cancelled the dialog.")
                            end
                        }
                    }
                })
            end
        })
        Tabs.Practical:AddButton({
            Title = "Door deletion stop",
            Description = "KILLS the thread deleting the doors.",
            Callback = function()
                deletealldoors = false
                Fluent:Notify({
                    Title = "Door deletion",
                    Content = "Thread should be killed.",
                    SubContent = "", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })  
            end
        })

        Tabs.Practical:AddButton({
            Title = "Open Hidden Exit (Bank)",
            Description = "Deletes the concrete blocking the hidden exit in the bank.",
            Callback = function()
                
                for _, obj in pairs(parent:GetChildren()) do
                    if obj:IsA("Model") then
                        if obj.Name == "HiddenExit" then
                            obj:Destroy()
                            task.wait() -- short pause to avoid lag
                        else
                            deleteDoors(obj)
                        end
                    elseif obj:IsA("Folder") then
                        deleteDoors(obj)
                    end
                end
                Fluent:Notify({
                    Title = "Success!",
                    Content = "The hidden Exit door should be open.",
                    SubContent = "", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })  
            end
        })

        Tabs.Settings:AddButton({
            Title = "Kill Script Backend",
            Description = "RUN BEFORE REEXECUTING!",
            Callback = function()
                Window:Dialog({
                    Title = "Warning",
                    Content = "This will shutdown the script. You will have to rejoin to fix graphical issues!",
                    Buttons = {
                        {
                            Title = "Confirm",
                            Callback = function()
                                SCRIPTRUNNING = false
                            end
                        },
                        {
                            Title = "Cancel",
                            Callback = function()
                                --print("Cancelled the dialog.")
                            end
                        }
                    }
                })
            end
        })

        local function teleportVEHICLEONLYto(target)
            if INTELEPORTPROCESS then
                Fluent:Notify({
                    Title = "Sorry!",
                    Content = "You cannot teleport your vehicle while already teleporting.",
                    SubContent = "Thats to prevent Anticheat noticing you!", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })
                return
            end
            INTELEPORTPROCESS = true
            local player = game.Players.LocalPlayer
            local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false
            if not vehicle then return end

            
            -- Ziel-CFrame eingeben
            local targetCFrame = CFrame.new(target)
            
            -- Werte für Bewegung
            local stepSize = 1.5
            local delayTime = 0.01
            
            -- Hilfsfunktion zur langsamen Bewegung entlang einer Achse
            local function moveAxis(start, goal, callback)
                local direction = (goal - start) >= 0 and 1 or -1
                local pos = start
                while (direction == 1 and pos < goal) or (direction == -1 and pos > goal) do
                    pos += stepSize * direction
                    if (direction == 1 and pos > goal) or (direction == -1 and pos < goal) then
                        pos = goal
                    end
                    callback(pos)
                    task.wait(delayTime)
                end
            end

            local function moveXZ(startX, goalX, startZ, goalZ, callback)
                local totalDistance = math.sqrt((goalX - startX)^2 + (goalZ - startZ)^2)
                local steps = math.ceil(totalDistance / stepSize)
            
                for i = 1, steps do
                    local t = i / steps
                    local newX = startX + (goalX - startX) * t
                    local newZ = startZ + (goalZ - startZ) * t
                    callback(newX, newZ)
                    task.wait(delayTime)
                end
            
                -- Sicherstellen, dass wir exakt am Ziel ankommen
                callback(goalX, goalZ)
            end
            
            
            if vehicle and vehicle:IsA("Model") and vehicle.PrimaryPart then
                local root = vehicle.PrimaryPart
                local currentPos = root.Position
                local targetPos = targetCFrame.Position
            
                -- 1. Langsam anheben auf Y + 10
                moveAxis(currentPos.Y, currentPos.Y + 100, function(y)
                    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, y, currentPos.Z)))
                end)
            
                currentPos = vehicle.PrimaryPart.Position
            
                -- 2. Langsam bewegen auf X
                --moveAxis(currentPos.X, targetPos.X, function(x)
                --    vehicle:PivotTo(CFrame.new(Vector3.new(x, currentPos.Y, currentPos.Z)))
                --    currentPos = vehicle.PrimaryPart.Position
                --end)
            
                -- 3. Langsam bewegen auf Z
                --moveAxis(currentPos.Z, targetPos.Z, function(z)
                --    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, currentPos.Y, z)))
                --   currentPos = vehicle.PrimaryPart.Position
                --end)

                moveXZ(currentPos.X, targetPos.X, currentPos.Z, targetPos.Z, function(x, z)
                    vehicle:PivotTo(CFrame.new(Vector3.new(x, currentPos.Y, z)))
                    currentPos = vehicle.PrimaryPart.Position
                end)

                currentPos = vehicle.PrimaryPart.Position
                local seat = vehicle:WaitForChild("DriveSeat")

                if player.Character and player.Character:FindFirstChild("Humanoid") then
                        seat:Sit(player.Character.Humanoid)
                end

                moveAxis(currentPos.Y, targetPos.Y + 20, function(y)
                    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, y, currentPos.Z)))
                end)

                currentPos = vehicle.PrimaryPart.Position

                stepSize = 0.2
                delayTime = 0.005

                local seat = vehicle:WaitForChild("DriveSeat")

                if player.Character and player.Character:FindFirstChild("Humanoid") then
                        seat:Sit(player.Character.Humanoid)
                end
            
                -- 4. Langsam absenken auf Ziel-Y
                moveAxis(currentPos.Y, targetPos.Y, function(y)
                    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, y, currentPos.Z)))
                end)

                local seat = vehicle:WaitForChild("DriveSeat")

                if player.Character and player.Character:FindFirstChild("Humanoid") then
                        seat:Sit(player.Character.Humanoid)
                end
                

            else
                Fluent:Notify({
                    Title = "Alert!",
                    Content = "To prevent an error, the current operation was cancelled.",
                    SubContent = "Errorcode: 1", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })
            end
            INTELEPORTPROCESS = false
        end

        local function teleportBUSTo(target)
            if INTELEPORTPROCESS then
                Fluent:Notify({
                    Title = "Sorry!",
                    Content = "You cannot teleport while already teleporting.",
                    SubContent = "Thats to prevent Anticheat noticing you!", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })
                return
            end
            INTELEPORTPROCESS = true
            local player = game.Players.LocalPlayer
            local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false
            if not vehicle then return end
            local seat = vehicle:WaitForChild("DriveSeat")

            if player.Character and player.Character:FindFirstChild("Humanoid") then
                if autoseattoggle then
                    seat:Sit(player.Character.Humanoid)
                end
            end

            
            -- Ziel-CFrame eingeben
            local targetCFrame = CFrame.new(target)
            
            -- Werte für Bewegung
            local stepSize = 0.5
            local delayTime = 0.005
            
            -- Hilfsfunktion zur langsamen Bewegung entlang einer Achse
            local function moveAxis(start, goal, callback)
                local direction = (goal - start) >= 0 and 1 or -1
                local pos = start
                while (direction == 1 and pos < goal) or (direction == -1 and pos > goal) do
                    pos += stepSize * direction
                    if (direction == 1 and pos > goal) or (direction == -1 and pos < goal) then
                        pos = goal
                    end
                    callback(pos)
                    task.wait(delayTime)
                end
            end

            local function moveXZ(startX, goalX, startZ, goalZ, callback)
                local totalDistance = math.sqrt((goalX - startX)^2 + (goalZ - startZ)^2)
                local steps = math.ceil(totalDistance / stepSize)
            
                for i = 1, steps do
                    local t = i / steps
                    local newX = startX + (goalX - startX) * t
                    local newZ = startZ + (goalZ - startZ) * t
                    callback(newX, newZ)
                    task.wait(delayTime)
                end
            
                -- Sicherstellen, dass wir exakt am Ziel ankommen
                callback(goalX, goalZ)
            end
            
            
            if vehicle and vehicle:IsA("Model") and vehicle.PrimaryPart then
                local root = vehicle.PrimaryPart
                local currentPos = root.Position
                local targetPos = targetCFrame.Position
            
                -- 1. Langsam anheben auf Y + 10
                moveAxis(currentPos.Y, currentPos.Y + 70, function(y)
                    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, y, currentPos.Z)))
                end)
            
                currentPos = vehicle.PrimaryPart.Position
            
                -- 2. Langsam bewegen auf X
                --moveAxis(currentPos.X, targetPos.X, function(x)
                --    vehicle:PivotTo(CFrame.new(Vector3.new(x, currentPos.Y, currentPos.Z)))
                --    currentPos = vehicle.PrimaryPart.Position
                --end)
            
                -- 3. Langsam bewegen auf Z
                --moveAxis(currentPos.Z, targetPos.Z, function(z)
                --    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, currentPos.Y, z)))
                --   currentPos = vehicle.PrimaryPart.Position
                --end)

                moveXZ(currentPos.X, targetPos.X, currentPos.Z, targetPos.Z, function(x, z)
                    vehicle:PivotTo(CFrame.new(Vector3.new(x, targetPos.Y+60, z)))
                    currentPos = vehicle.PrimaryPart.Position
                end)

                currentPos = vehicle.PrimaryPart.Position

                moveAxis(currentPos.Y, targetPos.Y + 20, function(y)
                    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, y, currentPos.Z)))
                end)

                currentPos = vehicle.PrimaryPart.Position

                stepSize = 0.2
                delayTime = 0.005
            
                -- 4. Langsam absenken auf Ziel-Y
                moveAxis(currentPos.Y, targetPos.Y+1, function(y)
                    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, y, currentPos.Z)))
                end)
                

            else
                Fluent:Notify({
                    Title = "Alert!",
                    Content = "To prevent an error, the current operation was cancelled.",
                    SubContent = "Errorcode: 1", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })
            end
            INTELEPORTPROCESS = false
        end


        local function teleportTo(target)
            if INTELEPORTPROCESS then
                Fluent:Notify({
                    Title = "Sorry!",
                    Content = "You cannot teleport while already teleporting.",
                    SubContent = "Thats to prevent Anticheat noticing you!", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })
                return
            end
            INTELEPORTPROCESS = true
            local player = game.Players.LocalPlayer
            local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false
            if not vehicle then return end
            local seat = vehicle:WaitForChild("DriveSeat")

            if player.Character and player.Character:FindFirstChild("Humanoid") then
                if autoseattoggle then
                    seat:Sit(player.Character.Humanoid)
                end
            end

            
            -- Ziel-CFrame eingeben
            local targetCFrame = CFrame.new(target)
            
            -- Werte für Bewegung
            local stepSize = 1.5
            local delayTime = 0.01
            
            -- Hilfsfunktion zur langsamen Bewegung entlang einer Achse
            local function moveAxis(start, goal, callback)
                local direction = (goal - start) >= 0 and 1 or -1
                local pos = start
                while (direction == 1 and pos < goal) or (direction == -1 and pos > goal) do
                    pos += stepSize * direction
                    if (direction == 1 and pos > goal) or (direction == -1 and pos < goal) then
                        pos = goal
                    end
                    callback(pos)
                    task.wait(delayTime)
                end
            end

            local function moveXZ(startX, goalX, startZ, goalZ, callback)
                local totalDistance = math.sqrt((goalX - startX)^2 + (goalZ - startZ)^2)
                local steps = math.ceil(totalDistance / stepSize)
            
                for i = 1, steps do
                    local t = i / steps
                    local newX = startX + (goalX - startX) * t
                    local newZ = startZ + (goalZ - startZ) * t
                    callback(newX, newZ)
                    task.wait(delayTime)
                end
            
                -- Sicherstellen, dass wir exakt am Ziel ankommen
                callback(goalX, goalZ)
            end
            
            
            if vehicle and vehicle:IsA("Model") and vehicle.PrimaryPart then
                local root = vehicle.PrimaryPart
                local currentPos = root.Position
                local targetPos = targetCFrame.Position
            
                -- 1. Langsam anheben auf Y + 10
                moveAxis(currentPos.Y, currentPos.Y + 100, function(y)
                    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, y, currentPos.Z)))
                end)
            
                currentPos = vehicle.PrimaryPart.Position
            
                -- 2. Langsam bewegen auf X
                --moveAxis(currentPos.X, targetPos.X, function(x)
                --    vehicle:PivotTo(CFrame.new(Vector3.new(x, currentPos.Y, currentPos.Z)))
                --    currentPos = vehicle.PrimaryPart.Position
                --end)
            
                -- 3. Langsam bewegen auf Z
                --moveAxis(currentPos.Z, targetPos.Z, function(z)
                --    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, currentPos.Y, z)))
                --   currentPos = vehicle.PrimaryPart.Position
                --end)

                moveXZ(currentPos.X, targetPos.X, currentPos.Z, targetPos.Z, function(x, z)
                    vehicle:PivotTo(CFrame.new(Vector3.new(x, currentPos.Y, z)))
                    currentPos = vehicle.PrimaryPart.Position
                end)

                currentPos = vehicle.PrimaryPart.Position

                moveAxis(currentPos.Y, targetPos.Y + 20, function(y)
                    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, y, currentPos.Z)))
                end)

                currentPos = vehicle.PrimaryPart.Position

                stepSize = 0.2
                delayTime = 0.005
            
                -- 4. Langsam absenken auf Ziel-Y
                moveAxis(currentPos.Y, targetPos.Y, function(y)
                    vehicle:PivotTo(CFrame.new(Vector3.new(currentPos.X, y, currentPos.Z)))
                end)
                

            else
                Fluent:Notify({
                    Title = "Alert!",
                    Content = "To prevent an error, the current operation was cancelled.",
                    SubContent = "Errorcode: 1", -- Optional
                    Duration = 5 -- Set to nil to make the notification not disappear
                })
            end
            INTELEPORTPROCESS = false
        end


        local TuningLevelSlider = Tabs.VehicleTab:AddSlider("Slider", {
            Title = "Tuning Level",
            Description = "Tunes EVERY aspect of your vehicle.",
            Default = TUNINGLEVEL,
            Min = 1,
            Max = 6,
            Rounding = 1,
            Callback = function(Value)
                --print("Slider was changed:", Value)
            end
        })

        TuningLevelSlider:OnChanged(function(Value)
            TUNINGLEVEL = Value
        end)

        local player = game.Players.LocalPlayer
        local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false



        local CustomLicensePlateInput = Tabs.VehicleTab:AddInput("Custom Licenseplate", {
            Title = "Custom Licenseplate",
            Default = vehicle.Body.LicensePlates.Back.Gui.TextLabel.Text,
            Placeholder = "To change the front one, get a lifetime key.",
            Numeric = false, -- Only allows numbers
            Finished = true, -- Only calls callback when you press enter
            Callback = function(Value)
                LICENSEPLATE = Value

            end
        })

        local GodCarToggle = Tabs.VehicleTab:AddToggle("GodCarToggle", {Title = "Godcar", Default = false })

        GodCarToggle:OnChanged(function()
            GODCAR = Options.GodCarToggle.Value
        end)

        local function teleportToDealer()
            -- Find the nearest Dealer model in workspace.Dealers
            local closestDealerPart = nil
            local minDistance = math.huge  -- Start with an infinitely large number to find the closest dealer
        
            -- Loop through each model in the Dealers folder
            for _, model in pairs(workspace.Dealers:GetChildren()) do
                if model:IsA("Model") then
                    local dealerPart = model:FindFirstChild("Right Arm")
                    if dealerPart and dealerPart:IsA("BasePart") then
                        -- Calculate the distance between the player's HumanoidRootPart and the dealer part
                        local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - dealerPart.Position).Magnitude
                        if distance < minDistance then
                            minDistance = distance
                            closestDealerPart = dealerPart
                        end
                    end
                end
            end
        
            -- If we found a valid Dealer part, return its position (Vector3)
            if closestDealerPart then
                return closestDealerPart.Position
            else
                -- If no Dealer part was found, notify the user and return nil
                Fluent:Notify({
                    Title = "No Dealer Found!",
                    Content = "Couldn't find a Dealer to teleport to.",
                    Duration = 5
                })
                return nil
            end
        end
        
        
        local function teleportToVendingMachine()
            -- Find the nearest Dealer model in workspace.Dealers
            local closestVendingPart = nil
            local minDistance = math.huge  -- Start with an infinitely large number to find the closest dealer
        
            -- Loop through each model in the Dealers folder
            for _, model in pairs(workspace.Robberies.VendingMachines:GetChildren()) do
                if model:IsA("Model") then
                    local vendingPart = model:FindFirstChild("Glass")
                    if vendingPart and vendingPart:IsA("BasePart") then
                        -- Calculate the distance between the player's HumanoidRootPart and the dealer part
                        local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - vendingPart.Position).Magnitude
                        if distance < minDistance then
                            minDistance = distance
                            closestVendingPart = vendingPart
                        end
                    end
                end
            end

        
            -- If we found a valid Dealer part, return its position (Vector3)
            if closestVendingPart then
                return closestVendingPart.Position
            else
                -- If no Dealer part was found, notify the user and return nil
                Fluent:Notify({
                    Title = "No Vending Machine Found!",
                    Content = "Couldn't find a Dealer to teleport to.",
                    Duration = 5
                })
                return nil
            end
        end

        local function teleportToVendingMachineNOTROBBED()
            local closestVendingPart = nil
            local minDistance = math.huge
            local fallbackVendingPart = nil
        
            for _, model in pairs(workspace.Robberies.VendingMachines:GetChildren()) do
                if model:IsA("Model") then
                    local glass = model:FindFirstChild("Glass")
                    if glass and glass:IsA("BasePart") then
                        if glass.Transparency < 1 then
                            local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - glass.Position).Magnitude
                            if distance < minDistance then
                                minDistance = distance
                                closestVendingPart = glass
                            end
                        elseif not fallbackVendingPart then
                            fallbackVendingPart = glass
                        end
                    end
                end
            end
        
            if closestVendingPart then
                return closestVendingPart.Position
            elseif fallbackVendingPart then
                Fluent:Notify({
                    Title = "Information",
                    Content = "No vending machine within 1000 Studs was not robbed. You will be teleportet to a random one!",
                    Duration = 5
                })
                return fallbackVendingPart.Position
            else
                Fluent:Notify({
                    Title = "No Vending Machine Found!",
                    Content = "Couldn't find a valid Vending Machine to teleport to.",
                    Duration = 5
                })
                return nil
            end
        end
        
        
        

        local TeleportLocationDropdown = Tabs.Main:AddDropdown("Teleport", {
            Title = "Teleport Locations",
            Values = {"Bank", "Jeweler","Club", "Gas n Go", "Ares", "Toolshop", "Farming Shop", "Osso", "Clothing Store","Harbor","Cargo Ship", "Police Station", "Fire Department", "Bus Company", "Tuning Garage", "ADAC", "Prison", "Car Dealership", "Hospital","Safezone", "Nearest Dealer","Nearest Vending Machine"},
            Multi = false,
            Default = 1,
        })

        local function calculateTeleportPosition()
            if teleportToLocation == "Bank" then
                teleportTo(Vector3.new(-1148, 2.75000191, 3210.625, 0, 0, 1, 0, 1, 0, -1, 0, 0))
            elseif teleportToLocation == "Fire Department" then
                teleportTo(Vector3.new(-970.25, 2.75, 3891.875, 0, 0, 1, 0, 1, -0, -1, 0, 0))
            elseif teleportToLocation == "Jeweler" then
                teleportTo(Vector3.new(-345, 2.25, 3539.25, 1, 0, 0, 0, 1, 0, 0, 0, 1))
            elseif teleportToLocation == "Police Station" then
                teleportTo(Vector3.new(-1655.75, 2.25, 2742.68799, -1, 0, 0, 0, 1, 0, 0, 0, -1))
            elseif teleportToLocation == "Harbor" then
                teleportTo(Vector3.new(584.250244, 2.12501335, 1705.625, 0, 0, 1, 0, 1, -0, -1, 0, 0))
            elseif teleportToLocation == "Bus Company" then
                teleportTo(Vector3.new(-1681.0625, 2.1249907, -1313.05396, 0, 0, -1, 0, 1, 0, 1, 0, 0))
            elseif teleportToLocation == "Tuning Garage" then
                teleportTo(Vector3.new(-1346.68811, 2.12501311, 136.750519, 1, 0, 0, 0, 1, 0, 0, 0, 1))
            elseif teleportToLocation == "ADAC" then
                teleportTo(Vector3.new(-325.4375, 2.125, 538, 0, 0, -1, 0, 1, 0, 1, 0, 0))
            elseif teleportToLocation == "Prison" then
                teleportTo(Vector3.new(-567.000488, 2.25496864, 2849.62549, 0, 0, -1, 0, 1, 0, 1, 0, 0))
            elseif teleportToLocation == "Car Dealership" then
                teleportTo(Vector3.new(-1431.75, 2.125, 915.324951, 1, 0, 0, 0, 1, 0, 0, 0, 1))
            elseif teleportToLocation == "Gas n Go" then
                teleportTo(Vector3.new(-1543.74829, 2.125, 3839.92505, -1, 0, 0, 0, 1, 0, 0, 0, -1))
            elseif teleportToLocation == "Ares" then
                teleportTo(Vector3.new(-871.75, 2.125, 1475.32495, 1, 0, 0, 0, 1, 0, 0, 0, 1))
            elseif teleportToLocation == "Toolshop" then
                teleportTo(Vector3.new(-740.5, 2.125, 708.770508, 1, 0, 0, 0, 1, 0, 0, 0, 1))
            elseif teleportToLocation == "Farming Shop" then
                teleportTo(Vector3.new(-857.5, 2.609375, -1142, 0, 0, 1, 0, 1, -0, -1, 0, 0))
            elseif teleportToLocation == "Osso" then
                teleportTo(Vector3.new(2.65355635, 2.125, -758.369995, 0, 0, -1, 0, 1, 0, 1, 0, 0))
            elseif teleportToLocation == "Clothing Store" then
                teleportTo(Vector3.new(495.0625, 2.109375, -1444.9375, 1, 0, 0, 0, 1, 0, 0, 0, 1))
            elseif teleportToLocation == "Cargo Ship" then
                teleportTo(Vector3.new(1032.25, 2.12499976, 2265.625, -1, 0, 0, 0, 1, 0, 0, 0, -1))
            elseif teleportToLocation == "Hospital" then
                teleportTo(Vector3.new(-257.628998, 2.75, 1184.06995, 1, 0, 0, 0, 1, 0, 0, 0, 1))
            elseif teleportToLocation == "Safezone" then
                teleportTo(Vector3.new(714.722168, 96.8313751, -645.928528, 0.967532575, -0.0304376129, 0.250906914, 0, 0.992722154, 0.120427497, -0.252746373, -0.116517529, 0.960491002))
            elseif teleportToLocation == "Club" then
                teleportTo(Vector3.new(-1818.875, 2.75000191, 3217.625, 1, 0, 0, 0, 1, 0, 0, 0, 1))
            elseif teleportToLocation == "Nearest Dealer" then
                local dealerCFrame = teleportToDealer()
                if dealerCFrame then
                    teleportTo(dealerCFrame)  -- Assuming your `teleportTo` function can handle a CFrame
                end
            elseif teleportToLocation == "Nearest Vending Machine" then
                if onlyunrobbedvendingmachines then
                    local vendingCFrame = teleportToVendingMachineNOTROBBED()
                    if vendingCFrame then
                        teleportTo(vendingCFrame)  -- Assuming your `teleportTo` function can handle a CFrame
                    end
                else
                    local vendingCFrame = teleportToVendingMachine()
                    if vendingCFrame then
                        teleportTo(vendingCFrame)  -- Assuming your `teleportTo` function can handle a CFrame
                    end
                end
            end
        end

        Tabs.Main:AddButton({
            Title = "Teleport now!",
            Description = "Teleports you to the selected location.",
            Callback = function()
                if autoseattoggle then
                    calculateTeleportPosition()
                else
                    Window:Dialog({
                        Title = "WARNING:",
                        Content = "Please sit in the vehicle before teleporting.",
                        Buttons = {
                            {
                                Title = "Confirm",
                                Callback = function()
                                    task.spawn(function()
                                    calculateTeleportPosition()
                                    end)
                                end
                            },
                            {
                                Title = "Cancel",
                                Callback = function()
                                    --print("Cancelled the dialog.")
                                end
                            }
                        }
                    })
                end
            end
        })

        Tabs.Main:AddButton({
            Title = "Teleport to nearest Dealer",
            Description = "Looks up the nearest dealer and teleports you to him.",
            Callback = function()
                local dealerCFrame = teleportToDealer()
                if dealerCFrame then
                    teleportTo(dealerCFrame)
                end
            end
        })
        Tabs.Main:AddButton({
            Title = "Teleport to nearest Vending Machine",
            Description = "Looks up the nearest vending machine and teleports you to it.",
            Callback = function()
                if onlyunrobbedvendingmachines then
                    local vendingCFrame = teleportToVendingMachineNOTROBBED()
                    if vendingCFrame then
                        teleportTo(vendingCFrame)  -- Assuming your `teleportTo` function can handle a CFrame
                    end
                else
                    local vendingCFrame = teleportToVendingMachine()
                    if vendingCFrame then
                        teleportTo(vendingCFrame)  -- Assuming your `teleportTo` function can handle a CFrame
                    end
                end
            end
        })

        local unrobbedVending = Tabs.Main:AddToggle("unrobbedvending", {Title = "Only unrobbed Vending Machines", Default = false })

        unrobbedVending:OnChanged(function()
            onlyunrobbedvendingmachines = Options.unrobbedvending.Value
        end)


        local predictionToggleAimbot = Tabs.AimbotTab:AddToggle("predictionAIMBOT", {Title = "Use Movement Prediction", Default = false })

        predictionToggleAimbot:OnChanged(function()
            if Options.predictionAIMBOT.Value then
                local aim_config = _G.JALON_AIMCONFIG or {
                    Enabled = true,
                    KeyActivation = Enum.UserInputType.MouseButton2, -- RightClick
                    CloseKey = Enum.KeyCode.L, -- Close with "L"
                    
                    FOV = 175,
                    TeamCheck = false, -- TeamCheck deaktiviert
                    DistanceCheck = true,
                    VisibleCheck = true,
            
                    Smoothness = 0.975,
                    Prediction = {
                        Enabled = true,
                        Value = 0.185
                    }
                }
            else
                local aim_config = _G.JALON_AIMCONFIG or {
                    Enabled = true,
                    KeyActivation = Enum.UserInputType.MouseButton2, -- RightClick
                    CloseKey = Enum.KeyCode.L, -- Close with "L"
                    
                    FOV = 175,
                    TeamCheck = false, -- TeamCheck deaktiviert
                    DistanceCheck = true,
                    VisibleCheck = true,
            
                    Smoothness = 0.975,
                    Prediction = {
                        Enabled = false,
                        Value = 0.185
                    }
                }
            end
        end)


    -- DISABLED DUE TO ANTICHEAT

    
    

        local TPinCarToggle = Tabs.Main:AddToggle("vehicletptoggle", {Title = "Auto TP to Vehicle", Default = false })

        TPinCarToggle:OnChanged(function()
            autoseattoggle = Options.vehicletptoggle.Value
        end)

        TeleportLocationDropdown:OnChanged(function(Value)
            teleportToLocation = Value
        end)

        
        local AutoTPondying = Tabs.Practical:AddToggle("autosaveplayer", {Title = "Teleport when low health", Default = false })

        AutoTPondying:OnChanged(function()
            savemybutt = Options.autosaveplayer.Value
        end)

        local antiTasterToggle = Tabs.Practical:AddToggle("antitaser", {Title = "Anti Taser", Default = false })

        antiTasterToggle:OnChanged(function()
            antitaser = Options.antitaser.Value
        end)


        local bankstatusVIEWtoggle = Tabs.Main:AddToggle("bankstats", {Title = "Bank Status (read only): ", Default = false })


        Options.bankstats:SetValue(false)

        local AntiCopRadarToggle = Tabs.VehicleTab:AddToggle("coprader", {Title = "Break on nearby Cop Radar", Default = false })

        AntiCopRadarToggle:OnChanged(function()
            anticopradar = Options.coprader.Value
        end)

        local AntiNormRadarToggle = Tabs.VehicleTab:AddToggle("normradar", {Title = "Break on nearby Speed Camera", Default = false })

        AntiNormRadarToggle:OnChanged(function()
            antinormradar = Options.normradar.Value
        end)




        -- ERRORCODE MEANINGS:
        -- 1 = BusStops folder not found in workspace
        -- 2 = City Bus Driver folder not found or is not a Folder
        -- 3 = No matching Part found for City Bus Driver
        -- 4 = Found CFrame is nil

        local positions = {
            "-535.75, 2.87497735, 831.875244, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "109.625031, 2.87497735, 1593.37524, -1, 0, 0, 0, 1, 0, 0, 0, -1",
            "-1207.75, 2.87497735, 3247.00024, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "-1767.75, 2.87497735, 3247.00024, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "-1543.75, 2.87497735, 3967.87524, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "-983.75, 2.87497735, 3967.87524, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "-289.499969, 2.87497735, 3609.25024, -1, 0, 0, 0, 1, 0, 0, 0, -1",
            "-983.75, 2.87497735, 3923.37524, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "-1543.75, 2.87497735, 3923.37524, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "-1767.75, 2.87497735, 3300.25024, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "-1207.75, 2.87497735, 3300.25024, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "162.875031, 2.87497735, 1593.37524, -1, 0, 0, 0, 1, 0, 0, 0, -1",
            "-535.75, 2.87497735, 787.375244, 0, 0, 1, 0, 1, -0, -1, 0, 0",
            "-1431.75, 2.87497735, 787.375244, 0, 0, 1, 0, 1, -0, -1, 0, 0"
        }




        -- FUNCTIONS USED IN WHILE LOOP

        local function isNearSpeedCamera()
            speedCamerasMobile = workspace.SpeedCameras:WaitForChild("Mobile")
            speedCamerasStationary = workspace.SpeedCameras:WaitForChild("Stationary")
            local playerPosition = player.Character and player.Character.HumanoidRootPart.Position
            if not playerPosition then return false end
            
            -- Check models in Mobile folder
            for _, camera in ipairs(speedCamerasMobile:GetChildren()) do
                if camera:IsA("Model") and (camera.PrimaryPart) then
                    local distance = (camera.PrimaryPart.Position - playerPosition).Magnitude
                    if distance <= 200 then
                        return true
                    end
                end
            end
            
            -- Check models in Stationary folder
            for _, camera in ipairs(speedCamerasStationary:GetChildren()) do
                if camera:IsA("Model") and (camera.PrimaryPart) then
                    local distance = (camera.PrimaryPart.Position - playerPosition).Magnitude
                    if distance <= 200 then
                        return true
                    end
                end
            end
            
            return false
        end

        local function playerLowHealthMove(health)
            hasTriggeredemergencyMove = true
            Fluent:Notify({
                Title = "Alert!",
                Content = "Due to low health, you will be teleported to the hospital.",
                SubContent = "Your health: "..health, -- Optional
                Duration = 15 -- Set to nil to make the notification not disappear
            })
            autoseattoggle = false
            local player = game.Players.LocalPlayer
            local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false

            if vehicle then
                local seat = vehicle:WaitForChild("DriveSeat")
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    seat:Sit(player.Character.Humanoid)
                end
                wait(0.5)
                teleportTo(Vector3.new(-257.628998, 2.75, 1184.06995, 1, 0, 0, 0, 1, 0, 0, 0, 1))
                wait(0.5)
                autoseattoggle = true
            end
        end



        RunService.RenderStepped:Connect(function(dt)
            local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false
            if not vehicle or not vehicle.PrimaryPart then return end
            if CARFLY then
                
                setAnchored(true)
            
                local camCF = Workspace.CurrentCamera.CFrame
                local position = vehicle.PrimaryPart.Position
                local lookDirection = camCF.LookVector
            
                -- Always face the camera direction
                local targetPosition = position
                local moveDir =
                    (camCF.LookVector * inputDirection.Z) +
                    (camCF.RightVector * inputDirection.X) +
                    (Vector3.new(0, 1, 0) * inputDirection.Y)
            
                if moveDir.Magnitude > 0 then
                    targetPosition += moveDir.Unit * CARFLYspeed
                end
            
                vehicle:SetPrimaryPartCFrame(CFrame.new(targetPosition, targetPosition + lookDirection))
                CARFLYteleportetoSeat = false
            else
                
                for part, _ in pairs(anchoredParts) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                    end
                end
                anchoredParts = {}
                inputDirection = Vector3.new(0, 0, 0)

                if CARFLYteleportetoSeat == false then
                    CARFLYunflyTeleportLoopInit = CARFLYunflyTeleportLoopInit + 1
                    if CARFLYunflyTeleportLoopInit > 1000 then
                        CARFLYteleportetoSeat = true
                        CARFLYunflyTeleportLoopInit = 0
                    end
                    
                    local seat = vehicle:FindFirstChild("Seat")
                    if seat and seat.Occupant then
                        local occupant = seat.Occupant
                        if occupant and occupant.Parent == player.Character then
                            seat.Occupant = occupant
                        end
                    end
                end

            end
        end)




        -- Addons:
        -- SaveManager (Allows you to have a configuration system)
        -- InterfaceManager (Allows you to have a interface managment system)

        -- Hand the library over to our managers
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)

        -- Ignore keys that are used by ThemeManager.
        -- (we dont want configs to save themes, do we?)
        SaveManager:IgnoreThemeSettings()

        -- You can add indexes of elements the save manager should ignore
        SaveManager:SetIgnoreIndexes({})

        -- use case for doing it this way:
        -- a script hub could have themes in a global foldersa
        -- and game configs in a separate folder per game
        InterfaceManager:SetFolder("FluentScriptHub")
        SaveManager:SetFolder("FluentScriptHub/specific-game")

        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)


        Window:SelectTab(1)


        -- You can use the SaveManager:LoadAutoloadConfig() to load a config
        -- which has been marked to be one that auto loads!
        SaveManager:LoadAutoloadConfig()


        -- WHILE TRUEE LOOP 

        while SCRIPTRUNNING do
            local player = game.Players.LocalPlayer
            local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false -- Debugging line to check if vehicle is found
            wait(0.05)
            if vehicle then

                if GODCAR then
                    local player = game.Players.LocalPlayer
                    local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false

                    if vehicle then
                        vehicle:SetAttribute("armorLevel", 6)
                        vehicle:SetAttribute("brakesLevel", 6)
                        vehicle:SetAttribute("engineLevel", 6)
                        vehicle:SetAttribute("currentFuel", 10000000)
                        vehicle:SetAttribute("currentHealth", 500)
                        vehicle:SetAttribute("IsOn", true)
                    end
                else
                    local player = game.Players.LocalPlayer
                    local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false

                    if vehicle then
                    vehicle:SetAttribute("armorLevel", TUNINGLEVEL)
                    vehicle:SetAttribute("brakesLevel", TUNINGLEVEL)
                    vehicle:SetAttribute("engineLevel", TUNINGLEVEL)
                    end
                end


                whileloopcounter1 = whileloopcounter1 + 1
            
                

                if lifetimekey then
                    local player = game.Players.LocalPlayer
                    local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false

                    if vehicle then
                        vehicle.Body.LicensePlates.Back.Gui.TextLabel.Text = LICENSEPLATE
                        vehicle.Body.LicensePlates.Front.Gui.TextLabel.Text = LICENSEPLATE
                    end
                else
                    
                    local player = game.Players.LocalPlayer
                    local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false

                    if vehicle then
                        vehicle.Body.LicensePlates.Front.Gui.TextLabel.Text = "Letsnet"
                        vehicle.Body.LicensePlates.Front.Decal.Color3 = Color3.fromRGB(126, 147, 255)
                        vehicle.Body.LicensePlates.Back.Gui.TextLabel.Text = LICENSEPLATE
                    end

                end
                
                


                if anticopradar then
                    local Players = game:GetService("Players")
                    local player = Players.LocalPlayer
                    local character = player and player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local seatPart = humanoid and humanoid.SeatPart
                
                    if character and humanoid and seatPart then
                        local playerHRP = character:FindFirstChild("HumanoidRootPart")
                        local isBeingWatched = false
                
                        for _, otherPlayer in ipairs(Players:GetPlayers()) do
                            if otherPlayer ~= player then
                                local otherChar = otherPlayer.Character
                                local radar = otherChar and otherChar:FindFirstChild("Radar Gun")
                                local otherHRP = otherChar and otherChar:FindFirstChild("HumanoidRootPart")
                
                                if radar and otherHRP and playerHRP then
                                    local directionToPlayer = (playerHRP.Position - otherHRP.Position).Unit
                                    local otherLookVector = otherHRP.CFrame.LookVector
                                    local dot = directionToPlayer:Dot(otherLookVector)
                
                                    local distance = (otherHRP.Position - playerHRP.Position).Magnitude
                                    if distance <= 500 and dot > 0.7 then -- dot > 0.7 ≈ innerhalb eines Sichtkegels von ~45°
                                        isBeingWatched = true
                                        break
                                    end
                                end
                            end
                        end
                
                        if isBeingWatched then
                                local speed = seatPart.Velocity.Magnitude
                                local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false

                                if vehicle then
                                    if vehicle:GetAttribute("ParkingBrake") == false then
                                        Fluent:Notify({
                                            Title = "Alert!",
                                            Content = "A cop near you that is holding a Radar Gun, is facing your direction!",
                                            SubContent = "Disable -Break on nearby Cop Radar- to continue driving!", -- Optional
                                            Duration = 15 -- Set to nil to make the notification not disappear
                                        })
                                    end
                                    vehicle:SetAttribute("ParkingBrake", true)
                                end
                    end end
                end


                if player.Character and player.Character.HumanoidRootPart then
                    local playerPosition = player.Character.HumanoidRootPart.Position
                    --print("Player Position:", playerPosition)  -- Debugging line to check player's position
                
                    local nearSpeedCamera = false
                    local vehicleSpeed = 0  -- Variable to hold the car's speed
                
                    -- Check Mobile Cameras
                    for _, camera in ipairs(workspace.SpeedCameras.Mobile:GetChildren()) do
                        if camera:IsA("Model") then
                            -- Look for the part inside the camera model, e.g., "SpeedCamera"
                            local speedCameraPart = camera:FindFirstChild("SpeedCamera")  -- Replace with actual part name if needed
                            if speedCameraPart then
                                local cameraPosition = speedCameraPart.Position
                                --print("Mobile Camera Position:", cameraPosition)  -- Debugging line to check camera's position
                
                                local distance = (cameraPosition - playerPosition).Magnitude
                            -- print("Distance to Camera:", distance)  -- Debugging line to check distance
                
                                if distance <= 100 then
                                    nearSpeedCamera = true
                                --    print("Near Mobile Camera!")  -- Debugging line to confirm proximity
                                    break
                                end
                            end
                        end
                    end
                
                    -- Check Stationary Cameras if not already near a mobile camera
                    if not nearSpeedCamera then
                        for _, camera in ipairs(workspace.SpeedCameras.Stationary:GetChildren()) do
                            if camera:IsA("Model") then
                                -- Check all the SpeedCamera children within the stationary camera model
                                for _, part in ipairs(camera:GetChildren()) do
                                    if part.Name == "SpeedCamera" and part:IsA("Part") then
                                        local cameraPosition = part.Position
                                        --print("Stationary Camera Part Position:", cameraPosition)  -- Debugging line to check part's position
                
                                        local distance = (cameraPosition - playerPosition).Magnitude
                                        --print("Distance to Camera Part:", distance)  -- Debugging line to check distance
                
                                        if distance <= 50 then
                                            nearSpeedCamera = true
                                            --print("Near Stationary Camera!")  -- Debugging line to confirm proximity
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                
                    -- If player is near a camera
                    if nearSpeedCamera then
                        local player = game.Players.LocalPlayer
                        local team = player.Team

                        if team and team.Name == "Police" then
                            --print("Player is a cop, not applying speed limit.")
                        else
                            if antinormradar then
                                local vehicle = workspace.Vehicles:FindFirstChild(player.Name) or false
                                if vehicle then
                                    local primaryPart = vehicle.PrimaryPart  -- Assuming vehicle has a PrimaryPart
                                    if primaryPart then
                                        -- Get the velocity of the car's primary part
                                        local velocity = primaryPart.Velocity  -- Velocity is a Vector3 representing movement in 3D space
                                        vehicleSpeed = velocity.Magnitude  -- Get the speed in studs per second
                                        --print("Vehicle Speed:", vehicleSpeed)
                    
                                        if vehicle:GetAttribute("ParkingBrake") == false then
                                            Fluent:Notify({
                                                Title = "Alert!",
                                                Content = "You were speeding near a speed camera!",
                                                SubContent = "Disable -Break on nearby Speed Camera- to continue driving!", -- Optional
                                                Duration = 15 -- Set to nil to make the notification not disappear
                                            })
                                        end
                    
                                        vehicle:SetAttribute("ParkingBrake", true)
                                    else
                                        --print("No PrimaryPart found for the vehicle.")
                                    end
                                end
                            end
                        end
                    end
                end
                

                
                
                
            


                if antitaser then
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local team = player.Team

                    if team and team.Name == "Police" then
                        --print("Player is a cop, not applying anti-taser.")
                    else

                        if character:GetAttribute("Tased") == true then
                            character:SetAttribute("Tased", false)
                            Fluent:Notify({
                                Title = "Alert!",
                                Content = "You were tased, but we got you out of it!",
                                SubContent = "RUN AWAY!", -- Optional
                                Duration = 5 -- Set to nil to make the notification not disappear
                            })
                        end
                    end
                end
                


                local lightBANK = game.Workspace:FindFirstChild("Robberies") 
                        and game.Workspace.Robberies:FindFirstChild("BankRobbery")
                        and game.Workspace.Robberies.BankRobbery:FindFirstChild("LightGreen")
                        and game.Workspace.Robberies.BankRobbery.LightGreen:FindFirstChild("Light")

                if lightBANK then
                    if lightBANK.Enabled then
                        if lastlightbank == false then
                            if SENDNOTIFICTIONS then
                            Fluent:Notify({
                                Title = "Notify",
                                Content = "The bank is ready to rob!",
                                SubContent = "", -- Optional
                                Duration = 5 -- Set to nil to make the notification not disappear
                            })
                        end
                        end
                        Options.bankstats:SetValue(true)
                        lastlightbank = true
                    else
                    if SENDNOTIFICTIONS then
                        if lastlightbank then
                            Fluent:Notify({
                                Title = "Notify",
                                Content = "The bank is not ready for robbery!",
                                SubContent = "", -- Optional
                                Duration = 5 -- Set to nil to make the notification not disappear
                            })
                        end
                    end
                        Options.bankstats:SetValue(false)
                        lastlightbank = false
                    end
                else
                    
                end

                local humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")

                if humanoid.Health < 50 then
                    if savemybutt then
                    playerLowHealthMove(humanoid.Health)
                    end
                else
                    hasTriggeredemergencyMove = false
                end

                if PLAYERESP_main then
                        _G.espMarkers = _G.espMarkers or {}

                        -- Clear old ESP drawings
                        for _, marker in pairs(_G.espMarkers) do
                            for _, item in pairs(marker) do
                                if typeof(item) == "Instance" and item:IsA("Highlight") then
                                    item:Destroy()
                                elseif typeof(item) == "table" and item.Remove then
                                    item:Remove()
                                end
                            end
                        end
                        table.clear(_G.espMarkers)

                        -- Draw ESP for each valid player
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local hrp = player.Character.HumanoidRootPart
                                local distance = (hrp.Position - Camera.CFrame.Position).Magnitude

                                if distance <= 1000 then
                                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                                    if onScreen then
                                        local marker = {}

                                        -- Box
                                        if PLAYERESP_box then
                                            local box = Drawing.new("Square")
                                            box.Size = Vector2.new(50, 100)
                                            box.Position = Vector2.new(screenPos.X - 25, screenPos.Y - 50)
                                            box.Color = Color3.new(1, 1, 1)
                                            box.Thickness = 1
                                            box.Filled = false
                                            box.Visible = true
                                            marker.box = box
                                        end

                                        -- Highlight + tracer
                                        if PLAYERESP_highlight then
                                            local hl = Instance.new("Highlight")
                                            hl.Adornee = player.Character
                                            hl.FillTransparency = 1
                                            hl.OutlineColor = Color3.new(1, 1, 0)
                                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                            hl.Parent = player.Character
                                            marker.highlight = hl

                                            local tracer = Drawing.new("Line")
                                            tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                                            tracer.Color = Color3.new(1, 1, 0)
                                            tracer.Thickness = 1
                                            tracer.Visible = true
                                            marker.tracer = tracer
                                        end

                                        -- Name (with team name included)
                                        if PLAYERESP_name then
                                            local teamName = player.Team and player.Team.Name or "Neutral"
                                            local nameText = Drawing.new("Text")
                                            nameText.Text = string.format("%s [%s]", player.Name, teamName)
                                            nameText.Position = Vector2.new(screenPos.X, screenPos.Y - 60)
                                            nameText.Color = Color3.new(1, 1, 1)
                                            nameText.Size = 13
                                            nameText.Center = true
                                            nameText.Outline = true
                                            nameText.Visible = true
                                            marker.name = nameText
                                        end

                                        -- Distance
                                        if PLAYERESP_distance then
                                            local distText = Drawing.new("Text")
                                            distText.Text = string.format("%.0f studs", distance)
                                            distText.Position = Vector2.new(screenPos.X, screenPos.Y + 60)
                                            distText.Color = Color3.new(0, 1, 0)
                                            distText.Size = 12
                                            distText.Center = true
                                            distText.Outline = true
                                            distText.Visible = true
                                            marker.distance = distText
                                        end

                                        -- Team (separate line)
                                        if PLAYERESP_team then
                                            local teamText = Drawing.new("Text")
                                            local teamName = player.Team and player.Team.Name or "Neutral"
                                            teamText.Text = teamName
                                            teamText.Position = Vector2.new(screenPos.X, screenPos.Y + 75)
                                            teamText.Color = Color3.new(0, 0.5, 1)
                                            teamText.Size = 12
                                            teamText.Center = true
                                            teamText.Outline = true
                                            teamText.Visible = true
                                            marker.team = teamText
                                        end

                                        -- Healthbar
                                        if PLAYERESP_healthbar and player.Character:FindFirstChild("Humanoid") then
                                            local hp = player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth
                                            local bar = Drawing.new("Line")
                                            bar.From = Vector2.new(screenPos.X - 30, screenPos.Y + 50)
                                            bar.To = Vector2.new(screenPos.X - 30, screenPos.Y + 50 - (hp * 100))
                                            bar.Color = Color3.fromRGB(0, 255, 0)
                                            bar.Thickness = 2
                                            bar.Visible = true
                                            marker.healthbar = bar
                                        end

                                        table.insert(_G.espMarkers, marker)
                                    end
                                end
                            end
                        end
                end

                if SCRIPTRUNNING == false then
                    _G.espMarkers = _G.espMarkers or {}

                    -- Clear old ESP drawings
                    for _, marker in pairs(_G.espMarkers) do
                        for _, item in pairs(marker) do
                            if typeof(item) == "Instance" and item:IsA("Highlight") then
                                item:Destroy()
                            elseif typeof(item) == "table" and item.Remove then
                                item:Remove()
                            end
                        end
                    end
                    table.clear(_G.espMarkers)
                end


                local function deleteDoors(parent)
                    for _, obj in pairs(parent:GetChildren()) do
                        if obj:IsA("Model") then
                            if obj.Name == "SlidingDoor" or obj.Name == "MetalDoor" or obj.Name == "GlassDoor" then
                                obj:Destroy()
                                task.wait() -- short pause to avoid lag
                            else
                                deleteDoors(obj)
                            end
                        elseif obj:IsA("Folder") then
                            deleteDoors(obj)
                        end
                    end
                end
                if deletealldoors and whileloopcounter1 == 2000 then
                    whileloopcounter1 = 0
                    task.spawn(function()
                        deleteDoors(workspace)
                    end)
                end
                if garagedoorpermanentopen then
                    for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                        if model:IsA("Model") and model.Name == "GarageDoor" then
                            model:SetAttribute("IsTriggered", false)
                            model:SetAttribute("IsTriggered", true)
                            model:SetAttribute("OpenForCitizen", true)
                            model:SetAttribute("OpenForPlayers", true)
                            model:SetAttribute("OpeningDuration", 0)
                        end
                    end
                    for _, model in pairs(workspace.GarageDoors:GetChildren()) do
                        if model:IsA("Model") and model.Name == "Bollards" then
                            model:SetAttribute("IsTriggered", false)
                            model:SetAttribute("IsTriggered", true)
                            model:SetAttribute("OpenForCitizen", true)
                            model:SetAttribute("OpenForPlayers", true)
                            model:SetAttribute("OpeningDuration", 0)
                        end
                    end
                    for _, model in pairs(workspace.Gates:GetChildren()) do
                        if model:IsA("Model") and model.Name == "Gate" then
                            model:SetAttribute("IsTriggered", false)
                            model:SetAttribute("IsTriggered", true)
                            model:SetAttribute("OpeningDuration", 0)
                        end
                    end
                end
            end

        end
    end



end




local function debug_print(...)
    if DEBUG then
        warn("[LetsNet Debug]", ...)
    end
end

-- Vereinfachter und robuster Loader
local function runWithErrorHandling(callback)
    local success, result = pcall(callback)
    if not success then
        debug_print("Fehler in runWithErrorHandling:", result)
        return false
    end
    return true, result
end

local api = {}

function api.get_hwid()
    local hwid = ""
    
    runWithErrorHandling(function()
        if game:GetService("RbxAnalyticsService") then
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
            debug_print("HWID von RbxAnalyticsService:", hwid)
        else
            hwid = game:GetService("HttpService"):GenerateGUID(false)
            debug_print("HWID von HttpService:", hwid)
        end
    end)
    
    if hwid == "" then
        hwid = tostring(math.random(10000000, 99999999))
        debug_print("Fallback HWID generiert:", hwid)
    end
    
    return hwid
end

function api.get_ip()
    local ip = "0.0.0.0"
    
    runWithErrorHandling(function()
        local success, result = pcall(function()
            local response
            debug_print("Versuche IP-Adresse abzurufen...")
            
            if syn and syn.request then
                debug_print("Verwende syn.request")
                response = syn.request({
                    Url = "https://api.ipify.org",
                    Method = "GET"
                })
                ip = response.Body
            elseif http and http.request then
                debug_print("Verwende http.request")
                response = http.request({
                    Url = "https://api.ipify.org",
                    Method = "GET"
                })
                ip = response.Body
            elseif request then
                debug_print("Verwende request")
                response = request({
                    Url = "https://api.ipify.org",
                    Method = "GET"
                })
                ip = response.Body
            else
                debug_print("Verwende game:HttpGet")
                ip = game:HttpGet("https://api.ipify.org")
            end
            
            debug_print("IP-Adresse erfolgreich abgerufen:", ip)
        end)
    end)
    
    return ip
end

local function save_key(key_data)
    local success, result = pcall(function()
        local HttpService = game:GetService("HttpService")
        local key_file = {
            key = key_data.key,
            hwid = key_data.hwid,
            expires = key_data.expires,
            timestamp = os.time()
        }
        
        -- Speichere im Workspace
        local key_folder = workspace:FindFirstChild("LetsNetKeys")
        if not key_folder then
            key_folder = Instance.new("Folder")
            key_folder.Name = "LetsNetKeys"
            key_folder.Parent = workspace
        end
        
        local key_value = Instance.new("StringValue")
        key_value.Name = "KeyData"
        key_value.Value = HttpService:JSONEncode(key_file)
        key_value.Parent = key_folder
    end)
    return success
end

local function load_saved_key()
    local success, result = pcall(function()
        local key_folder = workspace:FindFirstChild("LetsNetKeys")
        if key_folder then
            local key_value = key_folder:FindFirstChild("KeyData")
            if key_value then
                local HttpService = game:GetService("HttpService")
                local key_data = HttpService:JSONDecode(key_value.Value)
                
                if key_data.expires and key_data.expires > os.time() then
                    return key_data
                else
                    key_value:Destroy()
                end
            end
        end
        return nil
    end)
    
    if success and result then
        return result
    end
    return nil
end

function api.check_key(key)
    if not key then 
        debug_print("Kein Key angegeben")
        return {success = false, message = "Kein Key angegeben"} 
    end
    
    local hwid = api.get_hwid()
    local ip = api.get_ip()
    debug_print("Key-Überprüfung gestartet:", {
        key = key,
        hwid = hwid,
        ip = ip
    })
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local client_info = {
        account_name = LocalPlayer.Name,
        account_id = LocalPlayer.UserId,
        job_id = game.JobId,
        place_id = game.PlaceId,
        game_name = game.Name,
        executor = identifyexecutor and identifyexecutor() or "Unknown"
    }
    
    debug_print("Client-Informationen:", client_info)
    
    local success, result = runWithErrorHandling(function()
        local requestFunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
        
        if not requestFunc then
            debug_print("Keine HTTP-Request-Funktion verfügbar")
            return {success = false, message = "HTTP Requests werden nicht unterstützt"}
        end
        
        local requestData = {
            key = key,
            hwid = hwid,
            ip = ip,
            game_id = game.PlaceId,
            player_id = LocalPlayer.UserId,
            executor = client_info.executor,
            client_info = client_info
        }
        
        debug_print("Sende Validierungsanfrage:", requestData)
        
        local response = requestFunc({
            Url = "https://letsnet.vercel.app/api/validate",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-API-Key"] = "fd35e70a9d6b8c00d20e99e9020d163697b357e8d2fd6a6a372cbbef447c0c28"
            },
            Body = HttpService:JSONEncode(requestData)
        })
        
        debug_print("Server-Antwort erhalten:", {
            status = response.StatusCode,
            body = response.Body
        })
        
        if not response or not response.StatusCode then
            debug_print("Ungültige Serverantwort")
            return {
                success = false,
                message = "Ungültige Serverantwort",
                data = nil
            }
        end
        
        if response.StatusCode == 200 then
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)
            
            if success and decoded and decoded.success then
                debug_print("Key erfolgreich validiert:", decoded)
                
                -- Überprüfe HWID
                if decoded.data.hwid and decoded.data.hwid ~= hwid then
                    debug_print("HWID-Mismatch:", {
                        stored = decoded.data.hwid,
                        current = hwid
                    })
                    return {
                        success = false,
                        message = "Dieser Key ist an ein anderes Gerät gebunden. Bitte kontaktiere den Support für einen HWID-Reset.",
                        data = nil
                    }
                end
                
                -- Speichere HWID wenn noch keine gesetzt ist
                if not decoded.data.hwid then
                    decoded.data.hwid = hwid
                end
                
                decoded.data.key = key
                save_key(decoded.data)
            else
                debug_print("Fehler beim Dekodieren der Antwort:", decoded)
            end
            
            return decoded
        elseif response.StatusCode == 404 then
            debug_print("Key nicht gefunden")
            return {
                success = false,
                message = "Ungültiger Key",
                data = nil
            }
        elseif response.StatusCode == 403 then
            debug_print("403 Fehler - Versuche alternative Überprüfung")
            local responseBody = HttpService:JSONDecode(response.Body)
            
            local alternativeResponse = requestFunc({
                Url = "https://letsnet.vercel.app/api/validate",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["X-API-Key"] = "fd35e70a9d6b8c00d20e99e9020d163697b357e8d2fd6a6a372cbbef447c0c28"
                },
                Body = HttpService:JSONEncode({
                    key = key,
                    check_only = true
                })
            })
            
            debug_print("Alternative Überprüfung Antwort:", {
                status = alternativeResponse.StatusCode,
                body = alternativeResponse.Body
            })
            
            if alternativeResponse.StatusCode == 200 then
                local altData = HttpService:JSONDecode(alternativeResponse.Body)
                if altData.success and altData.key_exists and not altData.banned then
                    debug_print("Key existiert aber HWID-Reset erforderlich")
                    return {
                        success = false,
                        message = "Dieser Key ist an ein anderes Gerät gebunden. Bitte kontaktiere den Support für einen HWID-Reset.",
                        data = nil
                    }
                end
            end
            
            return {
                success = false, 
                message = responseBody.message or "Key ist gebunden an ein anderes Gerät oder abgelaufen", 
                data = nil
            }
        else
            debug_print("Unerwarteter Status-Code:", response.StatusCode)
            return {
                success = false,
                message = "Key konnte nicht überprüft werden: " .. (response.StatusCode or "Unbekannter Fehler"),
                data = nil
            }
        end
    end)
    
    if not success then
        debug_print("Verbindungsfehler:", result)
        return {
            success = false,
            message = "Verbindungsfehler: Key konnte nicht überprüft werden",
            data = nil
        }
    end
    
    return result
end

local function runcookedscript()
    game.CoreGui.LetsNetKeySystem:Destroy()
    startScript(false)
    INBOOTSTRAP = false
    SCRIPTRUNNING = true
end


function api.create_key_system()
    -- Einfaches UI ohne Rayfield für erhöhte Stabilität
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LetsNetKeySystem"
    screenGui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250) -- Größere Box für Discord-Text
    frame.Position = UDim2.new(0.5, -175, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = frame
    
    -- Topbar für Drag-Funktion
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 30)
    topbar.Position = UDim2.new(0, 0, 0, 0)
    topbar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    topbar.BorderSizePixel = 0
    topbar.Parent = frame
    
    local topbarCorner = Instance.new("UICorner")
    topbarCorner.CornerRadius = UDim.new(0, 10)
    topbarCorner.Parent = topbar
    
    -- Unterer Teil des Topbars zum Abschneiden der Ecken
    local topbarBottom = Instance.new("Frame")
    topbarBottom.Size = UDim2.new(1, 0, 0.5, 0)
    topbarBottom.Position = UDim2.new(0, 0, 0.5, 0)
    topbarBottom.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    topbarBottom.BorderSizePixel = 0
    topbarBottom.Parent = topbar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "LetsNet Key System"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar
    
    -- Schließen-Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✖"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = topbar
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.8, 0, 0, 30)
    inputBox.Position = UDim2.new(0.1, 0, 0.4, -15)
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    inputBox.BorderSizePixel = 0
    inputBox.PlaceholderText = "XXXXX-XXXXX-XXXXX"
    inputBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.Gotham
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = frame
    
    local inputBoxCorner = Instance.new("UICorner")
    inputBoxCorner.CornerRadius = UDim.new(0, 5)
    inputBoxCorner.Parent = inputBox
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0.55, 0)
    status.BackgroundTransparency = 1
    status.Text = "Warte auf Key..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0.6, 0, 0, 30)
    submitButton.Position = UDim2.new(0.2, 0, 0.7, 0)
    submitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Key überprüfen"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.TextSize = 14
    submitButton.Font = Enum.Font.GothamBold
    submitButton.Parent = frame
    
    local submitButtonCorner = Instance.new("UICorner")
    submitButtonCorner.CornerRadius = UDim.new(0, 5)
    submitButtonCorner.Parent = submitButton
    
    -- Discord-Container
    local discordContainer = Instance.new("Frame")
    discordContainer.Size = UDim2.new(0.9, 0, 0, 30)
    discordContainer.Position = UDim2.new(0.05, 0, 0.85, 0)
    discordContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    discordContainer.BorderSizePixel = 0
    discordContainer.Parent = frame
    
    local discordContainerCorner = Instance.new("UICorner")
    discordContainerCorner.CornerRadius = UDim.new(0, 5)
    discordContainerCorner.Parent = discordContainer
    
    local discordIcon = Instance.new("TextLabel")
    discordIcon.Size = UDim2.new(0.1, 0, 1, 0)
    discordIcon.Position = UDim2.new(0, 5, 0, 0)
    discordIcon.BackgroundTransparency = 1
    discordIcon.Text = "🔗"
    discordIcon.TextColor3 = Color3.fromRGB(114, 137, 218)
    discordIcon.TextSize = 18
    discordIcon.Font = Enum.Font.GothamBold
    discordIcon.Parent = discordContainer
    
    local discordText = Instance.new("TextLabel")
    discordText.Size = UDim2.new(0.5, 0, 1, 0)
    discordText.Position = UDim2.new(0.1, 5, 0, 0)
    discordText.BackgroundTransparency = 1
    discordText.Text = "Discord beitreten"
    discordText.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordText.TextSize = 14
    discordText.Font = Enum.Font.Gotham
    discordText.TextXAlignment = Enum.TextXAlignment.Left
    discordText.Parent = discordContainer
    
    local discordButton = Instance.new("TextButton")
    discordButton.Size = UDim2.new(0.3, 0, 0.8, 0)
    discordButton.Position = UDim2.new(0.65, 0, 0.1, 0)
    discordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    discordButton.BorderSizePixel = 0
    discordButton.Text = "Kopieren"
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextSize = 12
    discordButton.Font = Enum.Font.GothamBold
    discordButton.Parent = discordContainer
    
    local discordButtonCorner = Instance.new("UICorner")
    discordButtonCorner.CornerRadius = UDim.new(0, 5)
    discordButtonCorner.Parent = discordButton
    
    -- Drag-Funktionalität
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Mache Button funktional
    submitButton.MouseButton1Click:Connect(function()
        local key = inputBox.Text
        
        if key == "" then
            status.Text = "Bitte gib einen Key ein!"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        status.Text = "Überprüfe Key..."
        status.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        -- Überprüfe Key
        local result = api.check_key(key)
        
        if result and result.success then
            runcookedscript()
            status.Text = "Key gültig! Lade Script..."
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            _G.KeyData = result.data or {
                type = "validated",
                hwid = api.get_hwid(),
                expires = os.time() + 86400*30
            }
            
            -- HWID-Warnung anzeigen wenn nötig
            if _G.KeyData.hwid_issue then
                status.Text = "HWID-Problem: Bitte kontaktiere den Support!"
                task.wait(2)
            end
            
            -- Verzögerung für besseres Feedback
            task.wait(1)
            
            -- UI entfernen
            screenGui:Destroy()
            
            -- Script laden
            api.load_script()
        else
            status.Text = result.message or "Ungültiger Key!"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    discordButton.MouseButton1Click:Connect(function()
        local invite = "https://discord.gg/5zErAPgCYm"
        setclipboard(invite)
        discordButton.Text = "Kopiert!"
        task.wait(2)
        discordButton.Text = "Kopieren"
    end)
end

function api.load_script()
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local saved_key = load_saved_key()
    local is_quick_load = saved_key ~= nil
    
    debug_print("Script-Laden gestartet:", {
        is_quick_load = is_quick_load,
        saved_key = saved_key
    })
    
    local execution_data = {
        hwid = api.get_hwid(),
        ip = api.get_ip(),
        account_name = LocalPlayer.Name,
        account_id = LocalPlayer.UserId,
        job_id = game.JobId,
        place_id = game.PlaceId,
        game_name = game.Name,
        executor = identifyexecutor and identifyexecutor() or "Unknown",
        timestamp = os.time(),
        key_data = _G.KeyData,
        is_quick_load = is_quick_load,
        saved_key = saved_key
    }
    
    debug_print("Sende Ausführungsdaten:", execution_data)
    
    local success, result = pcall(function()
        local requestFunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
        
        if requestFunc then
            debug_print("Sende Log-Anfrage")
            local response = requestFunc({
                Url = "https://letsnet.vercel.app/api/log",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["X-API-Key"] = "fd35e70a9d6b8c00d20e99e9020d163697b357e8d2fd6a6a372cbbef447c0c28"
                },
                Body = HttpService:JSONEncode({
                    action = is_quick_load and "script_quick_load" or "script_execution",
                    data = execution_data
                })
            })
            debug_print("Log-Antwort erhalten:", {
                status = response.StatusCode,
                body = response.Body
            })
        else
            debug_print("Keine HTTP-Request-Funktion für Logging verfügbar")
        end
    end)
    
    if not success then
        debug_print("Fehler beim Logging:", result)
    end
end

if BYPASSKEYSYSTEM then
    startScript()
    INBOOTSTRAP = false
    SCRIPTRUNNING = true
else
    
    api.create_key_system()
end

return api
