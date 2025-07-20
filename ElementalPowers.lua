local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UseElementPower = ReplicatedStorage:WaitForChild("UseElementPower")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local ElementalPowers = {}

-- Función auxiliar para obtener la mano (derecha o izquierda)
local function getHand(character, preferRight)
	local right = character:FindFirstChild("RightHand")
	local left = character:FindFirstChild("LeftHand")
	if preferRight and right then return right end
	if not preferRight and left then return left end
	return right or left or character:FindFirstChild("HumanoidRootPart")
end

-- Función para crear animación de artes marciales
local function playMartialArtsAnimation(character, animationType)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Buscar las articulaciones correctas del brazo
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not torso then return end

	local rightShoulder = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder")
	local leftShoulder = torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftShoulder")

	if animationType == "fire" then
		-- Pose de fuego: brazos hacia adelante como lanzando
		spawn(function()
			local originalRightC0 = rightShoulder and rightShoulder.C0 or CFrame.new()
			local originalLeftC0 = leftShoulder and leftShoulder.C0 or CFrame.new()

			for i = 1, 10 do
				if rightShoulder then
					rightShoulder.C0 = rightShoulder.C0 * CFrame.Angles(math.rad(-8), 0, math.rad(10))
				end
				if leftShoulder then
					leftShoulder.C0 = leftShoulder.C0 * CFrame.Angles(math.rad(-8), 0, math.rad(-10))
				end
				wait(0.05)
			end
			wait(0.5)
			-- Restaurar posición original gradualmente
			for i = 1, 10 do
				if rightShoulder then
					rightShoulder.C0 = rightShoulder.C0:Lerp(originalRightC0, 0.1)
				end
				if leftShoulder then
					leftShoulder.C0 = leftShoulder.C0:Lerp(originalLeftC0, 0.1)
				end
				wait(0.05)
			end
		end)
	elseif animationType == "water" then
		-- Pose de agua: movimiento fluido circular
		spawn(function()
			local originalRightC0 = rightShoulder and rightShoulder.C0 or CFrame.new()

			for i = 1, 20 do
				local angle = math.rad(i * 18)
				if rightShoulder then
					rightShoulder.C0 = originalRightC0 * CFrame.Angles(
						math.sin(angle) * 0.5, 
						math.cos(angle) * 0.3, 
						math.sin(angle * 2) * 0.2
					)
				end
				wait(0.05)
			end
			-- Restaurar
			if rightShoulder then
				rightShoulder.C0 = originalRightC0
			end
		end)
	elseif animationType == "earth" then
		-- Pose de tierra: golpe hacia abajo
		spawn(function()
			local originalRightC0 = rightShoulder and rightShoulder.C0 or CFrame.new()

			for i = 1, 8 do
				if rightShoulder then
					rightShoulder.C0 = rightShoulder.C0 * CFrame.Angles(math.rad(15), 0, 0)
				end
				wait(0.05)
			end
			wait(0.2)
			-- Golpe rápido hacia abajo
			for i = 1, 5 do
				if rightShoulder then
					rightShoulder.C0 = rightShoulder.C0 * CFrame.Angles(math.rad(-25), 0, 0)
				end
				wait(0.02)
			end
			wait(0.3)
			-- Restaurar
			if rightShoulder then
				rightShoulder.C0 = originalRightC0
			end
		end)
	end
end

-- Función para encontrar el jugador más cercano (que no sea el propio)
local function getClosestPlayer(fromPlayer)
	local minDist = math.huge
	local closest = nil
	local fromChar = fromPlayer.Character
	if not fromChar or not fromChar:FindFirstChild("HumanoidRootPart") then return nil end
	local fromPos = fromChar.HumanoidRootPart.Position
	for _, p in Players:GetPlayers() do
		if p ~= fromPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
			local dist = (p.Character.HumanoidRootPart.Position - fromPos).Magnitude
			if dist < minDist then
				minDist = dist
				closest = p
			end
		end
	end
	return closest
end

