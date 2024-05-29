local Folder = script.Parent

local ReadLicense = require(script:FindFirstAncestorOfClass("ServerScriptService"):FindFirstChild("TM-License",true))
local Config = require(Folder.Config)
local Players = game:GetService("Players")
local Stack = 0
local Running = false

if Folder.Name == "TM-Radio" then

	for i,v in pairs(Folder.Parent:GetChildren()) do
		task.spawn(function()
			if v.Name == Folder.Name and v:IsA("Folder") and v ~= Folder then
				v:Destroy()
			end
		end)
	end

	local success,err
	
	while Stack < 10 do
		success,err = pcall(function()
			Running = ReadLicense(Config.Token,script)
		end)
		if success and Running then
			break
		elseif err then	
			Stack += 1
		elseif success and not Running then
			script:Destroy()
		end
		wait(1)
	end
	if Stack == 10 then
		script:Destroy()
	end
end

if Running ~= Folder.Name then
	Folder:Destroy()
else
	
	local DataPlr = {}
	local Post = {}
	
	game.ReplicatedStorage[Folder.Name].Radio.OnServerEvent:Connect(function(plr,action,str)
		if action == "Start" then
			Post[plr.Name] = true
		elseif action == "radiotalk" and type(str) == "boolean" then	
			plr:SetAttribute("radiotalk",str)
		end
	end)
	
	Players.PlayerRemoving:Connect(function(v)
		DataPlr[v.Name] = nil
		Post[v.Name] = nil
	end)
	
	local function Added (v:Player)
		if DataPlr[v.Name] then return end
		DataPlr[v.Name] = true
		
		local function Clear ()
			local char = v.Character or v.CharacterAdded:Wait()
			local humanoid : Humanoid = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid",1/0)
			humanoid.Died:Connect(function()
				v:SetAttribute("radio",nil)
				v:SetAttribute("radiotalk",false)
			end)
		end
		
		v.Chatted:Connect(function(message)
			local text = message:split(" ")
			if #text >= 2 then
				if text[1] == Config.Commmand.Join and tonumber(text[2]) then
					local number = tonumber(text[2])
					if number % 1 == 0 and number >= Config.Settings.Low and number <= Config.Settings.High then	
						v:SetAttribute("radio",number)
					end
				elseif message == Config.Commmand.Leave then
					v:SetAttribute("radio",nil)
				end
			end
		end)
		
		
		
		repeat
			pcall(function()
				game.ReplicatedStorage[Folder.Name].Radio:FireClient(v,Config)
			end)
			wait(1)
		until not v.Parent or Post[v.Name]
		Clear()
		
		v.CharacterAdded:Connect(function(char)
			Clear()
		end)
		
	end
	
	for i,v in pairs(Players:GetPlayers()) do	
		task.spawn(Added,v)
	end
	
	Players.PlayerAdded:Connect(Added)
	
end

