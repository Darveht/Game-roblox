-- Generador de plataforma de bosque con árboles y piedras para sobrevivir
local Workspace = game:GetService("Workspace")

-- Limpiar bosque anterior si existe
for _, obj in Workspace:GetChildren() do
    if obj.Name == "BosquePlataforma" or obj.Name == "BosqueArbol" or obj.Name == "BosquePiedra" then
        obj:Destroy()
    end
end

-- Crear plataforma base
local plataforma = Instance.new("Part")
plataforma.Name = "BosquePlataforma"
plataforma.Size = Vector3.new(180, 2, 180)
plataforma.Position = Vector3.new(-10, 1, 50)
plataforma.Anchored = true
plataforma.Material = Enum.Material.Grass
plataforma.Color = Color3.fromRGB(60, 180, 60)
plataforma.Parent = Workspace

-- Generar árboles
for i = 1, 55 do
    local tronco = Instance.new("Part")
    tronco.Name = "BosqueArbol"
    tronco.Size = Vector3.new(2, math.random(14, 22), 2)
    local x = math.random(-85, 65)
    local z = math.random(-35, 135)
    tronco.Position = Vector3.new(plataforma.Position.X + x, plataforma.Position.Y + tronco.Size.Y/2 + 1, plataforma.Position.Z + z)
    tronco.Anchored = true
    tronco.Material = Enum.Material.Wood
    tronco.Color = Color3.fromRGB(80, 60, 30)
    tronco.Parent = Workspace

    local copa = Instance.new("Part")
    copa.Name = "BosqueArbol"
    copa.Size = Vector3.new(math.random(7, 13), math.random(7, 11), math.random(7, 13))
    copa.Position = tronco.Position + Vector3.new(0, tronco.Size.Y/2 + copa.Size.Y/2, 0)
    copa.Anchored = true
    copa.Material = Enum.Material.Grass
    copa.Color = Color3.fromRGB(40, 120, 40)
    copa.Parent = Workspace
end

-- Generar piedras
for i = 1, 35 do
    local piedra = Instance.new("Part")
    piedra.Name = "BosquePiedra"
    local size = math.random(3, 8)
    piedra.Size = Vector3.new(size, math.random(2, 5), size)
    local x = math.random(-85, 65)
    local z = math.random(-35, 135)
    piedra.Position = Vector3.new(plataforma.Position.X + x, plataforma.Position.Y + piedra.Size.Y/2 + 1, plataforma.Position.Z + z)
    piedra.Anchored = true
    piedra.Material = Enum.Material.Slate
    piedra.Color = Color3.fromRGB(110, 110, 110)
    piedra.Parent = Workspace
end

-- (Opcional) Generar algunos arbustos
for i = 1, 20 do
    local arbusto = Instance.new("Part")
    arbusto.Name = "BosqueArbol"
    arbusto.Size = Vector3.new(math.random(3, 6), math.random(2, 3), math.random(3, 6))
    local x = math.random(-85, 65)
    local z = math.random(-35, 135)
    arbusto.Position = Vector3.new(plataforma.Position.X + x, plataforma.Position.Y + arbusto.Size.Y/2 + 1, plataforma.Position.Z + z)
    arbusto.Anchored = true
    arbusto.Material = Enum.Material.Grass
    arbusto.Color = Color3.fromRGB(60, 180, 60)
    arbusto.Transparency = 0.15
    arbusto.Parent = Workspace
end