-- Poder de fuego básico: llamas realistas desde las manos
function ElementalPowers.FirePower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, true)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not hand or not rootPart then return end

	-- Animación de artes marciales
	playMartialArtsAnimation(character, "fire")

	-- Obtener dirección hacia donde apunta el jugador
	local direction = rootPart.CFrame.LookVector

	-- Crear parte invisible para anclar el efecto de fuego en la mano
	local fireSource = Instance.new("Part")
	fireSource.Size = Vector3.new(0.1, 0.1, 0.1)
	fireSource.Position = hand.Position
	fireSource.Anchored = true
	fireSource.CanCollide = false
	fireSource.Transparency = 1
	fireSource.Parent = workspace

	-- Weld para que siga la mano
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hand
	weld.Part1 = fireSource
	weld.Parent = fireSource

	-- Crear múltiples emisores de partículas para un efecto de fuego más realista
	local mainEmitter = Instance.new("ParticleEmitter")
	mainEmitter.Texture = "rbxassetid://241594419"
	mainEmitter.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 100)),  -- Amarillo en la base
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 150, 50)), -- Naranja en el medio
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 20))     -- Rojo en las puntas
	}
	mainEmitter.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1.2),
		NumberSequenceKeypoint.new(1, 0.2)
	}
	mainEmitter.Lifetime = NumberRange.new(0.8, 1.5)
	mainEmitter.Rate = 150
	mainEmitter.Speed = NumberRange.new(8, 15)
	mainEmitter.SpreadAngle = Vector2.new(25, 25)
	mainEmitter.Acceleration = Vector3.new(0, 5, 0)
	mainEmitter.VelocityInheritance = 0.3
	mainEmitter.Parent = fireSource

	-- Emisor secundario para chispas
	local sparkEmitter = Instance.new("ParticleEmitter")
	sparkEmitter.Texture = "rbxassetid://241594419"
	sparkEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 200, 100))
	sparkEmitter.Size = NumberSequence.new(0.3)
	sparkEmitter.Lifetime = NumberRange.new(0.3, 0.8)
	sparkEmitter.Rate = 80
	sparkEmitter.Speed = NumberRange.new(12, 25)
	sparkEmitter.SpreadAngle = Vector2.new(45, 45)
	sparkEmitter.Acceleration = Vector3.new(0, -20, 0)
	sparkEmitter.Parent = fireSource

	-- Crear proyectil de fuego que se lanza en la dirección correcta
	local fireProjectile = Instance.new("Part")
	fireProjectile.Size = Vector3.new(1, 1, 2)
	fireProjectile.Position = hand.Position + direction * 2
	fireProjectile.Anchored = false
	fireProjectile.CanCollide = false
	fireProjectile.Transparency = 0.3
	fireProjectile.Color = Color3.fromRGB(255, 120, 40)
	fireProjectile.Material = Enum.Material.Neon
	fireProjectile.Parent = workspace

	-- Usar BodyPosition y BodyAngularVelocity para mejor control
	local bodyPos = Instance.new("BodyPosition")
	bodyPos.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyPos.Position = hand.Position + direction * 50
	bodyPos.Parent = fireProjectile

	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.Velocity = direction * 80
	bodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e5
	bodyVel.Parent = fireProjectile

	-- Orientar el proyectil en la dirección del movimiento
	fireProjectile.CFrame = CFrame.lookAt(fireProjectile.Position, fireProjectile.Position + direction)

	-- Efecto de fuego en el proyectil
	local projectileEmitter = Instance.new("ParticleEmitter")
	projectileEmitter.Texture = "rbxassetid://241594419"
	projectileEmitter.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 20))
	}
	projectileEmitter.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0.3)
	}
	projectileEmitter.Lifetime = NumberRange.new(0.3, 0.7)
	projectileEmitter.Rate = 120
	projectileEmitter.Speed = NumberRange.new(5, 12)
	projectileEmitter.SpreadAngle = Vector2.new(30, 30)
	projectileEmitter.Parent = fireProjectile

	-- Luz del fuego
	local fireLight = Instance.new("PointLight")
	fireLight.Color = Color3.fromRGB(255, 150, 50)
	fireLight.Brightness = 2
	fireLight.Range = 8
	fireLight.Parent = fireSource

	-- Daño al tocar
	fireProjectile.Touched:Connect(function(hit)
		local hum = hit.Parent:FindFirstChild("Humanoid")
		if hum and hum ~= character:FindFirstChild("Humanoid") then
			hum:TakeDamage(30)
			-- Crear pequeña explosión de fuego al impactar
			local explosion = Instance.new("Explosion")
			explosion.Position = fireProjectile.Position
			explosion.BlastRadius = 6
			explosion.BlastPressure = 200000
			explosion.ExplosionType = Enum.ExplosionType.NoCraters
			explosion.Parent = workspace
			fireProjectile:Destroy()
		end
	end)

	-- Limpiar efectos
	Debris:AddItem(fireSource, 2)
	Debris:AddItem(fireProjectile, 4)
end

