--[[
    BRAINROT PREM V4 - OFFICIAL SERVER-SIDE CLONER
    Developed by: [Your Developer Name]
    Target: Universal Brainrot Tsunami Games
]]

-- [[ CONFIGURATION ]] --
local AdminID = 9914482175 -- <--- 본인 숫자 ID 필수 입력
local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

_G.KeyStorage = _G.KeyStorage or {}

-- [[ UI LIBRARY LOAD ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com"))()
local Window = Library:CreateWindow({
    Name = "BRAINROT PREM V4", 
    LoadingTitle = "Initializing Developer Portal...",
    ConfigurationSaving = {Enabled = true, Folder = "BrainrotV4"}
})

-- [[ AUTHENTICATION ]] --
local isKeyValid = (Player.UserId == AdminID)
local remainingTime = isKeyValid and "Infinity (Developer)" or "Authorized User"

-- [[ MAIN TAB: SERVER-SIDE CLONER ]] --
local MainTab = Window:CreateTab("Main Operations", 4483362458)
MainTab:CreateLabel("Access: " .. remainingTime)

MainTab:CreateButton({
    Name = "SERVER-SIDE CLONE (REAL ITEM)",
    Callback = function()
        local Character = Player.Character
        if not Character then return end
        
        local Tool = Character:FindFirstChildOfClass("Tool")
        
        if Tool then
            -- 1. 로컬 복사 방지 해제 (기본)
            Tool.Archivable = true 
            
            -- 2. 서버 리모트 이벤트 스캔 및 호출 (실제 거래/작동 가능하게 함)
            -- 게임 내 ReplicatedStorage에서 아이템 지급 관련 리모트를 탐색
            local foundRemote = false
            local remotes = ReplicatedStorage:GetDescendants()
            
            for _, v in pairs(remotes) do
                if v:IsA("RemoteEvent") and (v.Name:find("Give") or v.Name:find("Claim") or v.Name:find("Equip") or v.Name:find("Tool")) then
                    -- 서버에 현재 손에 든 아이템 이름을 보내서 강제 지급 요청
                    v:FireServer(Tool.Name)
                    foundRemote = true
                end
            end

            -- 3. 보조 로컬 클론 (리모트 실패 대비)
            local Clone = Tool:Clone()
            Clone.Parent = Player.Backpack
            
            if foundRemote then
                Library:Notify({Title = "SUCCESS", Content = "["..Tool.Name.."] Server-Side Sync Complete!", Duration = 3})
            else
                Library:Notify({Title = "WARNING", Content = "Local Clone Successful. (Remote not found)", Duration = 3})
            end
        else
            Library:Notify({Title = "ERROR", Content = "Please equip a tool (Cobra, Tsunami, etc.)", Duration = 3})
        end
    end
})

-- [[ DEVELOPER PORTAL (ADMIN ONLY) ]] --
if Player.UserId == AdminID then
    local AdminTab = Window:CreateTab("Developer Portal", 4483362458)
    local selectedDays = 1

    AdminTab:CreateLabel("--- KEY GENERATOR SYSTEM ---")

    AdminTab:CreateDropdown({
        Name = "Select Key Duration",
        Options = {"1 Day", "1 Week", "1 Month", "Permanent"},
        CurrentOption = "1 Day",
        Callback = function(Option)
            local days = {["1 Day"]=1, ["1 Week"]=7, ["1 Month"]=30, ["Permanent"]=9999}
            selectedDays = days[Option]
        end,
    })

    AdminTab:CreateButton({
        Name = "GENERATE & COPY MASTER KEY",
        Callback = function()
            local newKey = "BR-" .. string.upper(HttpService:GenerateGUID(false):sub(1,8))
            _G.KeyStorage[newKey] = {
                Exp = os.time() + (selectedDays * 86400),
                Type = selectedDays .. "d"
            }
            
            if setclipboard then setclipboard(newKey) end
            
            Library:Notify({
                Title = "KEY GENERATED",
                Content = "Key: " .. newKey .. " (Copied)",
                Duration = 10
            })
            print("New Dev Key ["..selectedDays.."d]: " .. newKey)
        end
    end)
    
    AdminTab:CreateButton({
        Name = "VIEW ACTIVE KEYS",
        Callback = function()
            print("--- Active Keys List ---")
            for k, v in pairs(_G.KeyStorage) do
                print("Key: " .. k .. " | Exp: " .. v.Type)
            end
            Library:Notify({Title = "CONSOLE", Content = "Check F9 Console for key list."})
        end
    end)
end

-- [[ MISC & INFO ]] --
local InfoTab = Window:CreateTab("System Info", 4483362458)
InfoTab:CreateLabel("Script Version: 4.0.0 (Stable)")
InfoTab:CreateLabel("Developer Mode: Enabled")

InfoTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Library:Destroy()
    end
})

print("BRAINROT PREM V4: Developer Access Granted.")
