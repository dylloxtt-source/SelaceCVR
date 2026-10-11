# SelaceCVR

Проект Roblox-игры, который синхронизируется со Studio через [Rojo](https://rojo.space).

## Структура

| Папка | Куда попадает в Studio | Тип |
|---|---|---|
| `src/server/` | `ServerScriptService.Server` | Script (`init.server.luau`) |
| `src/client/` | `StarterPlayer.StarterPlayerScripts.Client` | LocalScript (`init.client.luau`) |
| `src/shared/` | `ReplicatedStorage.Shared` | папка с ModuleScript |

Правила именования файлов:
- `*.server.luau` → Script
- `*.client.luau` → LocalScript
- `*.luau` → ModuleScript

## Первый запуск

1. Установите [Rokit](https://github.com/rojo-rbx/rokit), затем в папке проекта выполните:
   ```
   rokit install
   ```
2. Установите плагин Rojo для Studio:
   ```
   rojo plugin install
   ```
3. Запустите сервер синхронизации:
   ```
   rojo serve
   ```
4. Откройте в Roblox Studio пустое место (Baseplate), во вкладке **Plugins** нажмите **Rojo → Connect**.

После этого изменения файлов в `src/` сразу появляются в Studio.

## Сборка файла места

```
rojo build -o SelaceCVR.rbxl
```