-- NUEVO: Poder de fuego izquierda - Bomba de fuego
function ElementalPowers.FireBombPower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, false) -- Mano izquierda
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not hand or not rootPart then return end

	-- Animación especial para bomba
	playMartialArtsAnimation(character, "fire")

	local direction = rootPart.CFrame.LookVector

	-- Crear bomba de fuego más grande
	local bomb = Instance.new("Part")
	bomb.Shape = Enum.PartType.Ball
	bomb.Size = Vector3.new(4, 4, 4)
	bomb.Position = hand.Position + direction * 3
	bomb.Anchored = false
	bomb.CanCollide = false
	bomb.Transparency = 0.3
	bomb.Color = Color3.fromRGB(255, 80, 20)
	bomb.Material = Enum.Material.Neon
	bomb.Parent = workspace

	-- Usar BodyPosition para mejor control direccional
	local bodyPos = Instance.new("BodyPosition")
	bodyPos.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyPos.Position = hand.Position + direction * 40
	bodyPos.Parent = bomb

	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.Velocity = direction * 60
	bodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e5
	bodyVel.Parent = bomb

	-- Efecto de fuego en la bomba
	local bombEmitter = Instance.new("ParticleEmitter")
	bombEmitter.Texture = "rbxassetid://241594419"
	bombEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 120, 40))
	bombEmitter.Size = NumberSequence.new(3)
	bombEmitter.Lifetime = NumberRange.new(0.5, 1.0)
	bombEmitter.Rate = 200
	bombEmitter.Speed = NumberRange.new(10, 20)
	bombEmitter.Parent = bomb

	-- Explosión al tocar
	bomb.Touched:Connect(function(hit)
		local hum = hit.Parent:FindFirstChild("Humanoid")
		if hum and hum ~= character:FindFirstChild("Humanoid") then
			-- Explosión masiva
			local explosion = Instance.new("Explosion")
			explosion.Position = bomb.Position
			explosion.BlastRadius = 15
			explosion.BlastPressure = 500000
			explosion.ExplosionType = Enum.ExplosionType.NoCraters
			explosion.Parent = workspace
			bomb:Destroy()
		end
	end)

	Debris:AddItem(bomb, 5)
end

-- NUEVO: Poder de fuego derecha - Ráfaga múltiple
function ElementalPowers.FireBarragePower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, true)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not hand or not rootPart then return end

	playMartialArtsAnimation(character, "fire")

	local direction = rootPart.CFrame.LookVector

	-- Lanzar múltiples proyectiles de fuego
	for i = 1, 5 do
		spawn(function()
			wait(i * 0.15) -- Delay entre disparos

			local fireball = Instance.new("Part")
			fireball.Shape = Enum.PartType.Ball
			fireball.Size = Vector3.new(2, 2, 2)
			fireball.Position = hand.Position + direction * 2
			fireball.Anchored = false
			fireball.CanCollide = false
			fireball.Transparency = 0.2
			fireball.Color = Color3.fromRGB(255, 120, 40)
			fireball.Material = Enum.Material.Neon
			fireball.Parent = workspace

			-- Añadir variación al ángulo pero mantener dirección hacia adelante
			local spreadDirection = direction + Vector3.new(
				math.random(-15, 15) / 100,
				math.random(-5, 5) / 100,
				0
			)
			spreadDirection = spreadDirection.Unit -- Normalizar

			local bodyPos = Instance.new("BodyPosition")
			bodyPos.MaxForce = Vector3.new(4000, 4000, 4000)
			bodyPos.Position = hand.Position + spreadDirection * 35
			bodyPos.Parent = fireball

			local bodyVel = Instance.new("BodyVelocity")
			bodyVel.Velocity = spreadDirection * 90
			bodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e5
			bodyVel.Parent = fireball

			local emitter = Instance.new("ParticleEmitter")
			emitter.Texture = "rbxassetid://241594419"
			emitter.Color = ColorSequence.new(Color3.fromRGB(255, 150, 40))
			emitter.Size = NumberSequence.new(1.5)
			emitter.Lifetime = NumberRange.new(0.2, 0.5)
			emitter.Rate = 100
			emitter.Speed = NumberRange.new(8, 15)
			emitter.Parent = fireball

			fireball.Touched:Connect(function(hit)
				local hum = hit.Parent:FindFirstChild("Humanoid")
				if hum and hum ~= character:FindFirstChild("Humanoid") then
					hum:TakeDamage(20)
					fireball:Destroy()
				end
			end)

			Debris:AddItem(fireball, 3)
		end)
	end
end

-- NUEVO: Poder de fuego - Bomba de explosión masiva (sale de la boca)
function ElementalPowers.FireExplosionPower(player, moveState)
	local character = player.Character
	if not character then return end
	local head = character:FindFirstChild("Head")
	if not head then return end

	-- Efecto visual de fuego saliendo de la boca
	local firePart = Instance.new("Part")
	firePart.Size = Vector3.new(2,2,2)
	firePart.CFrame = head.CFrame * CFrame.new(0,0,-1)
	firePart.Anchored = true
	firePart.CanCollide = false
	firePart.Transparency = 1
	firePart.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxassetid://241594419"
	emitter.Color = ColorSequence.new(Color3.fromRGB(255,120,40), Color3.fromRGB(255,40,10))
	emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,2), NumberSequenceKeypoint.new(1,6)})
	emitter.Lifetime = NumberRange.new(0.3, 0.7)
	emitter.Rate = 200
	emitter.Speed = NumberRange.new(30, 60)
	emitter.VelocitySpread = 40
	emitter.Parent = firePart

	-- Explosión masiva de fuego
	local explosion = Instance.new("Explosion")
	explosion.Position = head.Position + head.CFrame.LookVector * 6
	explosion.BlastRadius = 18
	explosion.BlastPressure = 900000
	explosion.ExplosionType = Enum.ExplosionType.NoCraters
	explosion.Parent = workspace

	-- Daño extra a jugadores cercanos
	explosion.Hit:Connect(function(part, dist)
		local hum = part.Parent:FindFirstChild("Humanoid")
		if hum and hum ~= character:FindFirstChild("Humanoid") then
			hum:TakeDamage(60)
		end
	end)

	Debris:AddItem(firePart, 1.2)
