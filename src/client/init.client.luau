-- Клиентская точка входа (LocalScript в StarterPlayerScripts)

local Players = game:GetService("Players")

local player = Players.LocalPlayer

print(`[Client] Привет, {player.Name}!`)
