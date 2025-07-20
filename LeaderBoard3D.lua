-- Tablón 3D con la lista de mejores jugadores (por KOs), mostrando foto y nombre
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Eliminar carteles previos para evitar duplicados
local oldBoard = Workspace:FindFirstChild("Leaderboard3DBoard")
if oldBoard then oldBoard:Destroy() end
local oldAvatar = Workspace:FindFirstChild("Avatar3DBoard")
if oldAvatar then oldAvatar:Destroy() end

-- Definir posiciones separadas para ambos carteles (lejos del bosque y entre ellos)
local leaderboardPos = Vector3.new(150, 8, 20) -- Leaderboard más lejos
local avatarPos = Vector3.new(-120, 8, 20) -- Avatar en el lado opuesto

-- Crear el Part del leaderboard
local board = Instance.new("Part")
board.Name = "Leaderboard3DBoard"
board.Anchored = true
board.CanCollide = false
board.Size = Vector3.new(18, 12, 1)
board.Position = leaderboardPos
board.Parent = Workspace

-- Crear el Part del cartel Avatar separado del leaderboard
local avatarPart = Instance.new("Part")
avatarPart.Name = "Avatar3DBoard"
avatarPart.Anchored = true
avatarPart.CanCollide = false
avatarPart.Size = Vector3.new(22, 12, 1)
avatarPart.Position = avatarPos
avatarPart.Parent = Workspace

-- SurfaceGui para el leaderboard
local surfaceGui = Instance.new("SurfaceGui")
surfaceGui.Face = Enum.NormalId.Front
surfaceGui.Adornee = board
surfaceGui.AlwaysOnTop = true
surfaceGui.Parent = board

local title = Instance.new("TextLabel")
title.Name = "LeaderboardTitleLabel"
title.Size = UDim2.new(1,0,0.13,0)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Mejores Jugadores"
title.TextColor3 = Color3.fromRGB(255,215,80)
title.Font = Enum.Font.Fantasy
title.TextScaled = true
title.Parent = surfaceGui

-- SurfaceGui para el cartel Avatar
local avatarGui = Instance.new("SurfaceGui")
avatarGui.Face = Enum.NormalId.Front
avatarGui.Adornee = avatarPart
avatarGui.AlwaysOnTop = true
avatarGui.Parent = avatarPart

local avatarTitle = Instance.new("TextLabel")
avatarTitle.Name = "AvatarTitleLabel"
avatarTitle.Size = UDim2.new(1,0,1,0)
avatarTitle.BackgroundTransparency = 1
avatarTitle.Text = "AVATAR\nEl poder de los elementos"
avatarTitle.TextColor3 = Color3.fromRGB(80,180,255)
avatarTitle.Font = Enum.Font.Fantasy
avatarTitle.TextScaled = true
avatarTitle.TextStrokeTransparency = 0.2
avatarTitle.Parent = avatarGui

local headshotCache = {}

local function getHeadshot(userId)
	if headshotCache[userId] then
		return headshotCache[userId]
	end
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size100x100
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	headshotCache[userId] = content
	return content
end

local function updateLeaderboard()
	local players = {}
	for _, p in Players:GetPlayers() do
		table.insert(players, {Name=p.Name, KOs=p.leaderstats and p.leaderstats:FindFirstChild("KOs") and p.leaderstats.KOs.Value or 0, UserId=p.UserId})
	end
	table.sort(players, function(a,b) return a.KOs > b.KOs end)
	for i = 1, 5 do
		-- Imagen
		local img = surfaceGui:FindFirstChild("PlayerImg"..i)
		if not img then
			img = Instance.new("ImageLabel")
			img.Name = "PlayerImg"..i
			img.Size = UDim2.new(0, 60, 0, 60)
			img.Position = UDim2.new(0, 10, 0.13+(i-1)*0.17, 0)
			img.BackgroundTransparency = 1
			img.Parent = surfaceGui
		end
		-- Nombre y KOs
		local label = surfaceGui:FindFirstChild("Player"..i)
		if not label then
			label = Instance.new("TextLabel")
			label.Name = "Player"..i
			label.Size = UDim2.new(0, 200, 0, 60)
			label.Position = UDim2.new(0, 80, 0.13+(i-1)*0.17, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.fromRGB(255,255,255)
			label.Font = Enum.Font.SourceSansBold
			label.TextScaled = true
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = surfaceGui
		end
		if players[i] then
			img.Image = getHeadshot(players[i].UserId)
			img.Visible = true
			label.Text = i..". "..players[i].Name.." - "..players[i].KOs.." KOs"
			label.Visible = true
		else
			img.Visible = false
			label.Visible = false
		end
	end
end

Players.PlayerAdded:Connect(updateLeaderboard)
Players.PlayerRemoving:Connect(updateLeaderboard)
for _, p in Players:GetPlayers() do
	if p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("KOs") then
		p.leaderstats.KOs.Changed:Connect(updateLeaderboard)
	end
end
updateLeaderboard()