end

-- NUEVO: Poder de rayo azul (Azula)
function ElementalPowers.AzulaLightningPower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, true)
	if not hand then return end

	local target = getClosestPlayer(player)
	if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end

	local startPos = hand.Position
	local endPos = target.Character.HumanoidRootPart.Position + Vector3.new(0,2,0)
	local dist = (endPos - startPos).Magnitude

	-- Efecto visual: rayo azul
	local beamPart = Instance.new("Part")
	beamPart.Size = Vector3.new(0.5,0.5,dist)
	beamPart.CFrame = CFrame.new((startPos+endPos)/2, endPos)
	beamPart.Anchored = true
	beamPart.CanCollide = false
	beamPart.Transparency = 0.5
	beamPart.Color = Color3.fromRGB(80,180,255)
	beamPart.Material = Enum.Material.Neon
	beamPart.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxassetid://259403370" -- textura de rayo
	emitter.Color = ColorSequence.new(Color3.fromRGB(80,180,255), Color3.fromRGB(0,80,255))
	emitter.Size = NumberSequence.new(1.2)
	emitter.Lifetime = NumberRange.new(0.15, 0.3)
	emitter.Rate = 120
	emitter.Speed = NumberRange.new(20, 40)
	emitter.Parent = beamPart

	-- Daño instantáneo y aturdimiento
	local hum = target.Character:FindFirstChild("Humanoid")
	if hum then
		hum:TakeDamage(50)
		-- Aturdir correctamente: guardar velocidad y restaurar
		local oldSpeed = hum.WalkSpeed
		hum.WalkSpeed = 0
		task.delay(1.2, function()
			if hum then hum.WalkSpeed = oldSpeed end
		end)
	end

	Debris:AddItem(beamPart, 0.7)
end

-- Poder de aire básico
function ElementalPowers.AirPower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, false)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not hand or not rootPart then return end

	playMartialArtsAnimation(character, "water")
	local direction = rootPart.CFrame.LookVector

	local gust = Instance.new("Part")
	gust.Size = Vector3.new(1,1,8)
	gust.CFrame = CFrame.new(hand.Position + direction * 4, hand.Position + direction * 12)
	gust.Anchored = false
	gust.CanCollide = false
	gust.Transparency = 0.7
	gust.Color = Color3.fromRGB(220,220,255)
	gust.Material = Enum.Material.Neon
	gust.Parent = workspace

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = direction * 100
	bv.MaxForce = Vector3.new(1,1,1) * 1e5
	bv.Parent = gust

	-- Efecto de partículas de aire
	local airEmitter = Instance.new("ParticleEmitter")
	airEmitter.Texture = "rbxassetid://130207098"
	airEmitter.Color = ColorSequence.new(Color3.fromRGB(200,200,255))
	airEmitter.Size = NumberSequence.new(1.5)
	airEmitter.Lifetime = NumberRange.new(0.3, 0.7)
	airEmitter.Rate = 80
	airEmitter.Speed = NumberRange.new(15, 25)
	airEmitter.Parent = gust

	gust.Touched:Connect(function(hit)
		local hum = hit.Parent:FindFirstChild("Humanoid")
		if hum and hum ~= character:FindFirstChild("Humanoid") then
			hum:TakeDamage(15)
			-- Empujar al enemigo
			local bodyVel = Instance.new("BodyVelocity")
			bodyVel.Velocity = direction * 50
			bodyVel.MaxForce = Vector3.new(1,1,1) * 1e4
			bodyVel.Parent = hit.Parent:FindFirstChild("HumanoidRootPart")
			Debris:AddItem(bodyVel, 0.5)
		end
	end)
	Debris:AddItem(gust, 1.5)
end

