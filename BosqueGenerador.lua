
-- Generador de plataforma de bosque con árboles y piedras para sobrevivir
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear evento remoto para generar bosque
local generateForestEvent = Instance.new("RemoteEvent")
generateForestEvent.Name = "GenerateForest"
generateForestEvent.Parent = ReplicatedStorage

local function generateForest()
	-- Limpiar bosque anterior si existe
	for _, obj in Workspace:GetChildren() do
		if obj.Name == "BosquePlataforma" or obj.Name == "BosqueArbol" or obj.Name == "BosquePiedra" then
			obj:Destroy()
		end
	end

	-- Crear plataforma base más grande
	local plataforma = Instance.new("Part")
	plataforma.Name = "BosquePlataforma"
	plataforma.Size = Vector3.new(300, 3, 300)
	plataforma.Position = Vector3.new(-10, 1.5, 50)
	plataforma.Anchored = true
	plataforma.Material = Enum.Material.Grass
	plataforma.Color = Color3.fromRGB(60, 180, 60)
	plataforma.Parent = Workspace

	-- Generar árboles más realistas y en mayor cantidad
	for i = 1, 120 do
		-- Tronco principal más detallado
		local tronco = Instance.new("Part")
		tronco.Name = "BosqueArbol"
		local altura = math.random(18, 30)
		tronco.Size = Vector3.new(math.random(2.5, 4), altura, math.random(2.5, 4))
		local x = math.random(-140, 120)
		local z = math.random(-140, 140)
		tronco.Position = Vector3.new(plataforma.Position.X + x, plataforma.Position.Y + tronco.Size.Y/2 + 1.5, plataforma.Position.Z + z)
		tronco.Anchored = true
		tronco.Material = Enum.Material.Wood
		tronco.Color = Color3.fromRGB(math.random(70, 90), math.random(50, 70), math.random(20, 40))
		tronco.Parent = Workspace

		-- Añadir textura al tronco
		local mesh = Instance.new("CylinderMesh")
		mesh.Parent = tronco

		-- Copa principal más natural
		local copa = Instance.new("Part")
		copa.Name = "BosqueArbol"
		copa.Size = Vector3.new(math.random(12, 20), math.random(10, 16), math.random(12, 20))
		copa.Position = tronco.Position + Vector3.new(0, tronco.Size.Y/2 + copa.Size.Y/2 - 2, 0)
		copa.Anchored = true
		copa.Material = Enum.Material.Grass
		copa.Color = Color3.fromRGB(math.random(30, 50), math.random(100, 140), math.random(30, 50))
		copa.Shape = Enum.PartType.Ball
		copa.Parent = Workspace

		-- Añadir ramas secundarias para más realismo
		for j = 1, math.random(2, 4) do
			local rama = Instance.new("Part")
			rama.Name = "BosqueArbol"
			rama.Size = Vector3.new(1.5, math.random(3, 6), 1.5)
			rama.Position = tronco.Position + Vector3.new(
				math.random(-3, 3), 
				math.random(altura/3, altura*2/3), 
				math.random(-3, 3)
			)
			rama.Anchored = true
			rama.Material = Enum.Material.Wood
			rama.Color = Color3.fromRGB(math.random(70, 90), math.random(50, 70), math.random(20, 40))
			rama.Parent = Workspace

			-- Copa de rama
			local copaRama = Instance.new("Part")
			copaRama.Name = "BosqueArbol"
			copaRama.Size = Vector3.new(math.random(6, 10), math.random(5, 8), math.random(6, 10))
			copaRama.Position = rama.Position + Vector3.new(0, rama.Size.Y/2 + 2, 0)
			copaRama.Anchored = true
			copaRama.Material = Enum.Material.Grass
			copaRama.Color = Color3.fromRGB(math.random(30, 50), math.random(100, 140), math.random(30, 50))
			copaRama.Shape = Enum.PartType.Ball
			copaRama.Parent = Workspace
		end
	end

	-- Generar más piedras para el bosque grande
	for i = 1, 80 do
		local piedra = Instance.new("Part")
		piedra.Name = "BosquePiedra"
		local size = math.random(3, 12)
		piedra.Size = Vector3.new(size, math.random(2, 8), size)
		local x = math.random(-140, 120)
		local z = math.random(-140, 140)
		piedra.Position = Vector3.new(plataforma.Position.X + x, plataforma.Position.Y + piedra.Size.Y/2 + 1.5, plataforma.Position.Z + z)
		piedra.Anchored = true
		piedra.Material = Enum.Material.Slate
		piedra.Color = Color3.fromRGB(math.random(90, 130), math.random(90, 130), math.random(90, 130))
		piedra.Parent = Workspace
	end

	-- Generar más arbustos variados
	for i = 1, 60 do
		local arbusto = Instance.new("Part")
		arbusto.Name = "BosqueArbol"
		arbusto.Size = Vector3.new(math.random(4, 8), math.random(2, 4), math.random(4, 8))
		local x = math.random(-140, 120)
		local z = math.random(-140, 140)
		arbusto.Position = Vector3.new(plataforma.Position.X + x, plataforma.Position.Y + arbusto.Size.Y/2 + 1.5, plataforma.Position.Z + z)
		arbusto.Anchored = true
		arbusto.Material = Enum.Material.Grass
		arbusto.Color = Color3.fromRGB(math.random(50, 80), math.random(160, 200), math.random(50, 80))
		arbusto.Shape = Enum.PartType.Ball
		arbusto.Transparency = 0.1
		arbusto.Parent = Workspace
	end

	-- Añadir algunos troncos caídos para más realismo
	for i = 1, 15 do
		local troncoCaido = Instance.new("Part")
		troncoCaido.Name = "BosqueArbol"
		troncoCaido.Size = Vector3.new(math.random(15, 25), math.random(2, 3), math.random(2, 3))
		local x = math.random(-140, 120)
		local z = math.random(-140, 140)
		troncoCaido.Position = Vector3.new(plataforma.Position.X + x, plataforma.Position.Y + 2, plataforma.Position.Z + z)
		troncoCaido.Anchored = true
		troncoCaido.Material = Enum.Material.Wood
		troncoCaido.Color = Color3.fromRGB(60, 40, 20)
		troncoCaido.CFrame = troncoCaido.CFrame * CFrame.Angles(0, 0, math.rad(math.random(-15, 15)))
		troncoCaido.Parent = Workspace
	end

	print("Bosque generado exitosamente!")
end

-- Generar el bosque inmediatamente al cargar
generateForest()

-- También permitir regenerar desde el cliente
generateForestEvent.OnServerEvent:Connect(function(player)
	generateForest()
end)
