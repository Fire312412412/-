--[[
    BRAINROT PREM V4 - OFFICIAL FINAL SOURCE
    Developed by: Fire312412412
    Target: Universal Brainrot Tsunami Games
]]

-- [[ CONFIGURATION ]] --
local AdminID = 9914482175 -- 개발자 본인 고유 ID (프리패스)
local Player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 전역 키 저장소 (서버 내 유지)
_G.KeyStorage = _G.KeyStorage or {}
_G.UserKey = "" -- 유저가 입력한 키 저장

-- [[ UI LIBRARY LOAD ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com"))()

-- [[ AUTH LOGIC ]] --
local isDev = (Player.UserId == AdminID)

-- 시간 포맷 함수 (초 -> 00h 00m 00s)
local function FormatTime(seconds)
    if seconds <= 0 then return "Expired" end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02dh %02dm %02ds", h, m, s)
end

-- [[ MAIN SCRIPT CONTENT ]] --
local function StartMain(timeLeftStr)
    local Window = Library:CreateWindow({
        Name = "BRAINROT PREM V4", 
        LoadingTitle = "Syncing with Server...",
        ConfigurationSaving = {Enabled = true, Folder = "BrainrotV4"}
    })

    -- [MAIN TAB]
    local MainTab = Window:CreateTab("Main", 4483362458)
    local TimeLabel = MainTab:CreateLabel("Time Left: " .. timeLeftStr)

    -- 시간 실시간 업데이트 루프
    task.spawn(function()
        while true do
            if isDev then
                TimeLabel:Set("Time Left: Infinity (Developer)")
                break
            else
                local data = _G.KeyStorage[_G.UserKey]
                if data then
                    local diff = data.Exp - os.time()
                    if diff <= 0 then
                        Player:Kick("Key Expired!")
                        break
                    end
                    TimeLabel:Set("Time Left: " .. FormatTime(diff))
                end
            end
            task.wait(1)
        end
    end)

    -- [범용 아이템 복사 기능]
    MainTab:CreateButton({
        Name = "SERVER-SIDE CLONE (ANY ITEM)",
        Callback = function()
            local Tool = Player.Character:FindFirstChildOfClass("Tool")
            if Tool then
                Tool.Archivable = true 
                
                -- 서버 리모트 이벤트 자동 호출 (실제 거래 가능하게 함)
                local found = false
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:find("Give") or v.Name:find("Claim") or v.Name:find("Tool")) then
                        v:FireServer(Tool.Name)
                        found = true
                    end
                end

                -- 로컬 백업 복사
                local Clone = Tool:Clone()
                Clone.Parent = Player.Backpack
                
                Library:Notify({
                    Title = "SUCCESS", 
                    Content = "["..Tool.Name.."] Cloned! (Remote: "..tostring(found)..")",
                    Duration = 3
                })
            else
                Library:Notify({Title = "ERROR", Content = "아이템을 손에 들어주세요!", Duration = 3})
            end
        end
    })

    -- [[ DEVELOPER PORTAL (AdminID 전용) ]] --
    if isDev then
        local AdminTab = Window:CreateTab("Dev Portal", 4483362458)
        local selectedDays = 1

        AdminTab:CreateDropdown({
            Name = "Select Duration",
            Options = {"1 Day", "1 Week", "1 Month", "Permanent"},
            CurrentOption = "1 Day",
            Callback = function(Option)
                local days = {["1 Day"]=1, ["1 Week"]=7, ["1 Month"]=30, ["Permanent"]=9999}
                selectedDays = days[Option]
            end,
        })

        AdminTab:CreateButton({
            Name = "GENERATE & COPY KEY",
            Callback = function()
                local newKey = "BR-" .. string.upper(HttpService:GenerateGUID(false):sub(1,8))
                _G.KeyStorage[newKey] = {
                    Exp = os.time() + (selectedDays * 86400),
                    Type = selectedDays .. "d"
                }
                if setclipboard then setclipboard(newKey) end
                Library:Notify({Title = "KEY READY", Content = "Generated: " .. newKey .. " (Copied)"})
                print("Generated Key: " .. newKey .. " | Duration: " .. selectedDays .. "d")
            end
        })
    end
end

-- [[ AUTHENTICATION UI (일반 유저용) ]] --
if isDev then
    -- 개발자는 인증 없이 즉시 실행
    StartMain("Infinity (Developer)")
else
    local AuthWindow = Library:CreateWindow({Name = "BRAINROT PREM - AUTH", LoadingTitle = "Waiting for Key..."})
    local AuthTab = AuthWindow:CreateTab("Authentication", 4483362458)

    AuthTab:CreateInput({
        Name = "Enter Your Key",
        PlaceholderText = "BR-XXXXXXX",
        Callback = function(Value)
            _G.UserKey = Value
        end,
    })

    AuthTab:CreateButton({
        Name = "SUBMIT KEY",
        Callback = function()
            local data = _G.KeyStorage[_G.UserKey]
            if data and os.time() < data.Exp then
                local diff = data.Exp - os.time()
                Library:Notify({Title = "SUCCESS", Content = "Welcome, " .. Player.Name})
                AuthWindow:Destroy()
                StartMain(FormatTime(diff))
            else
                Library:Notify({Title = "ERROR", Content = "Invalid or Expired Key!"})
            end
        end
    })
end