-- NUEVO: Tornado de aire (izquierda)
function ElementalPowers.AirTornadoPower(player, moveState)
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	playMartialArtsAnimation(character, "water")

	-- Crear tornado en frente del jugador
	local tornadoPos = rootPart.Position + rootPart.CFrame.LookVector * 8
	local tornado = Instance.new("Part")
	tornado.Size = Vector3.new(8, 15, 8)
	tornado.Position = tornadoPos
	tornado.Anchored = true
	tornado.CanCollide = false
	tornado.Transparency = 1
	tornado.Parent = workspace

	-- Efecto visual del tornado
	local tornadoEmitter = Instance.new("ParticleEmitter")
	tornadoEmitter.Texture = "rbxassetid://130207098"
	tornadoEmitter.Color = ColorSequence.new(Color3.fromRGB(200,220,255))
	tornadoEmitter.Size = NumberSequence.new(3)
	tornadoEmitter.Lifetime = NumberRange.new(2, 4)
	tornadoEmitter.Rate = 200
	tornadoEmitter.Speed = NumberRange.new(25, 40)
	tornadoEmitter.SpreadAngle = Vector2.new(360, 25)
	tornadoEmitter.Parent = tornado

	-- Daño por área
	spawn(function()
		for i = 1, 30 do
			for _, p in Players:GetPlayers() do
				if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local dist = (p.Character.HumanoidRootPart.Position - tornadoPos).Magnitude
					if dist < 10 then
						local hum = p.Character:FindFirstChild("Humanoid")
						if hum then hum:TakeDamage(3) end
					end
				end
			end
			wait(0.1)
		end
	end)

	Debris:AddItem(tornado, 3)
end

-- NUEVO: Corte de aire (derecha)
function ElementalPowers.AirSlashPower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, true)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not hand or not rootPart then return end

	playMartialArtsAnimation(character, "water")
	local direction = rootPart.CFrame.LookVector

	-- Crear múltiples cortes de aire
	for i = 1, 3 do
		spawn(function()
			wait(i * 0.2)

			local slash = Instance.new("Part")
			slash.Size = Vector3.new(0.2, 6, 8)
			slash.CFrame = CFrame.new(hand.Position + direction * (3 + i * 2), hand.Position + direction * 15)
			slash.Anchored = false
			slash.CanCollide = false
			slash.Transparency = 0.5
			slash.Color = Color3.fromRGB(200,220,255)
			slash.Material = Enum.Material.Neon
			slash.Parent = workspace

			local bv = Instance.new("BodyVelocity")
			bv.Velocity = direction * 90
			bv.MaxForce = Vector3.new(1,1,1) * 1e5
			bv.Parent = slash

			slash.Touched:Connect(function(hit)
				local hum = hit.Parent:FindFirstChild("Humanoid")
				if hum and hum ~= character:FindFirstChild("Humanoid") then
					hum:TakeDamage(25)
					slash:Destroy()
				end
			end)

			Debris:AddItem(slash, 2)
		end)
	end
end

-- Poder de tierra básico
function ElementalPowers.EarthPower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, false)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not hand or not rootPart then return end

	playMartialArtsAnimation(character, "earth")
	local direction = rootPart.CFrame.LookVector

	local rock = Instance.new("Part")
	rock.Size = Vector3.new(3,3,3)
	rock.Position = hand.Position + direction * 2
	rock.Anchored = false
	rock.CanCollide = true
	rock.BrickColor = BrickColor.new("Earth green")
	rock.Material = Enum.Material.Slate
	rock.Parent = workspace

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = direction * 60
	bv.MaxForce = Vector3.new(1,1,1) * 1e5
	bv.Parent = rock

	rock.Touched:Connect(function(hit)
		local hum = hit.Parent:FindFirstChild("Humanoid")
		if hum and hum ~= character:FindFirstChild("Humanoid") then
			hum:TakeDamage(40)
			rock:Destroy()
		end
	end)
	Debris:AddItem(rock, 2)
end

-- NUEVO: Muro de tierra (izquierda)
function ElementalPowers.EarthWallPower(player, moveState)
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	playMartialArtsAnimation(character, "earth")

	-- Crear muro frente al jugador
	local wallPos = rootPart.Position + rootPart.CFrame.LookVector * 5
	for i = 1, 5 do
		local wallPiece = Instance.new("Part")
		wallPiece.Size = Vector3.new(2, 6, 1)
		wallPiece.Position = wallPos + Vector3.new((i-3) * 2, 3, 0)
		wallPiece.Anchored = true
		wallPiece.CanCollide = true
		wallPiece.BrickColor = BrickColor.new("Earth green")
		wallPiece.Material = Enum.Material.Slate
		wallPiece.Parent = workspace

		-- Animar elevación del muro
		local startPos = wallPiece.Position - Vector3.new(0, 6, 0)
		wallPiece.Position = startPos
		TweenService:Create(wallPiece, TweenInfo.new(0.5), {Position = wallPos + Vector3.new((i-3) * 2, 3, 0)}):Play()

		Debris:AddItem(wallPiece, 8)
	end
