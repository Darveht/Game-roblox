
-- Servidor para gestionar el bosque y asegurar que esté presente
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Función para verificar si el bosque existe
local function forestExists()
	return Workspace:FindFirstChild("BosquePlataforma") ~= nil
end

-- Función para generar bosque si no existe
local function ensureForestExists()
	if not forestExists() then
		-- Ejecutar el generador de bosque
		local success, err = pcall(function()
			require(script.Parent.BosqueGenerador)
		end)
		if not success then
			warn("Error generando bosque: " .. tostring(err))
		end
	end
end

-- Generar bosque al iniciar el servidor
ensureForestExists()

-- Cuando un jugador se conecta, asegurar que el bosque exista
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		-- Esperar un poco para que el jugador cargue completamente
		wait(2)
		ensureForestExists()
	end)
end)

-- Verificar periódicamente que el bosque siga existiendo
spawn(function()
	while true do
		wait(30) -- Verificar cada 30 segundos
		ensureForestExists()
	end
end)
