local Folder = script.Parent
local Config = require(Folder.Config)
local Players = game:GetService("Players")
local DataPlr = {}
	local Post = {}
	
	game.ReplicatedStorage["TM-Mic"].Mic.OnServerEvent:Connect(function(plr,action,str)
		if action == "start" then
			Post[plr.Name] = true
		elseif action == "set-mic" and type(str)=="number" and str % 1 == 0 and str > 0 and str <= #Config.Settings then	
			plr:SetAttribute("mic",str)
		end
	end)
	
	Players.PlayerRemoving:Connect(function(v)
		DataPlr[v.Name] = nil
		Post[v.Name] = nil
	end)
	
	local function Added (v:Player)
		if DataPlr[v.Name] then return end
		DataPlr[v.Name] = true
		v:SetAttribute("mic",Config.StartMic)
		repeat
			pcall(function()
				game.ReplicatedStorage["TM-Mic"].Mic:FireClient(v,Config)
			end)
			wait(1)
		until not v.Parent or Post[v.Name]
	end
	
	for i,v in pairs(Players:GetPlayers()) do
		
		task.spawn(Added,v)
	end
	
	Players.PlayerAdded:Connect(Added)