end

-- NUEVO: Terremoto (derecha)
function ElementalPowers.EarthQuakePower(player, moveState)
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	playMartialArtsAnimation(character, "earth")

	-- Crear efectos de terremoto
	spawn(function()
		for i = 1, 20 do
			for _, p in Players:GetPlayers() do
				if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local dist = (p.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
					if dist < 15 then
						-- Hacer temblar al enemigo
						local shake = Vector3.new(
							math.random(-2, 2),
							0,
							math.random(-2, 2)
						)
						p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + shake

						local hum = p.Character:FindFirstChild("Humanoid")
						if hum then hum:TakeDamage(2) end
					end
				end
			end
			wait(0.1)
		end
	end)
end

-- Poder de agua básico: chorro de agua realista desde las manos
function ElementalPowers.WaterPower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, true)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not hand or not rootPart then return end

	-- Animación de artes marciales para agua
	playMartialArtsAnimation(character, "water")

	-- Obtener dirección hacia donde apunta el jugador
	local direction = rootPart.CFrame.LookVector

	-- Crear fuente de agua en la mano
	local waterSource = Instance.new("Part")
	waterSource.Size = Vector3.new(0.1, 0.1, 0.1)
	waterSource.Position = hand.Position
	waterSource.Anchored = true
	waterSource.CanCollide = false
	waterSource.Transparency = 1
	waterSource.Parent = workspace

	-- Weld para que siga la mano
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hand
	weld.Part1 = waterSource
	weld.Parent = waterSource

	-- Efecto de agua fluida desde la mano
	local waterEmitter = Instance.new("ParticleEmitter")
	waterEmitter.Texture = "rbxassetid://484436622"
	waterEmitter.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 200, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 180, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 120, 200))
	}
	waterEmitter.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.3, 1.5),
		NumberSequenceKeypoint.new(1, 0.4)
	}
	waterEmitter.Lifetime = NumberRange.new(1.2, 2.0)
	waterEmitter.Rate = 200
	waterEmitter.Speed = NumberRange.new(15, 25)
	waterEmitter.SpreadAngle = Vector2.new(15, 15)
	waterEmitter.Acceleration = Vector3.new(0, -10, 0) -- Gravedad para hacer más realista
	waterEmitter.VelocityInheritance = 0.5
	waterEmitter.Parent = waterSource

	-- Crear proyectil de agua que viaja en línea recta
	local waterProjectile = Instance.new("Part")
	waterProjectile.Size = Vector3.new(2, 2, 6)
	waterProjectile.Position = hand.Position + direction * 3
	waterProjectile.Anchored = false
	waterProjectile.CanCollide = false
	waterProjectile.Transparency = 0.4
	waterProjectile.Color = Color3.fromRGB(80, 180, 255)
	waterProjectile.Material = Enum.Material.ForceField
	waterProjectile.Parent = workspace

	-- Usar BodyVelocity para movimiento fluido del agua
	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.Velocity = direction * 70
	bodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e5
	bodyVel.Parent = waterProjectile

	-- Orientar el proyectil
	waterProjectile.CFrame = CFrame.lookAt(waterProjectile.Position, waterProjectile.Position + direction)

	-- Efectos de partículas en el proyectil
	local projectileEmitter = Instance.new("ParticleEmitter")
	projectileEmitter.Texture = "rbxassetid://484436622"
	projectileEmitter.Color = ColorSequence.new(Color3.fromRGB(120, 200, 255))
	projectileEmitter.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1.2),
		NumberSequenceKeypoint.new(1, 0.6)
	}
	projectileEmitter.Lifetime = NumberRange.new(0.5, 1.0)
	projectileEmitter.Rate = 150
	projectileEmitter.Speed = NumberRange.new(8, 15)
	projectileEmitter.SpreadAngle = Vector2.new(25, 25)
	projectileEmitter.Parent = waterProjectile

	-- Daño al tocar
	waterProjectile.Touched:Connect(function(hit)
		local hum = hit.Parent:FindFirstChild("Humanoid")
		if hum and hum ~= character:FindFirstChild("Humanoid") then
			hum:TakeDamage(25)
			-- Crear salpicaduras al impactar
			local splash = Instance.new("ParticleEmitter")
			splash.Texture = "rbxassetid://484436622"
			splash.Color = ColorSequence.new(Color3.fromRGB(120, 200, 255))
			splash.Size = NumberSequence.new(2)
			splash.Lifetime = NumberRange.new(0.3, 0.8)
			splash.Rate = 300
			splash.Speed = NumberRange.new(20, 35)
			splash.SpreadAngle = Vector2.new(180, 180)
			splash.Acceleration = Vector3.new(0, -30, 0)
			splash.Parent = waterProjectile
			splash.Enabled = true

			task.wait(0.3)
			splash.Enabled = false
			waterProjectile:Destroy()
		end
	end)

	-- Limpiar efectos
	Debris:AddItem(waterSource, 2.5)
	Debris:AddItem(waterProjectile, 4)
