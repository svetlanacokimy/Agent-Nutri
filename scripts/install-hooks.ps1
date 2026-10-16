#Requires -Version 5.1
# Устанавливает git-хуки из scripts/hooks/ в .git/hooks/.
# Запускать из корня репозитория на КАЖДОЙ машине после клонирования:
#   powershell -ExecutionPolicy Bypass -File scripts/install-hooks.ps1
$ErrorActionPreference = 'Stop'
$src = 'scripts\hooks\pre-commit'
$dst = '.git\hooks\pre-commit'
if (-not (Test-Path '.git')) { Write-Error 'Запусти из корня репозитория (.git не найден).'; exit 1 }
if (-not (Test-Path $src))   { Write-Error "Не найден $src"; exit 1 }
# читаем и пишем как есть (LF, без BOM) — критично для sh
$body = [System.IO.File]::ReadAllText("$PWD\$src")
$enc  = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText("$PWD\$dst", ($body -replace "`r`n","`n"), $enc)
Write-Output "pre-commit установлен в .git/hooks/ OK"
# самопроверка
$bytes = [System.IO.File]::ReadAllBytes("$PWD\$dst")
if ($bytes[0] -eq 0xEF) { Write-Warning "ВНИМАНИЕ: в хуке BOM — sh может не распознать shebang" }
if ($bytes -contains 13) { Write-Warning "ВНИМАНИЕ: в хуке есть CR — возможны проблемы" }