end

-- NUEVO: Torbellino de agua (izquierda)
function ElementalPowers.WaterWhirlpoolPower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, false) -- Mano izquierda
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not hand or not rootPart then return end

	-- Animación especial para torbellino
	playMartialArtsAnimation(character, "water")

	-- Crear torbellino frente al jugador
	local whirlpoolPos = rootPart.Position + rootPart.CFrame.LookVector * 8
	local whirlpool = Instance.new("Part")
	whirlpool.Size = Vector3.new(8, 12, 8)
	whirlpool.Position = whirlpoolPos
	whirlpool.Anchored = true
	whirlpool.CanCollide = false
	whirlpool.Transparency = 0.7
	whirlpool.Color = Color3.fromRGB(80, 180, 255)
	whirlpool.Material = Enum.Material.ForceField
	whirlpool.Parent = workspace

	-- Efecto visual del torbellino
	local whirlEmitter = Instance.new("ParticleEmitter")
	whirlEmitter.Texture = "rbxassetid://484436622"
	whirlEmitter.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 200, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 120, 200))
	}
	whirlEmitter.Size = NumberSequence.new(2.5)
	whirlEmitter.Lifetime = NumberRange.new(1.5, 3.0)
	whirlEmitter.Rate = 250
	whirlEmitter.Speed = NumberRange.new(20, 35)
	whirlEmitter.SpreadAngle = Vector2.new(360, 30)
	whirlEmitter.Acceleration = Vector3.new(0, 8, 0)
	whirlEmitter.Parent = whirlpool

	-- Hacer rotar el torbellino
	spawn(function()
		for i = 1, 60 do
			whirlpool.CFrame = whirlpool.CFrame * CFrame.Angles(0, math.rad(6), 0)
			task.wait(0.05)
		end
	end)

	-- Daño continuo por área y atracción
	spawn(function()
		for i = 1, 40 do
			for _, p in Players:GetPlayers() do
				if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local dist = (p.Character.HumanoidRootPart.Position - whirlpoolPos).Magnitude
					if dist < 12 then
						local hum = p.Character:FindFirstChild("Humanoid")
						if hum then
							hum:TakeDamage(4)
							-- Atraer hacia el centro del torbellino
							local direction = (whirlpoolPos - p.Character.HumanoidRootPart.Position).Unit
							local bodyVel = Instance.new("BodyVelocity")
							bodyVel.Velocity = direction * 20
							bodyVel.MaxForce = Vector3.new(1, 0, 1) * 1e4
							bodyVel.Parent = p.Character.HumanoidRootPart
							Debris:AddItem(bodyVel, 0.2)
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)

	Debris:AddItem(whirlpool, 4)
end

-- NUEVO: Olas de agua múltiples (derecha)
function ElementalPowers.WaterWavesPower(player, moveState)
	local character = player.Character
	if not character then return end
	local hand = getHand(character, true) -- Mano derecha
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not hand or not rootPart then return end

	playMartialArtsAnimation(character, "water")

	local direction = rootPart.CFrame.LookVector

	-- Crear múltiples olas de agua
	for i = 1, 4 do
		spawn(function()
			task.wait(i * 0.3) -- Delay entre olas

			local wave = Instance.new("Part")
			wave.Size = Vector3.new(12, 6, 3)
			wave.Position = hand.Position + direction * (5 + i * 3)
			wave.Anchored = false
			wave.CanCollide = false
			wave.Transparency = 0.3
			wave.Color = Color3.fromRGB(80, 180, 255)
			wave.Material = Enum.Material.ForceField
			wave.Parent = workspace

			-- Orientar la ola
			wave.CFrame = CFrame.lookAt(wave.Position, wave.Position + direction)

			local bodyVel = Instance.new("BodyVelocity")
			bodyVel.Velocity = direction * 65
			bodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e5
			bodyVel.Parent = wave

			-- Efectos de partículas de la ola
			local waveEmitter = Instance.new("ParticleEmitter")
			waveEmitter.Texture = "rbxassetid://484436622"
			waveEmitter.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 220, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 160, 255))
			}
			waveEmitter.Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 2),
				NumberSequenceKeypoint.new(1, 1)
			}
			waveEmitter.Lifetime = NumberRange.new(0.8, 1.5)
			waveEmitter.Rate = 180
			waveEmitter.Speed = NumberRange.new(12, 25)
			waveEmitter.SpreadAngle = Vector2.new(60, 30)
			waveEmitter.Parent = wave

			wave.Touched:Connect(function(hit)
				local hum = hit.Parent:FindFirstChild("Humanoid")
				if hum and hum ~= character:FindFirstChild("Humanoid") then
					hum:TakeDamage(22)
					-- Empujar con la fuerza de la ola
					local bodyVel = Instance.new("BodyVelocity")
					bodyVel.Velocity = direction * 40 + Vector3.new(0, 15, 0)
					bodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e4
					bodyVel.Parent = hit.Parent:FindFirstChild("HumanoidRootPart")
					Debris:AddItem(bodyVel, 0.8)
					wave:Destroy()
				end
			end)

			Debris:AddItem(wave, 3)
		end)
	end
end

-- NUEVO: Tsunami masivo (salto)
function ElementalPowers.WaterTsunamiPower(player, moveState)
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	playMartialArtsAnimation(character, "water")

	-- Crear tsunami masivo que cubre gran área
	local tsunamiPos = rootPart.Position + rootPart.CFrame.LookVector * 15
	local tsunami = Instance.new("Part")
	tsunami.Size = Vector3.new(25, 20, 8)
	tsunami.Position = tsunamiPos + Vector3.new(0, 10, 0)
	tsunami.Anchored = false
	tsunami.CanCollide = false
	tsunami.Transparency = 0.2
	tsunami.Color = Color3.fromRGB(60, 150, 255)
	tsunami.Material = Enum.Material.ForceField
	tsunami.Parent = workspace

	local direction = rootPart.CFrame.LookVector
	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.Velocity = direction * 45
	bodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e5
	bodyVel.Parent = tsunami

	-- Efectos masivos de agua
	local tsunamiEmitter = Instance.new("ParticleEmitter")
	tsunamiEmitter.Texture = "rbxassetid://484436622"
	tsunamiEmitter.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 200, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 180, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 120, 200))
	}
	tsunamiEmitter.Size = NumberSequence.new{
		ColorSequenceKeypoint.new(0, 4),
		ColorSequenceKeypoint.new(1, 2)
	}
	tsunamiEmitter.Lifetime = NumberRange.new(2, 4)
	tsunamiEmitter.Rate = 400
	tsunamiEmitter.Speed = NumberRange.new(25, 45)
	tsunamiEmitter.SpreadAngle = Vector2.new(90, 45)
	tsunamiEmitter.Acceleration = Vector3.new(0, -15, 0)
	tsunamiEmitter.Parent = tsunami

	-- Daño masivo al impactar
	tsunami.Touched:Connect(function(hit)
		local hum = hit.Parent:FindFirstChild("Humanoid")
		if hum and hum ~= character:FindFirstChild("Humanoid") then
			hum:TakeDamage(55)
			-- Empuje devastador
			local rootHit = hit.Parent:FindFirstChild("HumanoidRootPart")
			if rootHit then
				local bodyVel = Instance.new("BodyVelocity")
				bodyVel.Velocity = direction * 80 + Vector3.new(0, 30, 0)
				bodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e5
				bodyVel.Parent = rootHit
				Debris:AddItem(bodyVel, 1.2)
			end
		end
	end)

	Debris:AddItem(tsunami, 6)
end

-- Lógica para usar el poder correcto según elemento y dirección
function ElementalPowers.UsePower(player, element, moveState)
	if element == "Fuego" then
		if moveState == "Jump" then
			ElementalPowers.FireExplosionPower(player, moveState)
		elseif moveState == "Left" then
			ElementalPowers.FireBombPower(player, moveState)
		elseif moveState == "Right" then
			ElementalPowers.FireBarragePower(player, moveState)
		else
			ElementalPowers.FirePower(player, moveState)
		end
	elseif element == "Azula" then
		ElementalPowers.AzulaLightningPower(player, moveState)
	elseif element == "Aire" then
		if moveState == "Left" then
			ElementalPowers.AirTornadoPower(player, moveState)
		elseif moveState == "Right" then
			ElementalPowers.AirSlashPower(player, moveState)
		else
			ElementalPowers.AirPower(player, moveState)
		end
	elseif element == "Tierra" then
		if moveState == "Left" then
			ElementalPowers.EarthWallPower(player, moveState)
		elseif moveState == "Right" then
			ElementalPowers.EarthQuakePower(player, moveState)
		else
			ElementalPowers.EarthPower(player, moveState)
		end
	elseif element == "Agua" then
		if moveState == "Jump" then
			ElementalPowers.WaterTsunamiPower(player, moveState)
		elseif moveState == "Left" then
			ElementalPowers.WaterWhirlpoolPower(player, moveState)
		elseif moveState == "Right" then
			ElementalPowers.WaterWavesPower(player, moveState)
		else
			ElementalPowers.WaterPower(player, moveState)
		end
	end
end

UseElementPower.OnServerEvent:Connect(function(player, element, moveState)
	ElementalPowers.UsePower(player, element, moveState)
end)

return ElementalPowers




